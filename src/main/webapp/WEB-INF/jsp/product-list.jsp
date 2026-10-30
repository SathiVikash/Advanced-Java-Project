<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Products — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 1100px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; margin-bottom: 24px; display: inline-block; }
        .back-link:hover { text-decoration: underline; }
        .header-row { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 32px; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-top: 4px; }
        .btn-register {
            padding: 10px 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 10px; color: #fff; text-decoration: none;
            font-size: 13px; font-weight: 600;
            transition: transform 0.2s;
        }
        .btn-register:hover { transform: translateY(-1px); }
        .products-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
        .product-card {
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; padding: 24px;
            transition: transform 0.2s, border-color 0.2s;
        }
        .product-card:hover { transform: translateY(-3px); border-color: rgba(102,126,234,0.3); }
        .product-card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 14px; }
        .product-name { font-size: 15px; font-weight: 700; color: #fff; margin-bottom: 4px; }
        .product-id { font-family: monospace; font-size: 11px; color: rgba(255,255,255,0.35); }
        .stage-pill { padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 600; background: rgba(102,126,234,0.2); color: #a5b4fc; white-space: nowrap; }
        .product-info { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
        .info-row { display: flex; justify-content: space-between; font-size: 12px; }
        .info-label { color: rgba(255,255,255,0.4); }
        .info-value { color: rgba(255,255,255,0.8); font-weight: 500; }
        .cold-badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; background: rgba(59,130,246,0.2); color: #93c5fd; }
        .card-actions { display: flex; gap: 10px; }
        .action-btn { flex: 1; padding: 8px; border-radius: 8px; font-size: 12px; font-weight: 500; text-align: center; text-decoration: none; cursor: pointer; border: none; transition: background 0.2s; }
        .btn-track { background: rgba(102,126,234,0.15); color: #a5b4fc; }
        .btn-track:hover { background: rgba(102,126,234,0.25); }
        .btn-verify { background: rgba(34,197,94,0.15); color: #86efac; }
        .btn-verify:hover { background: rgba(34,197,94,0.25); }
        .btn-update { background: rgba(245,158,11,0.15); color: #fcd34d; }
        .btn-update:hover { background: rgba(245,158,11,0.25); }
        .empty-state { text-align: center; padding: 60px 20px; background: rgba(255,255,255,0.03); border-radius: 16px; }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="header-row">
            <div>
                <div class="page-title">📦 Product Catalog</div>
                <div class="page-subtitle">${products.size()} products registered in the consortium</div>
            </div>
            <sec:authorize access="hasRole('MANUFACTURER')">
                <a href="/product/register" class="btn-register">+ Register Product</a>
            </sec:authorize>
        </div>

        <c:choose>
            <c:when test="${empty products}">
                <div class="empty-state">
                    <div style="font-size:48px;margin-bottom:16px;">📦</div>
                    <h3 style="color:#fff;margin-bottom:8px;">No Products Yet</h3>
                    <p style="color:rgba(255,255,255,0.4);margin-bottom:20px;">Register the first product batch to get started.</p>
                    <a href="/product/register" style="color:#667eea;text-decoration:none;">Register Product →</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="products-grid">
                    <c:forEach var="product" items="${products}">
                    <div class="product-card">
                        <div class="product-card-header">
                            <div>
                                <div class="product-name">${product.name}</div>
                                <div class="product-id">${product.productId}</div>
                            </div>
                            <span class="stage-pill">${product.currentStage}</span>
                        </div>
                        <div class="product-info">
                            <div class="info-row">
                                <span class="info-label">Batch</span>
                                <span class="info-value">${product.batchNumber}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Category</span>
                                <span class="info-value">${product.category}</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Manufacturer</span>
                                <span class="info-value">${product.manufacturerName}</span>
                            </div>
                            <c:if test="${product.perishable}">
                            <div class="info-row">
                                <span class="info-label">Cold Chain</span>
                                <span class="cold-badge">❄ ${product.minTemperature}°C–${product.maxTemperature}°C</span>
                            </div>
                            </c:if>
                        </div>
                        <div class="card-actions">
                            <a href="/track?productId=${product.productId}" class="action-btn btn-track">🔍 Track</a>
                            <a href="/verify?productId=${product.productId}" class="action-btn btn-verify">🔐 Verify</a>
                            <a href="/product/update-stage?productId=${product.productId}" class="action-btn btn-update">🔄 Update</a>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
