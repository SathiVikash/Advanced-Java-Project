package com.supplychain.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "anomaly_logs")
public class AnomalyLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id")
    private SupplyChainEvent event;

    @Enumerated(EnumType.STRING)
    @Column(name = "anomaly_type", nullable = false, length = 40)
    private AnomalyType anomalyType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Severity severity;

    @Column(nullable = false, length = 500)
    private String description;

    @Column(name = "detected_at")
    private LocalDateTime detectedAt;

    @Column(name = "is_resolved")
    private boolean resolved = false;

    public AnomalyLog() {}

    @PrePersist
    protected void onCreate() {
        this.detectedAt = LocalDateTime.now();
    }

    public enum AnomalyType {
        TEMPERATURE_EXCURSION,
        INVALID_STAGE_SEQUENCE,
        IMPOSSIBLE_LOCATION_JUMP,
        INTEGRITY_TAMPERED,
        UNAUTHORIZED_ACTOR
    }

    public enum Severity {
        LOW, MEDIUM, HIGH, CRITICAL
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public SupplyChainEvent getEvent() { return event; }
    public void setEvent(SupplyChainEvent event) { this.event = event; }
    public AnomalyType getAnomalyType() { return anomalyType; }
    public void setAnomalyType(AnomalyType anomalyType) { this.anomalyType = anomalyType; }
    public Severity getSeverity() { return severity; }
    public void setSeverity(Severity severity) { this.severity = severity; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getDetectedAt() { return detectedAt; }
    public void setDetectedAt(LocalDateTime detectedAt) { this.detectedAt = detectedAt; }
    public boolean isResolved() { return resolved; }
    public void setResolved(boolean resolved) { this.resolved = resolved; }

    public String getFormattedDetectedAt() {
        if (detectedAt == null) return "N/A";
        return detectedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }
}
