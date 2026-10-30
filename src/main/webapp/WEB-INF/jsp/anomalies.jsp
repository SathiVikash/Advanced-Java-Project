<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Anomaly Center — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }
        .container { max-width: 1000px; margin: 0 auto; padding: 40px 24px; }
        .back-link { color: #667eea; text-decoration: none; font-size: 13px; margin-bottom: 24px; display: inline-block; }
        .page-title { font-size: 26px; font-weight: 700; color: #fff; margin-bottom: 6px; }
        .page-subtitle { color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 32px; }
        .summary-bar { display: flex; gap: 16px; margin-bottom: 32px; flex-wrap: wrap; }
        .summary-chip {
            padding: 10px 20px; border-radius: 10px;
            font-size: 13px; font-weight: 600;
        }
        .summary-chip.total { background: rgba(102,126,234,0.15); color: #a5b4fc; }
        .summary-chip.critical { background: rgba(239,68,68,0.15); color: #fca5a5; }
        .anomaly-table {
            background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; overflow: hidden;
        }
        .anomaly-table table { width: 100%; border-collapse: collapse; }
        .anomaly-table th {
            padding: 14px 20px; text-align: left;
            font-size: 11px; font-weight: 600; color: rgba(255,255,255,0.4);
            text-transform: uppercase; letter-spacing: 0.8px;
            background: rgba(255,255,255,0.02); border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .anomaly-table td { padding: 16px 20px; border-bottom: 1px solid rgba(255,255,255,0.04); font-size: 13px; vertical-align: top; }
        .anomaly-table tr:last-child td { border-bottom: none; }
        .anomaly-table tr:hover td { background: rgba(255,255,255,0.02); }
        .badge { padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; white-space: nowrap; }
        .badge.CRITICAL { background: rgba(239,68,68,0.2); color: #fca5a5; }
        .badge.HIGH { background: rgba(245,158,11,0.2); color: #fcd34d; }
        .badge.MEDIUM { background: rgba(59,130,246,0.2); color: #93c5fd; }
        .badge.LOW { background: rgba(34,197,94,0.2); color: #86efac; }
        .type-badge { padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.7); white-space: nowrap; }
        .resolve-btn {
            padding: 6px 14px; border-radius: 6px;
            background: rgba(34,197,94,0.15); border: 1px solid rgba(34,197,94,0.3);
            color: #86efac; font-size: 12px; cursor: pointer;
            transition: background 0.2s; white-space: nowrap;
        }
        .resolve-btn:hover { background: rgba(34,197,94,0.25); }
        .product-link { color: #667eea; text-decoration: none; font-family: monospace; font-size: 12px; }
        .product-link:hover { text-decoration: underline; }
        .empty-state { padding: 60px 20px; text-align: center; }
        .desc-text { color: rgba(255,255,255,0.55); line-height: 1.5; max-width: 400px; }
    </style>
</head>
<body>
    <div class="container">
        <a href="/dashboard" class="back-link">← Back to Dashboard</a>
        <div class="page-title">⚠️ Anomaly Center</div>
        <div class="page-subtitle">Detected supply chain violations and integrity breaches</div>

        <div class="summary-bar">
            <div class="summary-chip total">📋 ${totalUnresolved} Open Anomalies</div>
            <div class="summary-chip critical">🚨 ${criticalCount} Critical</div>
        </div>

        <div class="anomaly-table">
            <table>
                <thead>
                    <tr>
                        <th>Severity</th>
                        <th>Type</th>
                        <th>Product</th>
                        <th>Description</th>
                        <th>Detected</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty anomalies}">
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state">
                                        <div style="font-size:48px;margin-bottom:16px;">✅</div>
                                        <h3 style="color:#fff;margin-bottom:8px;">All Clear!</h3>
                                        <p style="color:rgba(255,255,255,0.4);">No active anomalies detected in the supply chain.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="anomaly" items="${anomalies}">
                            <tr>
                                <td><span class="badge ${anomaly.severity}">${anomaly.severity}</span></td>
                                <td><span class="type-badge">${anomaly.anomalyType}</span></td>
                                <td>
                                    <a href="/track?productId=${anomaly.product.productId}" class="product-link">
                                        ${anomaly.product.productId}
                                    </a><br>
                                    <span style="font-size:12px;color:rgba(255,255,255,0.5);">${anomaly.product.name}</span>
                                </td>
                                <td class="desc-text">${anomaly.description}</td>
                                <td style="color:rgba(255,255,255,0.4);white-space:nowrap;">
                                    ${anomaly.formattedDetectedAt}
                                </td>
                                <td>
                                    <form method="POST" action="/anomalies/resolve/${anomaly.id}">
                                        <button type="submit" class="resolve-btn">✓ Resolve</button>
                                    </form>
                                </td>
                            </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
