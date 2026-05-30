<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/">首页</a>
    <span>/</span> 发布帖子
</div>

<h2 style="margin-bottom:20px;"><i class="fa fa-pencil"></i> 发布帖子</h2>

<form action="${pageContext.request.contextPath}/post/create" method="post">
    <div class="form-group">
        <label for="categoryId">选择板块 *</label>
        <select name="categoryId" id="categoryId" class="form-select" required>
            <option value="">-- 请选择板块 --</option>
            <c:forEach var="cat" items="${sessionScope.categoryList}">
                <option value="${cat.id}">${cat.name}</option>
            </c:forEach>
        </select>
    </div>

    <div class="form-group">
        <label for="title">标题 *</label>
        <input type="text" name="title" id="title" class="form-input"
               placeholder="请输入帖子标题（1-100字）" maxlength="100" required>
    </div>

    <div class="form-group">
        <label for="content">内容 *</label>
        <textarea name="content" id="content" class="form-input"
                  placeholder="请输入帖子内容..." rows="10" required></textarea>
    </div>

    <div style="display:flex;gap:12px;">
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="fa fa-check"></i> 发布
        </button>
        <a href="${pageContext.request.contextPath}/" class="btn btn-lg" style="background:#e5e7eb;color:#475569;">
            取消
        </a>
    </div>
</form>
