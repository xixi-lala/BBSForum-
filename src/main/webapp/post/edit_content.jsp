<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}">帖子详情</a>
    <span>/</span> 编辑
</div>

<h2 style="margin-bottom:20px;"><i class="fa fa-edit"></i> 编辑帖子</h2>

<form action="${pageContext.request.contextPath}/post/edit" method="post">
    <input type="hidden" name="id" value="${post.id}">

    <div class="form-group">
        <label for="categoryId">选择板块 *</label>
        <select name="categoryId" id="categoryId" class="form-select" required>
            <c:forEach var="cat" items="${sessionScope.categoryList}">
                <option value="${cat.id}" ${cat.id == post.categoryId ? 'selected' : ''}>${cat.name}</option>
            </c:forEach>
        </select>
    </div>

    <div class="form-group">
        <label for="title">标题 *</label>
        <input type="text" name="title" id="title" class="form-input"
               value="${post.title}" maxlength="100" required>
    </div>

    <div class="form-group">
        <label for="content">内容 *</label>
        <textarea name="content" id="content" class="form-input"
                  rows="10" required>${post.content}</textarea>
    </div>

    <div style="display:flex;gap:12px;">
        <button type="submit" class="btn btn-primary btn-lg">
            <i class="fa fa-save"></i> 保存修改
        </button>
        <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}"
           class="btn btn-lg" style="background:#e5e7eb;color:#475569;">取消</a>
    </div>
</form>
