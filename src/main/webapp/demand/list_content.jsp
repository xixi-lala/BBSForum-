<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
    <h2><i class="fa fa-gift"></i> 需求悬赏列表</h2>
    <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/demand/create" class="btn btn-warning">
            <i class="fa fa-plus"></i> 发布需求
        </a>
    </c:if>
</div>

<c:choose>
    <c:when test="${empty demandList}">
        <div class="empty-state">
            <i class="fa fa-inbox"></i>
            <p>暂无需求悬赏</p>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="demand" items="${demandList}">
            <div class="card">
                <div class="card-title">
                    <span class="badge badge-score"><i class="fa fa-diamond"></i> ${demand.score} 积分</span>
                    <c:if test="${demand.status == 'closed'}">
                        <span class="badge" style="background:#d1d5db;color:#6b7280;">已结束</span>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/demand/detail?id=${demand.id}">${demand.title}</a>
                </div>
                <div class="card-meta">
                    <span><i class="fa fa-user"></i> ${demand.authorName}</span>
                    <span><i class="fa fa-folder"></i> ${demand.categoryName}</span>
                    <span><i class="fa fa-clock-o"></i> ${demand.createdAt}</span>
                    <span>
                        <i class="fa fa-tag"></i>
                        ${demand.status == 'open' ? '进行中' : '已结束'}
                    </span>
                </div>
                <div class="card-body">${demand.summary}</div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<div class="pagination">${pagination}</div>
