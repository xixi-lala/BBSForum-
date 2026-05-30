<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
    <h2><i class="fa fa-file-text"></i> 帖子管理（置顶/加精/编辑）</h2>
    <a href="${pageContext.request.contextPath}/admin" class="btn btn-sm" style="background:#e5e7eb;color:#475569;">
        <i class="fa fa-arrow-left"></i> 返回后台
    </a>
</div>

<table class="data-table">
    <thead>
        <tr>
            <th>ID</th>
            <th>标题</th>
            <th>作者</th>
            <th>板块</th>
            <th>置顶</th>
            <th>精华</th>
            <th>操作</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="post" items="${postList}">
            <tr>
                <td>${post.id}</td>
                <td><a href="${pageContext.request.contextPath}/post/detail?id=${post.id}">${post.title}</a></td>
                <td>${post.authorName}</td>
                <td>${post.categoryName}</td>
                <td>${post.isTop == 2 ? '全局' : post.isTop == 1 ? '板块' : '否'}</td>
                <td>${post.isElite == 1 ? '是' : '否'}</td>
                <td>
                    <a href="${pageContext.request.contextPath}/admin/post/top?id=${post.id}"
                       class="btn btn-sm btn-warning"><i class="fa fa-arrow-up"></i></a>
                    <a href="${pageContext.request.contextPath}/admin/post/elite?id=${post.id}"
                       class="btn btn-sm btn-warning"><i class="fa fa-diamond"></i></a>
                    <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}"
                       class="btn btn-sm btn-primary"><i class="fa fa-edit"></i></a>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>

<div class="pagination">${pagination}</div>
