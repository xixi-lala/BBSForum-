package com.bbs.controller;

import com.bbs.util.ContentUtil;
import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页入口控制器
 * 负责：加载板块列表、加载帖子列表，转发到 index.jsp
 */
@WebServlet(name = "home", urlPatterns = {"/index", "/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 首次访问时加载板块列表到 session（全局共享）
        if (request.getSession().getAttribute("categoryList") == null) {
            loadCategories(request);
        }

        // 2. 加载帖子列表（分板块展示）
        loadPosts(request);

        // 3. 转发到首页模板（/WEB-INF下受保护，只能通过Servlet访问）
        request.getRequestDispatcher("/WEB-INF/home.jsp").forward(request, response);
    }

    /** 加载板块列表 */
    private void loadCategories(HttpServletRequest request) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, name, description, sort_order, created_at FROM categories ORDER BY sort_order";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> cat = new HashMap<>();
                cat.put("id", rs.getInt("id"));
                cat.put("name", rs.getString("name"));
                cat.put("description", rs.getString("description"));
                cat.put("sortOrder", rs.getInt("sort_order"));
                cat.put("createdAt", rs.getTimestamp("created_at").toString());
                list.add(cat);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        request.getSession().setAttribute("categoryList", list);
    }

    /** 加载帖子列表 */
    private void loadPosts(HttpServletRequest request) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.title, p.content, p.image_url, " +
                     "p.is_top, p.is_elite, p.view_count, p.created_at, " +
                     "u.username AS author_name, c.name AS category_name " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "JOIN categories c ON p.category_id = c.id " +
                     "ORDER BY p.is_top DESC, p.is_elite DESC, p.created_at DESC " +
                     "LIMIT 20";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> post = new HashMap<>();
                post.put("id", rs.getInt("id"));
                post.put("title", rs.getString("title"));
                String rawContent = rs.getString("content") == null ? "" : rs.getString("content");
                post.put("summary", ContentUtil.summary(rawContent, 120));
                post.put("isTop", rs.getInt("is_top"));
                post.put("isElite", rs.getInt("is_elite"));
                post.put("viewCount", rs.getInt("view_count"));
                post.put("createdAt", rs.getTimestamp("created_at").toString());
                post.put("authorName", rs.getString("author_name"));
                post.put("categoryName", rs.getString("category_name"));
                post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                list.add(post);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        request.setAttribute("postList", list);
    }
}
