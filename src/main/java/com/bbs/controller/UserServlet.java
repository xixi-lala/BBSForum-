package com.bbs.controller;

import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器（简易版，组员B会替换为完整版）
 * 负责：登录、注册、退出
 */
@WebServlet(name = "user", urlPatterns = {"/user/login", "/user/register", "/logout"})
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/");
        } else if ("/user/login".equals(path)) {
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
        } else if ("/user/register".equals(path)) {
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/user/login".equals(path)) {
            handleLogin(request, response);
        } else if ("/user/register".equals(path)) {
            handleRegister(request, response);
        }
    }

    /** 登录 */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username, role, phone, job_type, job_location FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> user = new HashMap<>();
                    user.put("id", rs.getInt("id"));
                    user.put("username", rs.getString("username"));
                    user.put("role", rs.getString("role"));
                    user.put("phone", rs.getString("phone") == null ? "" : rs.getString("phone"));
                    user.put("jobType", rs.getString("job_type") == null ? "" : rs.getString("job_type"));
                    user.put("jobLocation", rs.getString("job_location") == null ? "" : rs.getString("job_location"));

                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);

                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("error", "用户名或密码错误");
        request.getRequestDispatcher("/user/login.jsp").forward(request, response);
    }

    /** 注册 */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");
        String phone = request.getParameter("phone");
        String jobType = request.getParameter("jobType");
        String jobLocation = request.getParameter("jobLocation");

        // 校验
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }
        if (!password.equals(password2)) {
            request.setAttribute("error", "两次输入的密码不一致");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        String sql = "INSERT INTO users (username, password, phone, job_type, job_location) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password.trim());
            ps.setString(3, phone == null ? "" : phone.trim());
            ps.setString(4, jobType == null ? "" : jobType.trim());
            ps.setString(5, jobLocation == null ? "" : jobLocation.trim());
            ps.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/user/login?registered=1");
            return;
        } catch (SQLException e) {
            if (e.getSQLState().equals("23000")) {
                request.setAttribute("error", "用户名已存在");
            } else {
                request.setAttribute("error", "注册失败，请重试");
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("/user/register.jsp").forward(request, response);
    }
}
