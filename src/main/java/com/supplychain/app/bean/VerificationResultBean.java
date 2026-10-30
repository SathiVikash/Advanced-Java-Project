package com.supplychain.app.bean;

import com.supplychain.app.service.IntegrityVerificationService;

/**
 * Java Bean for the verification result returned to the JSP view
 */
public class VerificationResultBean {

    private String productId;
    private String productName;
    private IntegrityVerificationService.VerificationResult result;
    private String resultMessage;
    private String resultClass; // CSS class: "verified", "tampered", "pending"
    private String onChainHash;
    private String recomputedHash;
    private int totalEvents;
    private int verifiedEvents;
    private int tamperedEvents;

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public IntegrityVerificationService.VerificationResult getResult() { return result; }
    public void setResult(IntegrityVerificationService.VerificationResult result) { this.result = result; }
    public String getResultMessage() { return resultMessage; }
    public void setResultMessage(String resultMessage) { this.resultMessage = resultMessage; }
    public String getResultClass() { return resultClass; }
    public void setResultClass(String resultClass) { this.resultClass = resultClass; }
    public String getOnChainHash() { return onChainHash; }
    public void setOnChainHash(String onChainHash) { this.onChainHash = onChainHash; }
    public String getRecomputedHash() { return recomputedHash; }
    public void setRecomputedHash(String recomputedHash) { this.recomputedHash = recomputedHash; }
    public int getTotalEvents() { return totalEvents; }
    public void setTotalEvents(int totalEvents) { this.totalEvents = totalEvents; }
    public int getVerifiedEvents() { return verifiedEvents; }
    public void setVerifiedEvents(int verifiedEvents) { this.verifiedEvents = verifiedEvents; }
    public int getTamperedEvents() { return tamperedEvents; }
    public void setTamperedEvents(int tamperedEvents) { this.tamperedEvents = tamperedEvents; }
}
