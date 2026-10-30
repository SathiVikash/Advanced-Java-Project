package com.supplychain.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "supply_chain_events")
public class SupplyChainEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private Product.Stage stage;

    @Column(nullable = false, length = 200)
    private String location;

    @Column(name = "actor_wallet", length = 42)
    private String actorWallet;

    @Column(name = "actor_role", length = 20)
    private String actorRole;

    @Column(name = "actor_name", length = 100)
    private String actorName;

    // Environmental telemetry (kept off-chain)
    private Double temperature;
    private Double humidity;

    @Column(length = 500)
    private String notes;

    // On-chain anchoring fields
    @Column(name = "sha256_hash", length = 64)
    private String sha256Hash;

    @Column(name = "blockchain_tx_hash", length = 70)
    private String blockchainTxHash;

    @Column(name = "block_number")
    private Long blockNumber;

    @Column(name = "on_chain_timestamp")
    private Long onChainTimestamp;

    @Enumerated(EnumType.STRING)
    @Column(name = "integrity_status", length = 20)
    private IntegrityStatus integrityStatus = IntegrityStatus.PENDING;

    @Column(name = "event_time")
    private LocalDateTime eventTime;

    public SupplyChainEvent() {}

    @PrePersist
    protected void onCreate() {
        this.eventTime = LocalDateTime.now();
    }

    public enum IntegrityStatus {
        PENDING, VERIFIED, TAMPERED, ERROR
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public Product.Stage getStage() { return stage; }
    public void setStage(Product.Stage stage) { this.stage = stage; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getActorWallet() { return actorWallet; }
    public void setActorWallet(String actorWallet) { this.actorWallet = actorWallet; }
    public String getActorRole() { return actorRole; }
    public void setActorRole(String actorRole) { this.actorRole = actorRole; }
    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }
    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }
    public Double getHumidity() { return humidity; }
    public void setHumidity(Double humidity) { this.humidity = humidity; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public String getSha256Hash() { return sha256Hash; }
    public void setSha256Hash(String sha256Hash) { this.sha256Hash = sha256Hash; }
    public String getBlockchainTxHash() { return blockchainTxHash; }
    public void setBlockchainTxHash(String blockchainTxHash) { this.blockchainTxHash = blockchainTxHash; }
    public Long getBlockNumber() { return blockNumber; }
    public void setBlockNumber(Long blockNumber) { this.blockNumber = blockNumber; }
    public Long getOnChainTimestamp() { return onChainTimestamp; }
    public void setOnChainTimestamp(Long onChainTimestamp) { this.onChainTimestamp = onChainTimestamp; }
    public IntegrityStatus getIntegrityStatus() { return integrityStatus; }
    public void setIntegrityStatus(IntegrityStatus integrityStatus) { this.integrityStatus = integrityStatus; }
    public LocalDateTime getEventTime() { return eventTime; }
    public void setEventTime(LocalDateTime eventTime) { this.eventTime = eventTime; }

    public String getFormattedEventTime() {
        if (eventTime == null) return "N/A";
        return eventTime.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    public String getShortTxHash() {
        if (blockchainTxHash == null || blockchainTxHash.isBlank()) return "Pending";
        if (blockchainTxHash.length() > 18) {
            return blockchainTxHash.substring(0, 10) + "..." + blockchainTxHash.substring(blockchainTxHash.length() - 8);
        }
        return blockchainTxHash;
    }
}
