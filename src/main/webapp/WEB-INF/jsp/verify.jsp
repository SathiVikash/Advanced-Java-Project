<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Verify Integrity — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 760px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; margin-bottom: 24px; display: inline-block; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px; }

        /* SEARCH */
        .search-bar { display: flex; gap: 12px; margin-bottom: 32px; }
        .search-bar input {
            flex: 1; padding: 13px 16px;
            background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px; color: #fff; font-size: 14px; font-family: 'Inter', sans-serif;
        }
        .search-bar input:focus { outline: none; border-color: #22c55e; }
        .search-bar button {
            padding: 13px 24px;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            border: none; border-radius: 10px; color: #fff;
            font-size: 14px; font-weight: 600; cursor: pointer;
        }

        /* RESULT CARD */
        .result-card {
            border-radius: 16px; padding: 32px; margin-bottom: 24px;
            border-width: 1px; border-style: solid;
        }
        .result-card.verified { background: rgba(34,197,94,0.08); border-color: rgba(34,197,94,0.3); }
        .result-card.tampered { background: rgba(239,68,68,0.08); border-color: rgba(239,68,68,0.3); }
        .result-card.pending { background: rgba(245,158,11,0.08); border-color: rgba(245,158,11,0.3); }
        .result-card.error { background: rgba(156,163,175,0.08); border-color: rgba(156,163,175,0.3); }
        .result-icon { font-size: 48px; margin-bottom: 16px; }
        .result-message { font-size: 18px; font-weight: 700; margin-bottom: 12px; }
        .result-card.verified .result-message { color: #86efac; }
        .result-card.tampered .result-message { color: #fca5a5; }
        .result-card.pending .result-message { color: #fcd34d; }
        .result-stats { display: flex; gap: 24px; margin-top: 20px; flex-wrap: wrap; }
        .stat { text-align: center; }
        .stat-value { font-size: 28px; font-weight: 700; color: #fff; }
        .stat-label { font-size: 12px; color: rgba(255,255,255,0.5); margin-top: 4px; }

        /* EVENT LIST */
        .event-card {
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 12px; padding: 16px 20px; margin-bottom: 12px;
            display: flex; justify-content: space-between; align-items: flex-start;
        }
        .event-card.tampered { border-color: rgba(239,68,68,0.4); background: rgba(239,68,68,0.05); }
        .event-card.verified { border-color: rgba(34,197,94,0.2); }
        .event-stage { font-size: 14px; font-weight: 600; color: #fff; margin-bottom: 6px; }
        .event-hash { font-family: monospace; font-size: 11px; color: rgba(255,255,255,0.35); word-break: break-all; }
        .badge { padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .badge.VERIFIED { background: rgba(34,197,94,0.2); color: #86efac; }
        .badge.TAMPERED { background: rgba(239,68,68,0.2); color: #fca5a5; }
        .badge.PENDING { background: rgba(245,158,11,0.2); color: #fcd34d; }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="page-title">🔐 Integrity Verification</div>
        <div class="page-subtitle">Verify that off-chain MySQL records match the Ethereum blockchain</div>

        <form method="GET" action="/verify">
            <div class="search-bar">
                <input type="text" name="productId" placeholder="Enter Product ID to verify"
                    value="${not empty verificationResult ? verificationResult.productId : ''}">
                <button type="submit">🔐 Verify Now</button>
            </div>
        </form>

        <c:if test="${not empty errorMsg}">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.3);border-radius:12px;padding:20px;color:#fca5a5;">
                ${errorMsg}
            </div>
        </c:if>

        <c:if test="${not empty verificationResult}">
            <!-- RESULT CARD -->
            <div class="result-card ${verificationResult.resultClass}">
                <div class="result-icon">
                    <c:choose>
                        <c:when test="${verificationResult.resultClass == 'verified'}">✅</c:when>
                        <c:when test="${verificationResult.resultClass == 'tampered'}">🚨</c:when>
                        <c:otherwise>⏳</c:otherwise>
                    </c:choose>
                </div>
                <div class="result-message">${verificationResult.resultMessage}</div>
                <div style="color:rgba(255,255,255,0.6);font-size:13px;">
                    Product: <strong style="color:#fff;">${verificationResult.productName}</strong>
                    (${verificationResult.productId})
                </div>
                <div class="result-stats">
                    <div class="stat">
                        <div class="stat-value">${verificationResult.totalEvents}</div>
                        <div class="stat-label">Total Events</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color:#86efac;">${verificationResult.verifiedEvents}</div>
                        <div class="stat-label">Verified</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color:#fca5a5;">${verificationResult.tamperedEvents}</div>
                        <div class="stat-label">Tampered</div>
                    </div>
                </div>
            </div>

            <!-- EVENT INTEGRITY LIST -->
            <h3 style="font-size:15px;font-weight:600;color:#fff;margin-bottom:16px;">Event Integrity Details</h3>
            <c:forEach var="event" items="${history}">
            <div class="event-card ${event.integrityStatus == 'TAMPERED' ? 'tampered' : event.integrityStatus == 'VERIFIED' ? 'verified' : ''}">
                <div style="flex:1;">
                    <div class="event-stage">${event.stage}</div>
                    <div style="font-size:12px;color:rgba(255,255,255,0.4);margin-bottom:8px;">
                        📍 ${event.location} | 👤 ${event.actorName}
                    </div>
                    <div class="event-hash">SHA-256: ${event.sha256Hash}</div>
                </div>
                <span class="badge ${event.integrityStatus}">${event.integrityStatus}</span>
            </div>
            </c:forEach>
        </c:if>
    </div>
</body>
</html>
