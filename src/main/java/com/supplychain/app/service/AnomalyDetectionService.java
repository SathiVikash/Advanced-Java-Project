package com.supplychain.app.service;

import com.supplychain.app.entity.AnomalyLog;
import com.supplychain.app.entity.Product;
import com.supplychain.app.entity.SupplyChainEvent;
import com.supplychain.app.repository.AnomalyLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * AnomalyDetectionService:
 * Implements business rule checks for three anomaly types:
 *   1. Temperature Excursion  (Cold-chain violation)
 *   2. Invalid Stage Sequence (Stage skipped or reversed)
 *   3. Impossible Location Jump (Unrealistic geographic teleportation)
 */
@Service
public class AnomalyDetectionService {

    private static final Logger log = LoggerFactory.getLogger(AnomalyDetectionService.class);

    private final AnomalyLogRepository anomalyLogRepository;

    @Autowired
    public AnomalyDetectionService(AnomalyLogRepository anomalyLogRepository) {
        this.anomalyLogRepository = anomalyLogRepository;
    }

    // Cold-chain limits (Pharmaceutical grade defaults)
    private static final double MIN_TEMP = 0.0;
    private static final double MAX_TEMP = 8.0;

    // Location velocity limit: ~900 km/h (slightly above commercial air freight speed)
    private static final double MAX_KM_PER_HOUR = 900.0;

    /**
     * Runs all anomaly checks on a new event being saved.
     * Persists any anomalies detected to the AnomalyLog table.
     *
     * @param product       The product being updated
     * @param newEvent      The new event being submitted
     * @param previousEvent The last known event for this product (can be null)
     */
    @Transactional
    public void detectAnomalies(Product product, SupplyChainEvent newEvent, SupplyChainEvent previousEvent) {
        checkTemperatureExcursion(product, newEvent);
        checkStageSequence(product, newEvent, previousEvent);
        if (previousEvent != null) {
            checkLocationJump(product, newEvent, previousEvent);
        }
    }

    // ======================================
    //   1. TEMPERATURE EXCURSION CHECK
    // ======================================
    private void checkTemperatureExcursion(Product product, SupplyChainEvent event) {
        if (!product.isPerishable()) return;
        if (event.getTemperature() == null) return;

        double temp = event.getTemperature();
        if (temp < MIN_TEMP || temp > MAX_TEMP) {
            AnomalyLog.Severity severity = (temp > 15.0 || temp < -5.0)
                ? AnomalyLog.Severity.CRITICAL : AnomalyLog.Severity.HIGH;

            String desc = String.format(
                "Temperature excursion detected! Recorded: %.2f°C. " +
                "Allowed range for perishable product '%s': %.1f°C to %.1f°C. " +
                "Location: %s, Stage: %s.",
                temp, product.getName(), MIN_TEMP, MAX_TEMP,
                event.getLocation(), event.getStage().name()
            );

            saveAnomaly(product, event, AnomalyLog.AnomalyType.TEMPERATURE_EXCURSION, severity, desc);
            log.warn("TEMPERATURE EXCURSION: product={}, temp={}", product.getProductId(), temp);
        }
    }

    // ======================================
    //   2. INVALID STAGE SEQUENCE CHECK
    // ======================================
    private void checkStageSequence(Product product, SupplyChainEvent newEvent, SupplyChainEvent prevEvent) {
        int expected = (prevEvent == null) ? 0 : prevEvent.getStage().ordinal() + 1;
        int actual = newEvent.getStage().ordinal();

        if (actual != expected) {
            String desc = String.format(
                "Invalid stage sequence for product '%s'. " +
                "Expected stage %d (%s) but received stage %d (%s). " +
                "Supply chain stages must advance strictly in order.",
                product.getProductId(),
                expected, stageNameOf(expected),
                actual, newEvent.getStage().name()
            );

            saveAnomaly(product, newEvent, AnomalyLog.AnomalyType.INVALID_STAGE_SEQUENCE,
                AnomalyLog.Severity.HIGH, desc);
            log.warn("STAGE SEQUENCE VIOLATION: product={}, expected={}, got={}",
                product.getProductId(), expected, actual);
        }
    }

    // ======================================
    //   3. IMPOSSIBLE LOCATION JUMP CHECK
    // ======================================
    private void checkLocationJump(Product product, SupplyChainEvent newEvent, SupplyChainEvent prevEvent) {
        if (newEvent.getOnChainTimestamp() == null || prevEvent.getOnChainTimestamp() == null) return;

        double[] prevCoords = cityToCoords(prevEvent.getLocation());
        double[] newCoords  = cityToCoords(newEvent.getLocation());

        if (prevCoords == null || newCoords == null) return;

        double distanceKm = haversineDistanceKm(prevCoords[0], prevCoords[1], newCoords[0], newCoords[1]);
        long timeDiffSeconds = newEvent.getOnChainTimestamp() - prevEvent.getOnChainTimestamp();
        if (timeDiffSeconds <= 0) return;

        double speedKmH = distanceKm / (timeDiffSeconds / 3600.0);

        if (speedKmH > MAX_KM_PER_HOUR) {
            String desc = String.format(
                "Impossible location jump detected for product '%s'! " +
                "Moved from '%s' to '%s' (%.0f km) in only %d seconds (implied speed: %.0f km/h). " +
                "Maximum allowed speed: %.0f km/h.",
                product.getProductId(),
                prevEvent.getLocation(), newEvent.getLocation(),
                distanceKm, timeDiffSeconds, speedKmH, MAX_KM_PER_HOUR
            );

            saveAnomaly(product, newEvent, AnomalyLog.AnomalyType.IMPOSSIBLE_LOCATION_JUMP,
                AnomalyLog.Severity.MEDIUM, desc);
            log.warn("LOCATION JUMP: product={}, speed={}km/h", product.getProductId(), speedKmH);
        }
    }

    // ======================================
    //   HELPERS
    // ======================================
    private void saveAnomaly(Product product, SupplyChainEvent event,
                              AnomalyLog.AnomalyType type, AnomalyLog.Severity severity, String desc) {
        AnomalyLog anomaly = new AnomalyLog();
        anomaly.setProduct(product);
        anomaly.setEvent(event);
        anomaly.setAnomalyType(type);
        anomaly.setSeverity(severity);
        anomaly.setDescription(desc);
        anomalyLogRepository.save(anomaly);
    }

    private String stageNameOf(int ordinal) {
        Product.Stage[] stages = Product.Stage.values();
        return (ordinal >= 0 && ordinal < stages.length) ? stages[ordinal].name() : "UNKNOWN";
    }

    /**
     * Basic city-to-coordinates lookup for demonstration purposes.
     * In production, use a geocoding API or store GPS coordinates from IoT sensors.
     */
    private double[] cityToCoords(String location) {
        if (location == null) return null;
        String loc = location.toLowerCase();
        if (loc.contains("chennai"))   return new double[]{13.0827, 80.2707};
        if (loc.contains("mumbai"))    return new double[]{19.0760, 72.8777};
        if (loc.contains("delhi"))     return new double[]{28.6139, 77.2090};
        if (loc.contains("bangalore") || loc.contains("bengaluru")) return new double[]{12.9716, 77.5946};
        if (loc.contains("kolkata"))   return new double[]{22.5726, 88.3639};
        if (loc.contains("hyderabad")) return new double[]{17.3850, 78.4867};
        if (loc.contains("pune"))      return new double[]{18.5204, 73.8567};
        if (loc.contains("vellore"))   return new double[]{12.9165, 79.1325};
        return null; // Unknown city - skip check
    }

    private double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
            * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
