<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Update Stage — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 680px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; margin-bottom: 24px; display: inline-block; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px; }
        .card { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; padding: 32px; }
        .form-group { margin-bottom: 22px; }
        label { display: block; font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.7); margin-bottom: 8px; }
        input, select, textarea {
            width: 100%; padding: 11px 14px;
            background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px; color: #fff; font-size: 14px; font-family: 'Inter', sans-serif;
            transition: border-color 0.2s;
        }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #667eea; }
        select option { background: #1e1e3f; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .error { color: #fca5a5; font-size: 12px; margin-top: 5px; }
        .stage-info {
            background: rgba(102,126,234,0.1); border: 1px solid rgba(102,126,234,0.2);
            border-radius: 10px; padding: 14px 16px; margin-bottom: 24px;
            font-size: 13px; color: rgba(255,255,255,0.6); line-height: 1.7;
        }
        .btn-submit {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            border: none; border-radius: 10px; color: #fff;
            font-size: 15px; font-weight: 600; cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s; margin-top: 8px;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(34,197,94,0.4); }
        .temp-warning { font-size: 12px; color: #fcd34d; margin-top: 5px; display: none; }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="page-title">Update Supply Chain Stage</div>
        <div class="page-subtitle">Log the next checkpoint for a tracked product</div>

        <div class="stage-info">
            📋 <strong>Stage Progression:</strong> MANUFACTURED → IN_TRANSIT → WAREHOUSE_STORAGE → DISTRIBUTOR_TRANSIT → RETAIL_RECEIVED → CONSUMER_SOLD<br>
            Each stage update is cryptographically hashed and committed to the Ethereum Sepolia blockchain.
        </div>

        <div class="card">
            <form:form method="POST" action="/product/update-stage" modelAttribute="stageBean">

                <div class="form-group">
                    <label for="productId">Product ID *</label>
                    <form:input path="productId" id="productId" placeholder="e.g. PROD-3F7A9B2C"
                        value="${not empty prefilledProductId ? prefilledProductId : ''}"/>
                    <form:errors path="productId" cssClass="error"/>
                </div>

                <div class="form-group">
                    <label for="stage">New Stage *</label>
                    <form:select path="stage" id="stage">
                        <option value="">— Select Next Stage —</option>
                        <c:forEach var="s" items="${stages}">
                            <option value="${s}">${s}</option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="stage" cssClass="error"/>
                </div>

                <div class="form-group">
                    <label for="location">Current Location *</label>
                    <form:input path="location" id="location" placeholder="e.g. Warehouse-A, Chennai"/>
                    <form:errors path="location" cssClass="error"/>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="temperature">Temperature (°C)</label>
                        <form:input path="temperature" id="temperature" type="number" step="0.1"
                            placeholder="e.g. 4.5" oninput="checkTemp(this.value)"/>
                        <div class="temp-warning" id="tempWarn">⚠ Value outside cold-chain range (0–8°C) will trigger an anomaly!</div>
                    </div>
                    <div class="form-group">
                        <label for="humidity">Humidity (%)</label>
                        <form:input path="humidity" id="humidity" type="number" step="0.1" placeholder="e.g. 60.0"/>
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Notes / Remarks</label>
                    <form:textarea path="notes" id="notes" rows="3" placeholder="Optional: inspection remarks, courier info, etc."/>
                </div>

                <button type="submit" class="btn-submit">🔗 Commit Stage to Blockchain →</button>
            </form:form>
        </div>
    </div>
    <script>
        function checkTemp(val) {
            const warn = document.getElementById('tempWarn');
            const num = parseFloat(val);
            warn.style.display = (!isNaN(num) && (num < 0 || num > 8)) ? 'block' : 'none';
        }
    </script>
</body>
</html>
