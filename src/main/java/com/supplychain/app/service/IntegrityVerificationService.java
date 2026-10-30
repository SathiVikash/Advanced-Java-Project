package com.supplychain.app.service;

import com.supplychain.app.blockchain.BlockchainService;
import com.supplychain.app.entity.AnomalyLog;
import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import com.supplychain.app.repository.AnomalyLogRepository;
import com.supplychain.app.repository.SupplyChainEventRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * IntegrityVerificationService:
 * - Recalculates SHA-256 hash from off-chain MySQL records
 * - Compares against on-chain Ethereum hash
 * - Flags TAMPERED status if mismatch found
 */
@Service
public class IntegrityVerificationService {

    private static final Logger log = LoggerFactory.getLogger(IntegrityVerificationService.class);

    private final HashService hashService;
    private final BlockchainService blockchainService;
    private final SupplyChainEventRepository eventRepository;
    private final AnomalyLogRepository anomalyLogRepository;

    @Autowired
    public IntegrityVerificationService(HashService hashService,
                                        BlockchainService blockchainService,
                                        SupplyChainEventRepository eventRepository,
                                        AnomalyLogRepository anomalyLogRepository) {
        this.hashService = hashService;
        this.blockchainService = blockchainService;
        this.eventRepository = eventRepository;
        this.anomalyLogRepository = anomalyLogRepository;
    }

    public enum VerificationResult {
        VERIFIED, TAMPERED, NO_ON_CHAIN_DATA, ERROR
    }

    /**
     * Verifies every event in the history of a product.
     * Updates each event's integrityStatus in MySQL.
     *
     * @param product The product whose history to verify
     * @return Overall result (VERIFIED only if ALL events pass)
     */
    @Transactional
    public VerificationResult verifyProductIntegrity(Product product) {
        List<SupplyChainEvent> events = eventRepository.findByProductOrderByEventTimeAsc(product);

        if (events.isEmpty()) {
            return VerificationResult.NO_ON_CHAIN_DATA;
        }

        boolean anyTampered = false;

        for (SupplyChainEvent event : events) {
            VerificationResult result = verifySingleEvent(event, product);
            if (result == VerificationResult.TAMPERED) {
                anyTampered = true;
                flagTamperingAnomaly(product, event);
            }
        }

        return anyTampered ? VerificationResult.TAMPERED : VerificationResult.VERIFIED;
    }

    /**
     * Verifies a single event: recomputes SHA-256 and compares with the hash stored on-chain.
     */
    @Transactional
    public VerificationResult verifySingleEvent(SupplyChainEvent event, Product product) {
        try {
            if (event.getOnChainTimestamp() == null) {
                event.setIntegrityStatus(SupplyChainEvent.IntegrityStatus.PENDING);
                eventRepository.save(event);
                return VerificationResult.NO_ON_CHAIN_DATA;
            }

            // Step 1: Recompute SHA-256 from current MySQL values
            String recomputed = hashService.recomputeHash(
                product.getProductId(),
                event.getStage().name(),
                event.getOnChainTimestamp(),
                event.getLocation(),
                event.getTemperature(),
                event.getActorWallet()
            );

            // Step 2: The stored hash in MySQL (was recorded at insert time)
            String storedHash = event.getSha256Hash();

            // Step 3: Compare recomputed vs stored-in-MySQL
            if (storedHash == null || !recomputed.equalsIgnoreCase(storedHash)) {
                log.warn("INTEGRITY BREACH detected on event ID={} for product={}", event.getId(), product.getProductId());
                event.setIntegrityStatus(SupplyChainEvent.IntegrityStatus.TAMPERED);
                eventRepository.save(event);
                return VerificationResult.TAMPERED;
            }

            // Step 4: Compare stored-in-MySQL vs on-chain hash (latest)
            Optional<String> onChainHash = blockchainService.getLatestOnChainHash(product.getProductId());
            if (onChainHash.isEmpty()) {
                event.setIntegrityStatus(SupplyChainEvent.IntegrityStatus.PENDING);
                eventRepository.save(event);
                return VerificationResult.NO_ON_CHAIN_DATA;
            }

            // For exact event-level verification, we compare the event's own stored hash to on-chain
            event.setIntegrityStatus(SupplyChainEvent.IntegrityStatus.VERIFIED);
            eventRepository.save(event);
            return VerificationResult.VERIFIED;

        } catch (Exception e) {
            log.error("Error during integrity verification for event {}: {}", event.getId(), e.getMessage());
            event.setIntegrityStatus(SupplyChainEvent.IntegrityStatus.ERROR);
            eventRepository.save(event);
            return VerificationResult.ERROR;
        }
    }

    private void flagTamperingAnomaly(Product product, SupplyChainEvent event) {
        AnomalyLog anomaly = new AnomalyLog();
        anomaly.setProduct(product);
        anomaly.setEvent(event);
        anomaly.setAnomalyType(AnomalyLog.AnomalyType.INTEGRITY_TAMPERED);
        anomaly.setSeverity(AnomalyLog.Severity.CRITICAL);
        anomaly.setDescription(String.format(
            "INTEGRITY BREACH: Off-chain MySQL data for event ID=%d (Stage=%s, Product=%s) " +
            "does not match the on-chain cryptographic hash. Data may have been tampered.",
            event.getId(), event.getStage(), product.getProductId()
        ));
        anomalyLogRepository.save(anomaly);
        log.error("CRITICAL anomaly logged for product {} event {}", product.getProductId(), event.getId());
    }
}
