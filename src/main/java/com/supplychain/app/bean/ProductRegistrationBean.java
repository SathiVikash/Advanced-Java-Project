package com.supplychain.app.bean;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Java Bean for product registration form (JSP form backing object)
 */
public class ProductRegistrationBean {

    @NotBlank(message = "Product name is required")
    @Size(max = 200)
    private String name;

    @NotBlank(message = "Batch number is required")
    private String batchNumber;

    @Size(max = 500)
    private String description;

    @NotBlank(message = "Category is required")
    private String category;

    @NotBlank(message = "Manufacturer name is required")
    private String manufacturerName;

    @NotBlank(message = "Origin location is required")
    private String originLocation;

    private boolean perishable = false;
    private Double minTemperature;
    private Double maxTemperature;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getBatchNumber() { return batchNumber; }
    public void setBatchNumber(String batchNumber) { this.batchNumber = batchNumber; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getManufacturerName() { return manufacturerName; }
    public void setManufacturerName(String manufacturerName) { this.manufacturerName = manufacturerName; }
    public String getOriginLocation() { return originLocation; }
    public void setOriginLocation(String originLocation) { this.originLocation = originLocation; }
    public boolean isPerishable() { return perishable; }
    public void setPerishable(boolean perishable) { this.perishable = perishable; }
    public Double getMinTemperature() { return minTemperature; }
    public void setMinTemperature(Double minTemperature) { this.minTemperature = minTemperature; }
    public Double getMaxTemperature() { return maxTemperature; }
    public void setMaxTemperature(Double maxTemperature) { this.maxTemperature = maxTemperature; }
}
