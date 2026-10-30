package com.supplychain.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_id", nullable = false, unique = true, length = 100)
    private String productId;

    @Column(name = "batch_number", nullable = false, length = 50)
    private String batchNumber;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(length = 100)
    private String category;

    @Column(name = "manufacturer_name", length = 100)
    private String manufacturerName;

    @Column(name = "manufacturer_wallet", length = 42)
    private String manufacturerWallet;

    @Enumerated(EnumType.STRING)
    @Column(name = "current_stage", nullable = false, length = 30)
    private Stage currentStage = Stage.MANUFACTURED;

    @Column(name = "is_perishable")
    private boolean perishable = false;

    @Column(name = "min_temp")
    private Double minTemperature;

    @Column(name = "max_temp")
    private Double maxTemperature;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "blockchain_tx_hash", length = 70)
    private String blockchainTxHash;

    @Column(name = "contract_product_id", length = 100)
    private String contractProductId;

    public Product() {}

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public enum Stage {
        MANUFACTURED,
        IN_TRANSIT,
        WAREHOUSE_STORAGE,
        DISTRIBUTOR_TRANSIT,
        RETAIL_RECEIVED,
        CONSUMER_SOLD
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getBatchNumber() { return batchNumber; }
    public void setBatchNumber(String batchNumber) { this.batchNumber = batchNumber; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getManufacturerName() { return manufacturerName; }
    public void setManufacturerName(String manufacturerName) { this.manufacturerName = manufacturerName; }
    public String getManufacturerWallet() { return manufacturerWallet; }
    public void setManufacturerWallet(String manufacturerWallet) { this.manufacturerWallet = manufacturerWallet; }
    public Stage getCurrentStage() { return currentStage; }
    public void setCurrentStage(Stage currentStage) { this.currentStage = currentStage; }
    public boolean isPerishable() { return perishable; }
    public void setPerishable(boolean perishable) { this.perishable = perishable; }
    public Double getMinTemperature() { return minTemperature; }
    public void setMinTemperature(Double minTemperature) { this.minTemperature = minTemperature; }
    public Double getMaxTemperature() { return maxTemperature; }
    public void setMaxTemperature(Double maxTemperature) { this.maxTemperature = maxTemperature; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getBlockchainTxHash() { return blockchainTxHash; }
    public void setBlockchainTxHash(String blockchainTxHash) { this.blockchainTxHash = blockchainTxHash; }
    public String getContractProductId() { return contractProductId; }
    public void setContractProductId(String contractProductId) { this.contractProductId = contractProductId; }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "N/A";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm"));
    }

    public String getShortTxHash() {
        if (blockchainTxHash == null || blockchainTxHash.isBlank()) return "Pending";
        if (blockchainTxHash.length() > 18) {
            return blockchainTxHash.substring(0, 10) + "..." + blockchainTxHash.substring(blockchainTxHash.length() - 8);
        }
        return blockchainTxHash;
    }
}
