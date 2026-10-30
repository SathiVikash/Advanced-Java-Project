<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Track Product — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 800px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; margin-bottom: 24px; display: inline-block; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px; }
        .search-bar { display: flex; gap: 12px; margin-bottom: 32px; }
        .search-bar input {
            flex: 1; padding: 13px 16px;
            background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px; color: #fff; font-size: 14px; font-family: 'Inter', sans-serif;
        }
        .search-bar input:focus { outline: none; border-color: #667eea; }
        .search-bar button {
            padding: 13px 24px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none; border-radius: 10px; color: #fff;
            font-size: 14px; font-weight: 600; cursor: pointer;
            transition: transform 0.2s;
        }
        .search-bar button:hover { transform: translateY(-1px); }

        /* PRODUCT HEADER */
        .product-header {
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; padding: 24px; margin-bottom: 24px;
            display: flex; justify-content: space-between; align-items: flex-start;
        }
        .product-header h2 { font-size: 20px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .product-meta { display: flex; gap: 16px; flex-wrap: wrap; margin-top: 10px; }
        .meta-chip { background: rgba(255,255,255,0.07); border-radius: 6px; padding: 4px 10px; font-size: 12px; color: rgba(255,255,255,0.6); }
        .meta-chip strong { color: #fff; }
        .current-stage-badge {
            padding: 8px 16px; border-radius: 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff; font-size: 13px; font-weight: 600;
        }
        .verify-btn {
            display: inline-block; margin-top: 12px; padding: 8px 16px;
            background: rgba(34,197,94,0.15); border: 1px solid rgba(34,197,94,0.3);
            border-radius: 8px; color: #86efac; font-size: 13px;
            text-decoration: none; transition: background 0.2s;
        }
        .verify-btn:hover { background: rgba(34,197,94,0.25); }

        /* TIMELINE */
        .timeline { position: relative; padding-left: 32px; }
        .timeline::before { content: ''; position: absolute; left: 12px; top: 0; bottom: 0; width: 2px; background: rgba(255,255,255,0.08); }
        .timeline-item { position: relative; margin-bottom: 24px; }
        .timeline-dot {
            position: absolute; left: -26px; top: 16px;
            width: 14px; height: 14px; border-radius: 50%;
            background: #667eea; border: 3px solid #0d0d1a;
            box-shadow: 0 0 0 2px #667eea;
        }
        .timeline-dot.tampered { background: #ef4444; box-shadow: 0 0 0 2px #ef4444; }
        .timeline-dot.verified { background: #22c55e; box-shadow: 0 0 0 2px #22c55e; }
        .event-card {
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 12px; padding: 20px;
            transition: border-color 0.2s;
        }
        .event-card:hover { border-color: rgba(102,126,234,0.3); }
        .event-card.tampered { border-color: rgba(239,68,68,0.4); background: rgba(239,68,68,0.05); }
        .event-card.verified { border-color: rgba(34,197,94,0.2); }
        .event-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
        .event-stage { font-size: 14px; font-weight: 700; color: #fff; }
        .event-time { font-size: 12px; color: rgba(255,255,255,0.4); }
        .event-details { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        .event-detail { font-size: 12px; color: rgba(255,255,255,0.5); }
        .event-detail strong { color: rgba(255,255,255,0.8); }
        .hash-row { margin-top: 12px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.06); }
        .hash-value { font-family: monospace; font-size: 11px; color: #667eea; word-break: break-all; }
        .integrity-badge { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .integrity-badge.VERIFIED { background: rgba(34,197,94,0.2); color: #86efac; }
        .integrity-badge.TAMPERED { background: rgba(239,68,68,0.2); color: #fca5a5; }
        .integrity-badge.PENDING { background: rgba(245,158,11,0.2); color: #fcd34d; }
        .tx-link { color: #a5b4fc; font-size: 11px; text-decoration: none; font-family: monospace; }
        .tx-link:hover { text-decoration: underline; }
        .not-found { text-align: center; padding: 60px 20px; background: rgba(255,255,255,0.03); border-radius: 16px; color: rgba(255,255,255,0.4); }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="page-title">🔍 Track Product</div>
        <div class="page-subtitle">Enter a product ID to view its full supply chain history</div>

        <form method="GET" action="/track">
            <div class="search-bar">
                <input type="text" name="productId" placeholder="Enter Product ID (e.g. PROD-3F7A9B2C)"
                    value="${not empty productId ? productId : ''}">
                <button type="submit">Track →</button>
            </div>
        </form>

        <c:if test="${notFound}">
            <div class="not-found">
                <div style="font-size:48px;margin-bottom:16px;">🔍</div>
                <h3 style="color:#fff;margin-bottom:8px;">Product Not Found</h3>
                <p>No product found with ID "<strong style="color:#fff">${productId}</strong>". Please check and try again.</p>
            </div>
        </c:if>

        <c:if test="${not empty product}">
            <!-- PRODUCT HEADER -->
            <div class="product-header">
                <div>
                    <h2>${product.name}</h2>
                    <div style="color:rgba(255,255,255,0.4);font-size:13px;font-family:monospace;">${product.productId}</div>
                    <div class="product-meta">
                        <div class="meta-chip"><strong>Batch:</strong> ${product.batchNumber}</div>
                        <div class="meta-chip"><strong>Category:</strong> ${product.category}</div>
                        <div class="meta-chip"><strong>Manufacturer:</strong> ${product.manufacturerName}</div>
                        <c:if test="${product.perishable}">
                            <div class="meta-chip" style="color:#fcd34d;"><strong>❄ Cold Chain:</strong> ${product.minTemperature}°C – ${product.maxTemperature}°C</div>
                        </c:if>
                    </div>
                    <a href="/verify?productId=${product.productId}" class="verify-btn">🔐 Verify Blockchain Integrity</a>
                </div>
                <div>
                    <div class="current-stage-badge">${product.currentStage}</div>
                </div>
            </div>

            <!-- TIMELINE -->
            <div class="timeline">
                <c:forEach var="event" items="${history}">
                    <div class="timeline-item">
                        <div class="timeline-dot ${event.integrityStatus == 'TAMPERED' ? 'tampered' : event.integrityStatus == 'VERIFIED' ? 'verified' : ''}"></div>
                        <div class="event-card ${event.integrityStatus == 'TAMPERED' ? 'tampered' : event.integrityStatus == 'VERIFIED' ? 'verified' : ''}">
                            <div class="event-header">
                                <div class="event-stage">${event.stage}</div>
                                <div style="display:flex;align-items:center;gap:10px;">
                                    <span class="integrity-badge ${event.integrityStatus}">${event.integrityStatus}</span>
                                    <span class="event-time">${event.formattedEventTime}</span>
                                </div>
                            </div>
                            <div class="event-details">
                                <div class="event-detail">📍 <strong>Location:</strong> ${event.location}</div>
                                <div class="event-detail">👤 <strong>Actor:</strong> ${event.actorName} (${event.actorRole})</div>
                                <c:if test="${not empty event.temperature}">
                                    <div class="event-detail" style="${event.temperature > 8 || event.temperature < 0 ? 'color:#fca5a5' : ''}">
                                        🌡 <strong>Temp:</strong> ${event.temperature}°C
                                        <c:if test="${event.temperature > 8 || event.temperature < 0}"> ⚠️</c:if>
                                    </div>
                                </c:if>
                                <c:if test="${not empty event.humidity}">
                                    <div class="event-detail">💧 <strong>Humidity:</strong> ${event.humidity}%</div>
                                </c:if>
                                <c:if test="${not empty event.notes}">
                                    <div class="event-detail" style="grid-column:1/-1;">📝 <strong>Notes:</strong> ${event.notes}</div>
                                </c:if>
                            </div>
                            <div class="hash-row">
                                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:16px;flex-wrap:wrap;">
                                    <div style="flex:1;">
                                        <div style="font-size:11px;color:rgba(255,255,255,0.3);margin-bottom:4px;">SHA-256 HASH (Off-chain record digest)</div>
                                        <div class="hash-value">${event.sha256Hash}</div>
                                    </div>
                                    <c:if test="${not empty event.blockchainTxHash}">
                                        <div>
                                            <div style="font-size:11px;color:rgba(255,255,255,0.3);margin-bottom:4px;">ETHEREUM TX</div>
                                            <a href="https://sepolia.etherscan.io/tx/${event.blockchainTxHash}" target="_blank" class="tx-link">
                                                ${event.shortTxHash} ↗
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
    </div>
</body>
</html>
