<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — SupplyChain Traceability</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            display: flex; align-items: center; justify-content: center;
        }
        .login-card {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 48px 40px;
            width: 100%; max-width: 420px;
            box-shadow: 0 25px 60px rgba(0,0,0,0.5);
        }
        .logo { text-align: center; margin-bottom: 32px; }
        .logo-icon {
            width: 60px; height: 60px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 16px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 28px; margin-bottom: 16px;
        }
        .logo h1 { color: #fff; font-size: 22px; font-weight: 700; }
        .logo p { color: rgba(255,255,255,0.5); font-size: 13px; margin-top: 4px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; color: rgba(255,255,255,0.7); font-size: 13px; font-weight: 500; margin-bottom: 8px; }
        input[type="text"], input[type="password"] {
            width: 100%; padding: 12px 16px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 10px; color: #fff;
            font-size: 14px; font-family: 'Inter', sans-serif;
            transition: border-color 0.3s;
        }
        input:focus { outline: none; border-color: #667eea; background: rgba(255,255,255,0.12); }
        .btn-login {
            width: 100%; padding: 13px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none; border-radius: 10px;
            color: #fff; font-size: 15px; font-weight: 600;
            cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 8px;
        }
        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102,126,234,0.5); }
        .alert-error {
            background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3);
            border-radius: 10px; padding: 12px 16px;
            color: #fca5a5; font-size: 13px; margin-bottom: 20px;
        }
        .credentials-hint {
            margin-top: 24px; padding: 16px;
            background: rgba(102,126,234,0.1); border: 1px solid rgba(102,126,234,0.2);
            border-radius: 10px;
        }
        .credentials-hint p { color: rgba(255,255,255,0.6); font-size: 12px; line-height: 1.8; }
        .credentials-hint strong { color: #a5b4fc; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="logo">
            <div class="logo-icon">⛓</div>
            <h1>SupplyChain Trace</h1>
            <p>Blockchain-Powered Consortium Portal</p>
        </div>

        <% if (request.getParameter("error") != null) { %>
        <div class="alert-error">Invalid username or password. Please try again.</div>
        <% } %>
        <% if (request.getParameter("logout") != null) { %>
        <div style="background:rgba(34,197,94,0.15);border:1px solid rgba(34,197,94,0.3);border-radius:10px;padding:12px 16px;color:#86efac;font-size:13px;margin-bottom:20px;">
            You have been logged out successfully.
        </div>
        <% } %>

        <form method="POST" action="/login">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="e.g. manufacturer1" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="••••••••••" required>
            </div>
            <button type="submit" class="btn-login">Sign In to Consortium →</button>
        </form>

        <div class="credentials-hint">
            <p><strong>Demo Accounts (password: password123)</strong><br>
            manufacturer1 · distributor1 · warehouse1<br>
            retailer1 · auditor1 · consumer1</p>
        </div>
    </div>
</body>
</html>
