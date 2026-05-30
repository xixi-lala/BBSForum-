<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<h2 style="margin-bottom:20px;"><i class="fa fa-trophy"></i> 积分排行</h2>

<table class="data-table">
    <thead>
        <tr>
            <th>排名</th>
            <th>用户名</th>
            <th>总积分</th>
        </tr>
    </thead>
    <tbody>
        <c:choose>
            <c:when test="${empty rankList}">
                <tr><td colspan="3" style="text-align:center;color:#94a3b8;">暂无数据</td></tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="row" items="${rankList}" varStatus="status">
                    <tr>
                        <td>
                            <c:choose>
                                <c:when test="${status.index == 0}"><span style="color:#f59e0b;font-size:18px;"><i class="fa fa-trophy"></i></span></c:when>
                                <c:when test="${status.index == 1}"><span style="color:#94a3b8;font-size:16px;"><i class="fa fa-trophy"></i></span></c:when>
                                <c:when test="${status.index == 2}"><span style="color:#b45309;font-size:16px;"><i class="fa fa-trophy"></i></span></c:when>
                                <c:otherwise>${status.index + 1}</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${row.username}</td>
                        <td style="font-weight:600;">${row.score}</td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </tbody>
</table>
