<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register Product — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 720px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 24px; }
        .back-link:hover { color: #a5b4fc; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px; }
        .card { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; padding: 32px; }
        .section-title { font-size: 13px; font-weight: 600; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { margin-bottom: 20px; }
        .form-group.full { grid-column: 1 / -1; }
        label { display: block; font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.7); margin-bottom: 8px; }
        input[type="text"], input[type="number"], select, textarea {
            width: 100%; padding: 11px 14px;
            background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px; color: #fff; font-size: 14px; font-family: 'Inter', sans-serif;
            transition: border-color 0.2s;
        }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #667eea; background: rgba(255,255,255,0.1); }
        select option { background: #1e1e3f; }
        textarea { resize: vertical; min-height: 80px; }
        .checkbox-group { display: flex; align-items: center; gap: 10px; padding: 12px 14px; background: rgba(255,255,255,0.05); border-radius: 10px; }
        .checkbox-group input[type="checkbox"] { width: 16px; height: 16px; accent-color: #667eea; }
        .checkbox-group label { margin: 0; font-size: 14px; color: rgba(255,255,255,0.8); cursor: pointer; }
        .error { color: #fca5a5; font-size: 12px; margin-top: 6px; }
        .btn-submit {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none; border-radius: 10px;
            color: #fff; font-size: 15px; font-weight: 600;
            cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 8px;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102,126,234,0.4); }
        .info-box { background: rgba(102,126,234,0.1); border: 1px solid rgba(102,126,234,0.2); border-radius: 10px; padding: 14px 16px; margin-bottom: 24px; font-size: 13px; color: rgba(255,255,255,0.6); line-height: 1.6; }
        .temp-range { display: none; }
        .temp-range.visible { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="page-title">Register New Product</div>
        <div class="page-subtitle">Add a new product batch to the consortium supply chain</div>

        <div class="info-box">
            ℹ️ Product registration creates both an <strong>off-chain MySQL record</strong> and an <strong>on-chain Ethereum transaction</strong>.
            A SHA-256 hash of the registration data will be committed to Sepolia testnet.
        </div>

        <div class="card">
            <form:form method="POST" action="/product/register" modelAttribute="productBean">
                <div class="section-title">Product Details</div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Product Name *</label>
                        <form:input path="name" id="name" placeholder="e.g. Insulin Glargine 100U/mL"/>
                        <form:errors path="name" cssClass="error"/>
                    </div>
                    <div class="form-group">
                        <label for="batchNumber">Batch Number *</label>
                        <form:input path="batchNumber" id="batchNumber" placeholder="e.g. BATCH-2026-A1"/>
                        <form:errors path="batchNumber" cssClass="error"/>
                    </div>
                    <div class="form-group">
                        <label for="category">Category *</label>
                        <form:select path="category" id="category">
                            <option value="">— Select Category —</option>
                            <option value="Pharmaceutical">Pharmaceutical</option>
                            <option value="Food & Beverage">Food & Beverage</option>
                            <option value="Electronics">Electronics</option>
                            <option value="Automotive">Automotive</option>
                            <option value="Textile">Textile</option>
                            <option value="Chemical">Chemical</option>
                        </form:select>
                        <form:errors path="category" cssClass="error"/>
                    </div>
                    <div class="form-group">
                        <label for="manufacturerName">Manufacturer Name *</label>
                        <form:input path="manufacturerName" id="manufacturerName" placeholder="e.g. VIT Pharma Ltd."/>
                        <form:errors path="manufacturerName" cssClass="error"/>
                    </div>
                    <div class="form-group full">
                        <label for="description">Description</label>
                        <form:textarea path="description" id="description" placeholder="Product description, specifications, regulatory info..."/>
                    </div>
                </div>

                <div class="section-title" style="margin-top:16px;">Origin & Cold Chain</div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="originLocation">Origin Location *</label>
                        <form:input path="originLocation" id="originLocation" placeholder="e.g. Factory 1, Vellore"/>
                        <form:errors path="originLocation" cssClass="error"/>
                    </div>
                    <div class="form-group">
                        <label>Perishable / Cold-Chain?</label>
                        <div class="checkbox-group">
                            <form:checkbox path="perishable" id="perishable" onclick="toggleTemp(this)"/>
                            <label for="perishable">This product requires temperature monitoring</label>
                        </div>
                    </div>
                </div>

                <div class="temp-range" id="tempRangeGroup">
                    <div class="form-group">
                        <label for="minTemperature">Min Temp (°C)</label>
                        <form:input path="minTemperature" id="minTemperature" type="number" placeholder="e.g. 2"/>
                    </div>
                    <div class="form-group">
                        <label for="maxTemperature">Max Temp (°C)</label>
                        <form:input path="maxTemperature" id="maxTemperature" type="number" placeholder="e.g. 8"/>
                    </div>
                </div>

                <button type="submit" class="btn-submit" id="submitBtn">⛓ Register on Blockchain →</button>
            </form:form>
        </div>
    </div>
    <script>
        function toggleTemp(cb) {
            const group = document.getElementById('tempRangeGroup');
            group.className = cb.checked ? 'temp-range visible' : 'temp-range';
        }
        // Show if perishable was already checked (form re-render on validation error)
        window.onload = () => {
            const cb = document.getElementById('perishable');
            if (cb && cb.checked) toggleTemp(cb);
        };
    </script>
</body>
</html>
