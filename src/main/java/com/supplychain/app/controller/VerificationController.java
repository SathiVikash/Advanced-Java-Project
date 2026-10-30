package com.supplychain.app.controller;

import com.supplychain.app.bean.VerificationResultBean;
import com.supplychain.app.entity.AnomalyLog;
import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import com.supplychain.app.repository.AnomalyLogRepository;
import com.supplychain.app.service.IntegrityVerificationService;
import com.supplychain.app.service.SupplyChainService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Controller
public class VerificationController {

    private final SupplyChainService supplyChainService;
    private final IntegrityVerificationService verificationService;
    private final AnomalyLogRepository anomalyLogRepository;

    @Autowired
    public VerificationController(SupplyChainService supplyChainService,
                                  IntegrityVerificationService verificationService,
                                  AnomalyLogRepository anomalyLogRepository) {
        this.supplyChainService = supplyChainService;
        this.verificationService = verificationService;
        this.anomalyLogRepository = anomalyLogRepository;
    }

    /**
     * Public tracking endpoint — accessible without login.
     */
    @GetMapping("/track")
    public String publicTrack(@RequestParam(required = false) String productId, Model model) {
        model.addAttribute("productId", productId);
        if (productId != null && !productId.isBlank()) {
            Optional<Product> productOpt = supplyChainService.findByProductId(productId.trim());
            if (productOpt.isPresent()) {
                Product product = productOpt.get();
                List<SupplyChainEvent> history = supplyChainService.getProductHistory(product);
                model.addAttribute("product", product);
                model.addAttribute("history", history);
            } else {
                model.addAttribute("notFound", true);
            }
        }
        return "track-product";
    }

    /**
     * Auditor/Consumer: Verify product integrity against the blockchain.
     */
    @GetMapping("/verify")
    public String verifyProduct(@RequestParam(required = false) String productId, Model model) {
        if (productId == null || productId.isBlank()) {
            return "verify";
        }

        Optional<Product> productOpt = supplyChainService.findByProductId(productId.trim());

        if (productOpt.isEmpty()) {
            model.addAttribute("errorMsg", "Product not found: " + productId);
            return "verify";
        }

        Product product = productOpt.get();
        List<SupplyChainEvent> history = supplyChainService.getProductHistory(product);

        IntegrityVerificationService.VerificationResult result =
            verificationService.verifyProductIntegrity(product);

        VerificationResultBean bean = new VerificationResultBean();
        bean.setProductId(productId);
        bean.setProductName(product.getName());
        bean.setResult(result);
        bean.setTotalEvents(history.size());
        bean.setVerifiedEvents((int) history.stream()
            .filter(e -> e.getIntegrityStatus() == SupplyChainEvent.IntegrityStatus.VERIFIED).count());
        bean.setTamperedEvents((int) history.stream()
            .filter(e -> e.getIntegrityStatus() == SupplyChainEvent.IntegrityStatus.TAMPERED).count());

        switch (result) {
            case VERIFIED -> {
                bean.setResultMessage("✓ INTEGRITY VERIFIED — All off-chain records match the Ethereum blockchain.");
                bean.setResultClass("verified");
            }
            case TAMPERED -> {
                bean.setResultMessage("⚠ INTEGRITY BREACH — Off-chain data has been altered. On-chain hashes do NOT match.");
                bean.setResultClass("tampered");
            }
            case NO_ON_CHAIN_DATA -> {
                bean.setResultMessage("⚙ Blockchain confirmation pending. Try again shortly.");
                bean.setResultClass("pending");
            }
            default -> {
                bean.setResultMessage("Error during verification. Check blockchain connection.");
                bean.setResultClass("error");
            }
        }

        model.addAttribute("verificationResult", bean);
        model.addAttribute("product", product);
        model.addAttribute("history", history);

        return "verify";
    }

    /**
     * Anomaly dashboard for Auditor role.
     */
    @GetMapping("/anomalies")
    public String anomaliesDashboard(Model model) {
        List<AnomalyLog> anomalies = anomalyLogRepository.findByResolvedFalseOrderByDetectedAtDesc();
        long criticalCount = anomalyLogRepository.countCriticalUnresolved();

        model.addAttribute("anomalies", anomalies);
        model.addAttribute("criticalCount", criticalCount);
        model.addAttribute("totalUnresolved", anomalies.size());
        return "anomalies";
    }

    /**
     * Mark an anomaly as resolved.
     */
    @PostMapping("/anomalies/resolve/{id}")
    public String resolveAnomaly(@PathVariable Long id) {
        anomalyLogRepository.findById(id).ifPresent(a -> {
            a.setResolved(true);
            anomalyLogRepository.save(a);
        });
        return "redirect:/anomalies";
    }
}
