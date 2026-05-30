<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2 style="margin-bottom:20px;"><i class="fa fa-dashboard"></i> 管理员后台</h2>

<!-- 统计卡片 -->
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px;">
    <div class="card" style="text-align:center;">
        <div style="font-size:32px;color:#3b82f6;font-weight:bold;">${postCount}</div>
        <div style="color:#94a3b8;font-size:13px;">帖子总数</div>
    </div>
    <div class="card" style="text-align:center;">
        <div style="font-size:32px;color:#10b981;font-weight:bold;">${userCount}</div>
        <div style="color:#94a3b8;font-size:13px;">用户总数</div>
    </div>
    <div class="card" style="text-align:center;">
        <div style="font-size:32px;color:#f59e0b;font-weight:bold;">${categoryCount}</div>
        <div style="color:#94a3b8;font-size:13px;">板块数量</div>
    </div>
</div>

<!-- 快捷入口 -->
<div style="display:grid;grid-template-columns:repeat(2,1fr);gap:12px;">
    <a href="${pageContext.request.contextPath}/admin/categories" class="card" style="display:block;text-align:center;">
        <i class="fa fa-th-list" style="font-size:24px;color:#3b82f6;"></i>
        <p style="margin-top:8px;">板块管理</p>
    </a>
    <a href="${pageContext.request.contextPath}/admin/post/manage" class="card" style="display:block;text-align:center;">
        <i class="fa fa-file-text" style="font-size:24px;color:#10b981;"></i>
        <p style="margin-top:8px;">帖子管理</p>
    </a>
</div>
