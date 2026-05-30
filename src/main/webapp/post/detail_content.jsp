<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/category?id=${post.categoryId}">${post.categoryName}</a>
    <span>/</span> 帖子详情
</div>

<!-- 帖子主体 -->
<article>
    <h1 style="font-size:24px;margin-bottom:16px;">
        <c:if test="${post.isTop > 0}">
            <span class="badge badge-top"><i class="fa fa-arrow-up"></i> 置顶</span>
        </c:if>
        <c:if test="${post.isElite == 1}">
            <span class="badge badge-elite"><i class="fa fa-diamond"></i> 精华</span>
        </c:if>
        ${post.title}
    </h1>

    <div class="card-meta" style="padding-bottom:16px;border-bottom:1px solid #e5e7eb;">
        <span><i class="fa fa-user"></i> ${post.authorName}</span>
        <span><i class="fa fa-clock-o"></i> ${post.createdAt}</span>
        <span><i class="fa fa-eye"></i> ${post.viewCount} 浏览</span>
        <c:if test="${post.updatedAt != null}">
            <span><i class="fa fa-edit"></i> ${post.updatedAt} 修改</span>
        </c:if>
    </div>

    <div style="padding:20px 0;line-height:1.8;font-size:15px;">
        ${post.content}
    </div>

    <!-- 操作按钮 -->
    <div style="padding-bottom:16px;border-bottom:1px solid #e5e7eb;">
        <c:if test="${sessionScope.user.id == post.userId or sessionScope.user.role == 'admin'}">
            <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}" class="btn btn-sm btn-primary">
                <i class="fa fa-edit"></i> 编辑
            </a>
            <a href="${pageContext.request.contextPath}/post/delete?id=${post.id}"
               class="btn btn-sm btn-danger" onclick="return confirmDelete('确定删除此帖子？')">
                <i class="fa fa-trash"></i> 删除
            </a>
        </c:if>
        <c:if test="${sessionScope.user.role == 'admin'}">
            <c:if test="${post.isTop == 0}">
                <a href="${pageContext.request.contextPath}/admin/post/top?id=${post.id}&level=1"
                   class="btn btn-sm btn-warning"><i class="fa fa-arrow-up"></i> 板块置顶</a>
                <a href="${pageContext.request.contextPath}/admin/post/top?id=${post.id}&level=2"
                   class="btn btn-sm btn-warning"><i class="fa fa-arrow-up"></i> 全局置顶</a>
            </c:if>
            <c:choose>
                <c:when test="${post.isElite == 0}">
                    <a href="${pageContext.request.contextPath}/admin/post/elite?id=${post.id}&action=add"
                       class="btn btn-sm btn-warning"><i class="fa fa-diamond"></i> 加精</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admin/post/elite?id=${post.id}&action=remove"
                       class="btn btn-sm btn-warning"><i class="fa fa-diamond"></i> 取消加精</a>
                </c:otherwise>
            </c:choose>
        </c:if>
    </div>
</article>

<!-- 回复列表 -->
<section style="margin-top:24px;">
    <h3 style="margin-bottom:16px;">
        <i class="fa fa-comments"></i> 回复（${replyCount}）
    </h3>

    <c:choose>
        <c:when test="${empty replyList}">
            <div class="empty-state">
                <i class="fa fa-commenting-o"></i>
                <p>暂无回复，快来抢沙发！</p>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="reply" items="${replyList}">
                <div class="card" style="padding:16px;">
                    <div class="card-meta">
                        <span><i class="fa fa-user"></i> ${reply.authorName}</span>
                        <span><i class="fa fa-clock-o"></i> ${reply.createdAt}</span>
                        <span>#${reply.floor}</span>
                    </div>
                    <div style="margin-top:8px;">${reply.content}</div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</section>

<!-- 回复表单 -->
<c:if test="${not empty sessionScope.user}">
    <section style="margin-top:24px;">
        <h3 style="margin-bottom:16px;"><i class="fa fa-reply"></i> 发表回复</h3>
        <form action="${pageContext.request.contextPath}/post/reply" method="post">
            <input type="hidden" name="postId" value="${post.id}">
            <div class="form-group">
                <textarea name="content" class="form-input" rows="5"
                          placeholder="请输入回复内容..." required></textarea>
            </div>
            <button type="submit" class="btn btn-primary">
                <i class="fa fa-send"></i> 提交回复
            </button>
        </form>
    </section>
</c:if>
