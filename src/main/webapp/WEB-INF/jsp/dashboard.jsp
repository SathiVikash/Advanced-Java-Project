<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard — SupplyChain Traceability</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0d0d1a; color: #e2e8f0; min-height: 100vh; }

        /* SIDEBAR */
        .sidebar {
            position: fixed; left: 0; top: 0; bottom: 0; width: 240px;
            background: rgba(255,255,255,0.03); border-right: 1px solid rgba(255,255,255,0.08);
            padding: 24px 0; display: flex; flex-direction: column;
        }
        .sidebar-logo { padding: 0 24px 24px; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .sidebar-logo .icon { font-size: 28px; }
        .sidebar-logo h2 { font-size: 16px; font-weight: 700; color: #fff; margin-top: 8px; }
        .sidebar-logo p { font-size: 11px; color: rgba(255,255,255,0.4); }
        .nav-section { padding: 16px 16px 8px; font-size: 10px; font-weight: 600; color: rgba(255,255,255,0.3); text-transform: uppercase; letter-spacing: 1px; }
        .nav-item { display: flex; align-items: center; gap: 10px; padding: 10px 24px; color: rgba(255,255,255,0.6); font-size: 13px; text-decoration: none; transition: all 0.2s; border-left: 3px solid transparent; }
        .nav-item:hover, .nav-item.active { color: #fff; background: rgba(102,126,234,0.15); border-left-color: #667eea; }
        .nav-item .icon { font-size: 16px; }
        .sidebar-footer { margin-top: auto; padding: 16px 24px; border-top: 1px solid rgba(255,255,255,0.08); }
        .user-info { display: flex; align-items: center; gap: 12px; }
        .user-avatar { width: 36px; height: 36px; background: linear-gradient(135deg,#667eea,#764ba2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700; }
        .user-name { font-size: 13px; font-weight: 600; color: #fff; }
        .user-role { font-size: 11px; color: rgba(255,255,255,0.4); }

        /* MAIN */
        .main { margin-left: 240px; padding: 32px; }
        .page-header { margin-bottom: 32px; }
        .page-header h1 { font-size: 26px; font-weight: 700; color: #fff; }
        .page-header p { color: rgba(255,255,255,0.5); font-size: 14px; margin-top: 4px; }

        /* KPI CARDS */
        .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 32px; }
        .kpi-card {
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; padding: 24px; position: relative; overflow: hidden;
            transition: transform 0.2s;
        }
        .kpi-card:hover { transform: translateY(-3px); }
        .kpi-card::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
        }
        .kpi-card.blue::before { background: linear-gradient(90deg, #667eea, #764ba2); }
        .kpi-card.green::before { background: linear-gradient(90deg, #22c55e, #16a34a); }
        .kpi-card.orange::before { background: linear-gradient(90deg, #f59e0b, #d97706); }
        .kpi-card.red::before { background: linear-gradient(90deg, #ef4444, #dc2626); }
        .kpi-label { font-size: 12px; color: rgba(255,255,255,0.5); font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-value { font-size: 36px; font-weight: 700; color: #fff; margin: 8px 0 4px; }
        .kpi-icon { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); font-size: 36px; opacity: 0.15; }

        /* SECTIONS */
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .section-card {
            background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; overflow: hidden;
        }
        .section-header { padding: 20px 24px; border-bottom: 1px solid rgba(255,255,255,0.06); display: flex; justify-content: space-between; align-items: center; }
        .section-header h3 { font-size: 15px; font-weight: 600; color: #fff; }
        .section-header a { font-size: 12px; color: #667eea; text-decoration: none; }

        /* ANOMALY LIST */
        .anomaly-item { padding: 16px 24px; border-bottom: 1px solid rgba(255,255,255,0.04); display: flex; align-items: flex-start; gap: 12px; }
        .anomaly-item:last-child { border-bottom: none; }
        .badge { padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .badge.CRITICAL { background: rgba(239,68,68,0.2); color: #fca5a5; }
        .badge.HIGH { background: rgba(245,158,11,0.2); color: #fcd34d; }
        .badge.MEDIUM { background: rgba(59,130,246,0.2); color: #93c5fd; }
        .badge.LOW { background: rgba(34,197,94,0.2); color: #86efac; }
        .anomaly-type { font-size: 13px; font-weight: 600; color: #fff; margin-bottom: 4px; }
        .anomaly-desc { font-size: 12px; color: rgba(255,255,255,0.45); line-height: 1.5; }

        /* PRODUCT LIST */
        .product-item { padding: 14px 24px; border-bottom: 1px solid rgba(255,255,255,0.04); display: flex; align-items: center; justify-content: space-between; }
        .product-item:last-child { border-bottom: none; }
        .product-name { font-size: 13px; font-weight: 600; color: #fff; }
        .product-id { font-size: 11px; color: rgba(255,255,255,0.4); font-family: monospace; }
        .stage-badge { padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; background: rgba(102,126,234,0.2); color: #a5b4fc; }
        .empty-state { padding: 40px 24px; text-align: center; color: rgba(255,255,255,0.3); font-size: 13px; }

        /* ALERT BANNERS */
        .alert { padding: 12px 20px; border-radius: 10px; font-size: 13px; margin-bottom: 20px; }
        .alert.success { background: rgba(34,197,94,0.15); border: 1px solid rgba(34,197,94,0.3); color: #86efac; }
        .alert.error { background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3); color: #fca5a5; }

        .btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 500; text-decoration: none; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-primary { background: linear-gradient(135deg,#667eea,#764ba2); color: #fff; }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 15px rgba(102,126,234,0.4); }
    </style>
</head>
<body>
    <!-- SIDEBAR -->
    <nav class="sidebar">
        <div class="sidebar-logo">
            <div class="icon">⛓</div>
            <h2>SupplyChain Trace</h2>
            <p>Blockchain Consortium Portal</p>
        </div>

        <div class="nav-section">Navigation</div>
        <a href="/dashboard" class="nav-item active"><span class="icon">📊</span> Dashboard</a>
        <a href="/product/list" class="nav-item"><span class="icon">📦</span> Products</a>
        <a href="/track" class="nav-item"><span class="icon">🔍</span> Track Product</a>

        <sec:authorize access="hasRole('MANUFACTURER')">
            <div class="nav-section">Manufacturer</div>
            <a href="/product/register" class="nav-item"><span class="icon">➕</span> Register Product</a>
        </sec:authorize>

        <sec:authorize access="hasAnyRole('DISTRIBUTOR','WAREHOUSE','RETAILER','MANUFACTURER')">
            <div class="nav-section">Operations</div>
            <a href="/product/update-stage" class="nav-item"><span class="icon">🔄</span> Update Stage</a>
        </sec:authorize>

        <sec:authorize access="hasRole('AUDITOR')">
            <div class="nav-section">Auditor</div>
            <a href="/anomalies" class="nav-item"><span class="icon">⚠️</span> Anomaly Center</a>
        </sec:authorize>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar"><sec:authentication property="name" var="uname"/>${uname.substring(0,1).toUpperCase()}</div>
                <div>
                    <div class="user-name"><sec:authentication property="name"/></div>
                    <div class="user-role"><sec:authentication property="authorities"/></div>
                </div>
            </div>
            <a href="/logout" style="display:block;margin-top:12px;font-size:12px;color:rgba(255,255,255,0.4);text-decoration:none;">→ Sign Out</a>
        </div>
    </nav>

    <!-- MAIN CONTENT -->
    <main class="main">
        <div class="page-header">
            <h1>Dashboard</h1>
            <p>Real-time supply chain overview and anomaly monitoring</p>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert success">✓ ${successMsg}</div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert error">✗ ${errorMsg}</div>
        </c:if>

        <!-- KPI CARDS -->
        <div class="kpi-grid">
            <div class="kpi-card blue">
                <div class="kpi-label">Total Products</div>
                <div class="kpi-value">${totalProducts}</div>
                <div class="kpi-icon">📦</div>
            </div>
            <div class="kpi-card green">
                <div class="kpi-label">Chain Events</div>
                <div class="kpi-value">${totalEvents}</div>
                <div class="kpi-icon">⛓</div>
            </div>
            <div class="kpi-card orange">
                <div class="kpi-label">Open Anomalies</div>
                <div class="kpi-value">${unresolvedAnomalies}</div>
                <div class="kpi-icon">⚠️</div>
            </div>
            <div class="kpi-card red">
                <div class="kpi-label">Critical Alerts</div>
                <div class="kpi-value">${criticalAnomalies}</div>
                <div class="kpi-icon">🚨</div>
            </div>
        </div>

        <!-- BOTTOM GRID -->
        <div class="grid-2">
            <!-- RECENT ANOMALIES -->
            <div class="section-card">
                <div class="section-header">
                    <h3>⚠️ Recent Anomalies</h3>
                    <a href="/anomalies">View All →</a>
                </div>
                <c:choose>
                    <c:when test="${empty recentAnomalies}">
                        <div class="empty-state">✓ No active anomalies detected</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="anomaly" items="${recentAnomalies}">
                        <div class="anomaly-item">
                            <span class="badge ${anomaly.severity}">${anomaly.severity}</span>
                            <div>
                                <div class="anomaly-type">${anomaly.anomalyType}</div>
                                <div class="anomaly-desc">${anomaly.description.length() > 100 ? anomaly.description.substring(0, 100).concat('...') : anomaly.description}</div>
                            </div>
                        </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- RECENT PRODUCTS -->
            <div class="section-card">
                <div class="section-header">
                    <h3>📦 Recent Products</h3>
                    <a href="/product/list">View All →</a>
                </div>
                <c:choose>
                    <c:when test="${empty recentProducts}">
                        <div class="empty-state">No products registered yet</div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="prod" items="${recentProducts}">
                        <div class="product-item">
                            <div>
                                <div class="product-name">${prod.name}</div>
                                <div class="product-id">${prod.productId}</div>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <span class="stage-badge">${prod.currentStage}</span>
                                <a href="/track?productId=${prod.productId}" style="font-size:12px;color:#667eea;text-decoration:none;">Track →</a>
                            </div>
                        </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</body>
</html>
