package com.supplychain.app.service;

import com.supplychain.app.bean.ProductRegistrationBean;
import com.supplychain.app.bean.StageUpdateBean;
import com.supplychain.app.blockchain.BlockchainService;
import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import com.supplychain.app.repository.ProductRepository;
import com.supplychain.app.repository.SupplyChainEventRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class SupplyChainService {

    private static final Logger log = LoggerFactory.getLogger(SupplyChainService.class);

    private final ProductRepository productRepository;
    private final SupplyChainEventRepository eventRepository;
    private final BlockchainService blockchainService;
    private final HashService hashService;
    private final AnomalyDetectionService anomalyDetectionService;

    @Autowired
    public SupplyChainService(ProductRepository productRepository,
                              SupplyChainEventRepository eventRepository,
                              BlockchainService blockchainService,
                              HashService hashService,
                              AnomalyDetectionService anomalyDetectionService) {
        this.productRepository = productRepository;
        this.eventRepository = eventRepository;
        this.blockchainService = blockchainService;
        this.hashService = hashService;
        this.anomalyDetectionService = anomalyDetectionService;
    }

    /**
     * Registers a new product: saves to MySQL + commits to Ethereum.
     */
    @Transactional
    public Product registerProduct(ProductRegistrationBean bean, String actorWallet) throws Exception {
        // 1. Generate a unique Product ID
        String productId = "PROD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        long epochNow = Instant.now().getEpochSecond();

        // 2. Compute SHA-256 hash for the registration event
        String dataHash = hashService.computeEventHash(
            productId,
            Product.Stage.MANUFACTURED.name(),
            epochNow,
            bean.getOriginLocation(),
            null, // no temperature at registration for non-perishables
            actorWallet
        );

        // 3. Save product to MySQL
        Product product = new Product();
        product.setProductId(productId);
        product.setBatchNumber(bean.getBatchNumber());
        product.setName(bean.getName());
        product.setDescription(bean.getDescription());
        product.setCategory(bean.getCategory());
        product.setManufacturerName(bean.getManufacturerName());
        product.setManufacturerWallet(actorWallet);
        product.setCurrentStage(Product.Stage.MANUFACTURED);
        product.setPerishable(bean.isPerishable());
        product.setMinTemperature(bean.getMinTemperature());
        product.setMaxTemperature(bean.getMaxTemperature());
        productRepository.save(product);

        // 4. Save the MANUFACTURED event to MySQL
        SupplyChainEvent event = new SupplyChainEvent();
        event.setProduct(product);
        event.setStage(Product.Stage.MANUFACTURED);
        event.setLocation(bean.getOriginLocation());
        event.setActorWallet(actorWallet);
        event.setActorRole("MANUFACTURER");
        event.setActorName(bean.getManufacturerName());
        event.setSha256Hash(dataHash);
        event.setOnChainTimestamp(epochNow);
        event.setNotes("Initial product registration");
        eventRepository.save(event);

        // 5. Commit to Ethereum (failure logs but does not rollback MySQL)
        try {
            String txHash = blockchainService.registerProduct(
                productId, bean.getBatchNumber(), dataHash, bean.getOriginLocation());
            product.setBlockchainTxHash(txHash);
            event.setBlockchainTxHash(txHash);
            productRepository.save(product);
            eventRepository.save(event);
            log.info("Product {} registered on-chain. TxHash: {}", productId, txHash);
        } catch (Exception e) {
            log.error("Blockchain commit failed for product {}: {}", productId, e.getMessage());
            // Product is still saved in MySQL — blockchain state is PENDING
        }

        return product;
    }

    /**
     * Adds a new stage event: validates sequence, runs anomaly checks, saves to MySQL + blockchain.
     */
    @Transactional
    public SupplyChainEvent addStageEvent(StageUpdateBean bean, String actorWallet, String actorRole, String actorName) throws Exception {
        Product product = productRepository.findByProductId(bean.getProductId())
            .orElseThrow(() -> new IllegalArgumentException("Product not found: " + bean.getProductId()));

        Product.Stage newStage = Product.Stage.valueOf(bean.getStage());
        long epochNow = Instant.now().getEpochSecond();

        // 1. Compute hash
        String dataHash = hashService.computeEventHash(
            bean.getProductId(),
            newStage.name(),
            epochNow,
            bean.getLocation(),
            bean.getTemperature(),
            actorWallet
        );

        // 2. Get previous event for anomaly detection
        Optional<SupplyChainEvent> prevEventOpt = eventRepository.findTopByProductOrderByEventTimeDesc(product);
        SupplyChainEvent prevEvent = prevEventOpt.orElse(null);

        // 3. Create and save new event
        SupplyChainEvent event = new SupplyChainEvent();
        event.setProduct(product);
        event.setStage(newStage);
        event.setLocation(bean.getLocation());
        event.setTemperature(bean.getTemperature());
        event.setHumidity(bean.getHumidity());
        event.setActorWallet(actorWallet);
        event.setActorRole(actorRole);
        event.setActorName(actorName);
        event.setSha256Hash(dataHash);
        event.setOnChainTimestamp(epochNow);
        event.setNotes(bean.getNotes());
        eventRepository.save(event);

        // 4. Run anomaly detection
        anomalyDetectionService.detectAnomalies(product, event, prevEvent);

        // 5. Update product's current stage
        product.setCurrentStage(newStage);
        productRepository.save(product);

        // 6. Commit to Ethereum
        try {
            String txHash = blockchainService.addStageEvent(
                bean.getProductId(), newStage.ordinal(), dataHash, bean.getLocation());
            event.setBlockchainTxHash(txHash);
            eventRepository.save(event);
        } catch (Exception e) {
            log.error("Blockchain stage commit failed for product {}: {}", bean.getProductId(), e.getMessage());
        }

        return event;
    }

    public Optional<Product> findByProductId(String productId) {
        return productRepository.findByProductId(productId);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAllOrderByCreatedAtDesc();
    }

    public List<SupplyChainEvent> getProductHistory(Product product) {
        return eventRepository.findByProductOrderByEventTimeAsc(product);
    }
}
