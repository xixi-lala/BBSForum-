<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="breadcrumb">
    <a href="${pageContext.request.contextPath}/">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/demand">需求列表</a>
    <span>/</span> 需求详情
</div>

<article>
    <h1 style="font-size:24px;margin-bottom:16px;">
        <span class="badge badge-score"><i class="fa fa-diamond"></i> ${demand.score} 积分</span>
        <c:if test="${demand.status == 'closed'}">
            <span class="badge" style="background:#d1d5db;color:#6b7280;">已结束</span>
        </c:if>
        ${demand.title}
    </h1>

    <div class="card-meta" style="padding-bottom:16px;border-bottom:1px solid #e5e7eb;">
        <span><i class="fa fa-user"></i> ${demand.authorName}</span>
        <span><i class="fa fa-clock-o"></i> ${demand.createdAt}</span>
        <span><i class="fa fa-tag"></i> ${demand.status == 'open' ? '进行中' : '已结束'}</span>
    </div>

    <div style="padding:20px 0;line-height:1.8;font-size:15px;">
        ${demand.content}
    </div>

    <!-- 采纳按钮（仅发布者可操作） -->
    <c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open'}">
        <div style="padding:12px 0;border-top:1px solid #e5e7eb;">
            <p style="color:#94a3b8;font-size:13px;">
                <i class="fa fa-info-circle"></i> 你可以采纳一条最佳回复，采纳后积分将转给该回复者
            </p>
        </div>
    </c:if>
</article>

<!-- 回复区（复用帖子回复结构） -->
<section style="margin-top:24px;">
    <h3 style="margin-bottom:16px;"><i class="fa fa-comments"></i> 回复</h3>

    <c:choose>
        <c:when test="${empty replyList}">
            <div class="empty-state"><i class="fa fa-commenting-o"></i><p>暂无回复</p></div>
        </c:when>
        <c:otherwise>
            <c:forEach var="reply" items="${replyList}">
                <div class="card" style="padding:16px;">
                    <div class="card-meta">
                        <span><i class="fa fa-user"></i> ${reply.authorName}</span>
                        <span><i class="fa fa-clock-o"></i> ${reply.createdAt}</span>
                        <c:if test="${reply.id == demand.bestReplyId}">
                            <span class="badge badge-score"><i class="fa fa-check-circle"></i> 已采纳</span>
                        </c:if>
                    </div>
                    <div style="margin-top:8px;">${reply.content}</div>
                    <!-- 采纳按钮 -->
                    <c:if test="${sessionScope.user.id == demand.userId && demand.status == 'open' && reply.id != demand.bestReplyId}">
                        <div style="margin-top:8px;">
                            <a href="${pageContext.request.contextPath}/demand/accept?demandId=${demand.id}&replyId=${reply.id}"
                               class="btn btn-sm btn-warning" onclick="return confirm('确定采纳此回复？积分将转给该用户')">
                                <i class="fa fa-check"></i> 采纳此回复
                            </a>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</section>

<!-- 回复表单 -->
<c:if test="${not empty sessionScope.user && demand.status == 'open'}">
    <section style="margin-top:24px;">
        <h3 style="margin-bottom:16px;"><i class="fa fa-reply"></i> 发表回复</h3>
        <form action="${pageContext.request.contextPath}/post/reply" method="post">
            <input type="hidden" name="postId" value="${demand.id}">
            <input type="hidden" name="isDemand" value="1">
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
