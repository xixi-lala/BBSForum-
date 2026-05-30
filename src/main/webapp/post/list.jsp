<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 帖子列表 -->
<div class="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
    <h2 class="text-lg font-semibold text-gray-900">
        <c:choose>
            <c:when test="${not empty currentCategory}">
                <i class="fa fa-folder-o mr-1"></i> ${currentCategory.name}
            </c:when>
            <c:otherwise>
                <i class="fa fa-newspaper-o mr-1"></i> 全部帖子
            </c:otherwise>
        </c:choose>
    </h2>
    <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/post/create" class="inline-flex items-center gap-1 px-5 py-2 bg-red-500 text-white text-sm rounded-md hover:bg-red-600 no-underline transition">
            <i class="fa fa-plus"></i> 写文章
        </a>
    </c:if>
</div>

<c:choose>
    <c:when test="${empty postList}">
        <div class="text-center py-20 text-gray-400">
            <i class="fa fa-inbox text-5xl block mb-4"></i>
            <p class="text-sm">还没有帖子，成为第一个分享知识的人吧</p>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="post" items="${postList}">
            <article class="bg-white rounded-lg shadow-sm hover:shadow-md transition-all border border-gray-100 overflow-hidden cursor-pointer mb-3" onclick="location.href='${pageContext.request.contextPath}/post/detail?id=${post.id}'">
                <div class="flex">
                    <!-- 封面图 -->
                    <div class="w-52 h-32 shrink-0 overflow-hidden bg-gray-100">
                        <c:choose>
                            <c:when test="${not empty post.imageUrl}">
                                <img src="${post.imageUrl}" alt="${post.title}" class="w-full h-full object-cover" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white text-3xl" style="display:none">
                                    <i class="fa fa-image"></i>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white text-3xl">
                                    <i class="fa fa-image"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <!-- 内容 -->
                    <div class="flex-1 p-5 min-w-0 flex flex-col justify-between">
                        <div>
                            <h3 class="text-base font-semibold leading-snug mb-2">
                                <c:if test="${post.isTop == 2}"><span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">全局置顶</span></c:if>
                                <c:if test="${post.isTop == 1}"><span class="inline-block px-1.5 py-px text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-1.5 align-middle">置顶</span></c:if>
                                <c:if test="${post.isElite == 1}"><span class="inline-block px-1.5 py-px text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded mr-1.5 align-middle">精华</span></c:if>
                                <a href="${pageContext.request.contextPath}/post/detail?id=${post.id}" class="text-gray-900 hover:text-red-500 no-underline">${post.title}</a>
                            </h3>
                            <p class="text-sm text-gray-500 leading-relaxed mb-3 line-clamp-2">
                                <c:if test="${not empty post.aiSummary}"><span class="text-purple-500 mr-1">🤖</span></c:if>
                                ${post.summary}
                            </p>
                        </div>
                        <div class="flex items-center gap-4 text-xs text-gray-400 flex-wrap">
                            <span class="flex items-center gap-1">
                                <span class="w-5 h-5 bg-red-400 text-white rounded-full flex items-center justify-center text-[10px] font-bold">${fn:substring(post.authorName, 0, 1)}</span>
                                ${post.authorName}
                            </span>
                            <span><i class="fa fa-folder-o mr-0.5"></i> ${post.categoryName}</span>
                            <span><i class="fa fa-eye mr-0.5"></i> ${post.viewCount}</span>
                            <span><i class="fa fa-clock-o mr-0.5"></i> ${post.createdAt}</span>
                        </div>
                    </div>
                </div>
            </article>
        </c:forEach>
        <div class="flex justify-center gap-2 mt-8 pb-5">${pagination}</div>
    </c:otherwise>
</c:choose>
