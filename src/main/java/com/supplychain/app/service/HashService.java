package com.supplychain.app.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * HashService: Computes the SHA-256 hash of an off-chain supply chain event record.
 * This hash is stored both in MySQL (for reference) and on the Ethereum blockchain (for immutability).
 * The IntegrityVerificationService uses this to detect tampering.
 */
@Service
public class HashService {

    private static final Logger log = LoggerFactory.getLogger(HashService.class);

    /**
     * Computes SHA-256 hash over all key fields of a supply chain event.
     * Formula: SHA256(productId + "|" + stage + "|" + epochSeconds + "|" + location + "|" + temp + "|" + actorWallet)
     *
     * @return 64-character lowercase hex string (e.g., "a3f1c...")
     */
    public String computeEventHash(
            String productId,
            String stage,
            long epochSeconds,
            String location,
            Double temperature,
            String actorWallet) {

        // Normalize: use "N/A" if temperature is null (non-perishable goods)
        String tempStr = (temperature != null) ? String.format("%.2f", temperature) : "N/A";
        String walletNormalized = (actorWallet != null) ? actorWallet.toLowerCase() : "0x0000000000000000000000000000000000000000";

        String payload = productId + "|" + stage + "|" + epochSeconds + "|" + location + "|" + tempStr + "|" + walletNormalized;

        log.debug("Computing hash for payload: {}", payload);
        return sha256(payload);
    }

    /**
     * Recomputes the hash for an existing event from MySQL fields for integrity verification.
     */
    public String recomputeHash(
            String productId,
            String stage,
            long onChainTimestamp,
            String location,
            Double temperature,
            String actorWallet) {
        return computeEventHash(productId, stage, onChainTimestamp, location, temperature, actorWallet);
    }

    // ========================
    //   INTERNAL SHA-256 UTIL
    // ========================

    private String sha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not found", e);
        }
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
