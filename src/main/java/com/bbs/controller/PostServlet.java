package com.bbs.controller;

import com.bbs.util.AiUtil;
import com.bbs.util.ContentUtil;
import com.bbs.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 帖子控制器
 * 负责：查看帖子详情、发布帖子、回复帖子（支持本地上传封面图）
 */
@WebServlet(name = "post", urlPatterns = {"/post/create", "/post/detail", "/post/reply", "/post/edit", "/post/delete", "/post/uploadImage", "/post/aiSummary"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, location = "")  // 最大5MB
public class PostServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/post/create".equals(path)) {
            handleCreateForm(request, response);
        } else if ("/post/detail".equals(path)) {
            handleDetail(request, response);
        } else if ("/post/edit".equals(path)) {
            handleEditForm(request, response);
        } else if ("/post/delete".equals(path)) {
            handleDelete(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/post/create".equals(path)) {
            handleCreatePost(request, response);
        } else if ("/post/reply".equals(path)) {
            handleReply(request, response);
        } else if ("/post/edit".equals(path)) {
            handleEditPost(request, response);
        } else if ("/post/uploadImage".equals(path)) {
            handleInlineImageUpload(request, response);
        } else if ("/post/aiSummary".equals(path)) {
            handleAiSummary(request, response);
        }
    }

    /** 显示发帖表单（需登录） */
    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }
        request.getRequestDispatcher("/post/create.jsp").forward(request, response);
    }

    /** 查看帖子详情（任何人可看） */
    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        int postId;
        try {
            postId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 1. 浏览量+1
        String updateSql = "UPDATE posts SET view_count = view_count + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. 查询帖子
        String postSql = "SELECT p.id, p.title, p.content, p.image_url, p.ai_summary, p.is_top, p.is_elite, " +
                         "p.view_count, p.user_id, p.category_id, p.created_at, p.updated_at, " +
                         "u.username AS author_name, c.name AS category_name " +
                         "FROM posts p " +
                         "JOIN users u ON p.user_id = u.id " +
                         "JOIN categories c ON p.category_id = c.id " +
                         "WHERE p.id = ?";
        Map<String, Object> post = null;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(postSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                    post.put("aiSummary", rs.getString("ai_summary") == null ? "" : rs.getString("ai_summary"));
                    post.put("isTop", rs.getInt("is_top"));
                    post.put("isElite", rs.getInt("is_elite"));
                    post.put("viewCount", rs.getInt("view_count"));
                    post.put("userId", rs.getInt("user_id"));
                    post.put("categoryId", rs.getInt("category_id"));
                    post.put("createdAt", rs.getTimestamp("created_at").toString());
                    post.put("authorName", rs.getString("author_name"));
                    post.put("categoryName", rs.getString("category_name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        // 渲染内容（Markdown图片语法 → HTML）
        post.put("contentRendered", ContentUtil.render((String) post.get("content")));
        request.setAttribute("post", post);

        // 3. 查询回复列表
        List<Map<String, Object>> replyList = new ArrayList<>();
        String replySql = "SELECT r.id, r.content, r.created_at, u.username AS author_name, u.id AS user_id " +
                          "FROM replies r JOIN users u ON r.user_id = u.id " +
                          "WHERE r.post_id = ? ORDER BY r.created_at ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(replySql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                int floor = 1;
                while (rs.next()) {
                    Map<String, Object> reply = new HashMap<>();
                    reply.put("id", rs.getInt("id"));
                    reply.put("content", rs.getString("content"));
                    reply.put("createdAt", rs.getTimestamp("created_at").toString());
                    reply.put("authorName", rs.getString("author_name"));
                    reply.put("userId", rs.getInt("user_id"));
                    reply.put("floor", floor++);
                    replyList.add(reply);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        request.setAttribute("replyList", replyList);
        request.setAttribute("replyCount", replyList.size());

        request.getRequestDispatcher("/post/detail.jsp").forward(request, response);
    }

    /** 处理发帖（需登录，支持本地上传封面图） */
    private void handleCreatePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");

        // 校验
        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            request.getRequestDispatcher("/post/create.jsp").forward(request, response);
            return;
        }

        // 处理封面图：优先本地上传，否则用URL
        String imageUrl = saveUploadedImage(request);
        if (imageUrl.isEmpty()) {
            String urlParam = request.getParameter("imageUrl");
            imageUrl = (urlParam != null) ? urlParam.trim() : "";
        }

        int userId = (int) user.get("id");
        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            categoryId = 1;
        }

        String sql = "INSERT INTO posts (title, content, image_url, user_id, category_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title.trim());
            ps.setString(2, content.trim());
            ps.setString(3, imageUrl);
            ps.setInt(4, userId);
            ps.setInt(5, categoryId);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int newId = rs.getInt(1);
                    response.sendRedirect(request.getContextPath() + "/post/detail?id=" + newId);
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "发布失败，请重试");
            request.getRequestDispatcher("/post/create.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/");
    }

    /** 处理回复（需登录） */
    private void handleReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        String content = request.getParameter("content");
        String postIdStr = request.getParameter("postId");

        if (content == null || content.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postIdStr);
            return;
        }

        int userId = (int) user.get("id");
        int postId;
        try {
            postId = Integer.parseInt(postIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String sql = "INSERT INTO replies (content, user_id, post_id) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, content.trim());
            ps.setInt(2, userId);
            ps.setInt(3, postId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
    }

    /** 显示编辑表单（需登录且是作者或管理员） */
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String sql = "SELECT p.id, p.title, p.content, p.image_url, p.user_id, p.category_id FROM posts p WHERE p.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // 权限检查
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }

                    Map<String, Object> post = new HashMap<>();
                    post.put("id", rs.getInt("id"));
                    post.put("title", rs.getString("title"));
                    post.put("content", rs.getString("content"));
                    post.put("imageUrl", rs.getString("image_url") == null ? "" : rs.getString("image_url"));
                    post.put("userId", rs.getInt("user_id"));
                    post.put("categoryId", rs.getInt("category_id"));
                    request.setAttribute("post", post);
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/post/edit.jsp").forward(request, response);
    }

    /** 处理编辑（需登录且是作者或管理员） */
    private void handleEditPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String categoryIdStr = request.getParameter("categoryId");

        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "标题和内容不能为空");
            handleEditForm(request, response);
            return;
        }

        // 处理封面图：优先本地上传，否则用URL
        String imageUrl = saveUploadedImage(request);
        if (imageUrl.isEmpty()) {
            String urlParam = request.getParameter("imageUrl");
            imageUrl = (urlParam != null) ? urlParam.trim() : "";
        }

        int categoryId;
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            categoryId = 1;
        }

        // 先检查权限
        String checkSql = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        String sql = "UPDATE posts SET title=?, content=?, image_url=?, category_id=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title.trim());
            ps.setString(2, content.trim());
            ps.setString(3, imageUrl);
            ps.setInt(4, categoryId);
            ps.setInt(5, postId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
    }

    /** 删除帖子（需登录且是作者或管理员） */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // 检查权限
        String checkSql = "SELECT user_id FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int authorId = rs.getInt("user_id");
                    if (!"admin".equals(user.get("role")) && (int) user.get("id") != authorId) {
                        response.sendRedirect(request.getContextPath() + "/post/detail?id=" + postId);
                        return;
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM posts WHERE id = ?")) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/");
    }

    /**  生成AI总结（需登录），返回JSON */
    private void handleAiSummary(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"请先登录\"}");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"参数错误\"}");
            return;
        }

        // 查帖子标题和内容
        String sql = "SELECT title, content FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String title = rs.getString("title");
                    String content = rs.getString("content");

                    // 调用AI生成总结
                    String summary = AiUtil.generateSummary(title, content);

                    if (summary != null) {
                        // 存入数据库
                        String updateSql = "UPDATE posts SET ai_summary = ? WHERE id = ?";
                        try (Connection conn2 = DBUtil.getConnection();
                             PreparedStatement ps2 = conn2.prepareStatement(updateSql)) {
                            ps2.setString(1, summary);
                            ps2.setInt(2, postId);
                            ps2.executeUpdate();
                        }

                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"summary\":\"" + escapeJson(summary) + "\"}");
                    } else {
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"error\":\"AI接口调用失败，请重试\"}");
                    }
                } else {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"error\":\"帖子不存在\"}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"服务器错误\"}");
        }
    }

    /** 处理内联图片上传，返回 Markdown 图片语法文本 */
    private void handleInlineImageUpload(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.setStatus(403);
            response.getWriter().write("{\"error\":\"请先登录\"}");
            return;
        }

        String url = saveUploadedImage(request);
        if (url.isEmpty()) {
            response.setStatus(400);
            response.getWriter().write("{\"error\":\"上传失败，仅支持 jpg/png/gif/webp\"}");
            return;
        }

        // 返回 Markdown 图片语法，前端直接插入文本框
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"markdown\":\"![图片](" + url + ")\",\"url\":\"" + url + "\"}");
    }

    /** JSON字符串转义 */
    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }

    /**
     * 保存上传的封面图片到 webapp/uploads/ 目录
     * @return 图片的访问URL，没有上传时返回空字符串
     */
    private String saveUploadedImage(HttpServletRequest request) throws IOException, ServletException {
        Part filePart;
        try {
            filePart = request.getPart("coverImage");
        } catch (ServletException e) {
            return "";
        }

        if (filePart == null || filePart.getSize() == 0) {
            return "";
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }

        // 只允许图片格式
        String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
            return "";
        }

        // 生成唯一文件名
        String newFileName = UUID.randomUUID().toString() + ext;

        // 上传目录: src/main/webapp/uploads/
        String projectRoot = System.getProperty("user.dir");
        File uploadDir = new File(projectRoot, "src/main/webapp/uploads");
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File targetFile = new File(uploadDir, newFileName);
        Files.copy(filePart.getInputStream(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

        return request.getContextPath() + "/uploads/" + newFileName;
    }
}
