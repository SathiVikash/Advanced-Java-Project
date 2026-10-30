package com.supplychain.app.bean;

import jakarta.validation.constraints.NotBlank;

/**
 * Java Bean for stage update form (JSP form backing object)
 */
public class StageUpdateBean {

    @NotBlank(message = "Product ID is required")
    private String productId;

    @NotBlank(message = "Stage is required")
    private String stage;

    @NotBlank(message = "Location is required")
    private String location;

    private Double temperature;
    private Double humidity;
    private String notes;

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getStage() { return stage; }
    public void setStage(String stage) { this.stage = stage; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }
    public Double getHumidity() { return humidity; }
    public void setHumidity(Double humidity) { this.humidity = humidity; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
