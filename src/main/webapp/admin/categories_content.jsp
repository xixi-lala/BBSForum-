<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
    <h2><i class="fa fa-th-list"></i> 板块管理</h2>
    <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm" style="background:#e5e7eb;color:#475569;">
        <i class="fa fa-arrow-left"></i> 返回后台
    </a>
</div>

<c:if test="${not empty message}">
    <div class="alert alert-success"><i class="fa fa-check-circle"></i> ${message}</div>
</c:if>

<!-- 添加板块 -->
<form action="${pageContext.request.contextPath}/admin/categories/add" method="post"
      style="display:flex;gap:12px;margin-bottom:24px;align-items:flex-end;">
    <div class="form-group" style="margin-bottom:0;flex:1;">
        <label for="name">板块名称</label>
        <input type="text" name="name" id="name" class="form-input" placeholder="请输入板块名称" required>
    </div>
    <div class="form-group" style="margin-bottom:0;flex:2;">
        <label for="description">描述</label>
        <input type="text" name="description" id="description" class="form-input" placeholder="请输入板块描述">
    </div>
    <button type="submit" class="btn btn-primary">
        <i class="fa fa-plus"></i> 添加
    </button>
</form>

<!-- 板块列表 -->
<table class="data-table">
    <thead>
        <tr>
            <th>ID</th>
            <th>板块名称</th>
            <th>描述</th>
            <th>排序</th>
            <th>创建时间</th>
            <th>操作</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="cat" items="${categoryList}">
            <tr>
                <td>${cat.id}</td>
                <td>${cat.name}</td>
                <td>${cat.description}</td>
                <td>${cat.sortOrder}</td>
                <td>${cat.createdAt}</td>
                <td>
                    <a href="${pageContext.request.contextPath}/admin/categories/edit?id=${cat.id}"
                       class="btn btn-sm btn-primary"><i class="fa fa-edit"></i></a>
                    <a href="${pageContext.request.contextPath}/admin/categories/delete?id=${cat.id}"
                       class="btn btn-sm btn-danger" onclick="return confirmDelete('确定删除?')">
                        <i class="fa fa-trash"></i>
                    </a>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>
