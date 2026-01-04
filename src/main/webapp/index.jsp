<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.itkannadigaru.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String username = user != null ? user.getUsername() : "Guest";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ITKANNADIGARU</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 60px 40px;
            text-align: center;
            max-width: 600px;
            width: 100%;
            animation: fadeIn 1s ease-in;
            position: relative;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .user-info {
            position: absolute;
            top: 20px;
            right: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .welcome-text {
            color: #555;
            font-size: 0.95em;
            font-weight: 600;
        }

        .username {
            color: #667eea;
            font-weight: bold;
        }

        .logout-btn {
            background: #f44336;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .logout-btn:hover {
            background: #d32f2f;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
        }

        h1 {
            color: #333;
            font-size: 3em;
            margin-bottom: 30px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
            animation: slideDown 0.8s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .youtube-section {
            margin-top: 40px;
        }

        .youtube-label {
            font-size: 1.2em;
            color: #555;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .youtube-link {
            display: inline-block;
            background: linear-gradient(135deg, #FF0000 0%, #CC0000 100%);
            color: white;
            text-decoration: none;
            padding: 15px 30px;
            border-radius: 50px;
            font-size: 1.1em;
            font-weight: bold;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 0, 0, 0.3);
        }

        .youtube-link:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(255, 0, 0, 0.4);
            background: linear-gradient(135deg, #CC0000 0%, #990000 100%);
        }

        .youtube-icon {
            margin-right: 10px;
            font-size: 1.3em;
        }

        .divider {
            width: 100px;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 30px auto;
            border-radius: 2px;
        }

        @media (max-width: 600px) {
            h1 {
                font-size: 2em;
            }

            .container {
                padding: 40px 20px;
            }

            .user-info {
                position: static;
                justify-content: center;
                margin-bottom: 20px;
                flex-wrap: wrap;
            }

            .youtube-link {
                padding: 12px 24px;
                font-size: 1em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="user-info">
            <span class="welcome-text">Welcome, <span class="username"><%= username %></span></span>
            <a href="<%= request.getContextPath() %>/logout" class="logout-btn">Logout</a>
        </div>

        <h1>ITKANNADIGARU</h1>

        <div class="divider"></div>

        <div class="youtube-section">
            <div class="youtube-label">Visit Our YouTube Channel</div>
            <a href="https://www.youtube.com/@Manojdevops-z7s"
               class="youtube-link"
               target="_blank"
               rel="noopener noreferrer">
                <span class="youtube-icon">▶</span>
                Manojdevops-z7s
            </a>
        </div>
    </div>
</body>
</html>
