<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 面包屑 -->
<div class="flex items-center gap-2 text-sm text-gray-400 mb-4">
    <a href="${pageContext.request.contextPath}/" class="text-gray-500 hover:text-blue-500 no-underline">首页</a>
    <span>/</span>
    <a href="${pageContext.request.contextPath}/category?id=${post.categoryId}" class="text-gray-500 hover:text-blue-500 no-underline">${post.categoryName}</a>
    <span>/</span>
    <span class="text-gray-700">帖子详情</span>
</div>

<!-- 帖子主体 -->
<article class="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden mb-6">
    <!-- 封面图：大图展示 -->
    <c:if test="${not empty post.imageUrl}">
        <div class="w-full bg-gray-100">
            <img src="${post.imageUrl}" alt="${post.title}" class="w-full max-h-80 object-cover" onerror="this.parentElement.style.display='none'">
        </div>
    </c:if>

    <div class="p-6">
        <!-- 标签 -->
        <div class="mb-3">
            <c:if test="${post.isTop == 2}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-2">全局置顶</span></c:if>
            <c:if test="${post.isTop == 1}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded mr-2">置顶</span></c:if>
            <c:if test="${post.isElite == 1}"><span class="inline-block px-2 py-0.5 text-xs font-medium text-pink-600 bg-pink-50 border border-pink-200 rounded">精华</span></c:if>
        </div>

        <!-- 标题 -->
        <h1 class="text-2xl font-bold text-gray-900 mb-4 leading-snug">${post.title}</h1>

        <!-- 元信息 -->
        <div class="flex items-center gap-5 text-sm text-gray-400 pb-5 border-b border-gray-100 flex-wrap">
            <span class="flex items-center gap-1.5">
                <span class="w-7 h-7 bg-blue-500 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(post.authorName, 0, 1)}</span>
                <span class="text-gray-700 font-medium">${post.authorName}</span>
            </span>
            <span><i class="fa fa-clock-o mr-1"></i> ${post.createdAt}</span>
            <span><i class="fa fa-eye mr-1"></i> ${post.viewCount} 次浏览</span>
        </div>

        <!-- 正文（渲染后的HTML，支持内联图片） -->
        <div class="py-6 text-gray-800 leading-relaxed text-[15px] post-content">
            ${post.contentRendered}
        </div>

        <!-- 操作按钮 -->
        <div class="flex items-center gap-2 pt-4 border-t border-gray-100 flex-wrap">
            <button onclick="history.back()" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-gray-500 bg-gray-100 border border-gray-200 rounded hover:bg-gray-200 transition cursor-pointer">
                <i class="fa fa-arrow-left"></i> 返回
            </button>
            <c:if test="${sessionScope.user.id == post.userId || sessionScope.user.role == 'admin'}">
                <a href="${pageContext.request.contextPath}/post/edit?id=${post.id}" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-blue-600 bg-blue-50 border border-blue-200 rounded hover:bg-blue-100 no-underline transition">
                    <i class="fa fa-edit"></i> 编辑
                </a>
                <a href="${pageContext.request.contextPath}/post/delete?id=${post.id}" onclick="return confirm('确定删除此帖子？')" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-red-600 bg-red-50 border border-red-200 rounded hover:bg-red-100 no-underline transition">
                    <i class="fa fa-trash"></i> 删除
                </a>
            </c:if>
            <c:if test="${sessionScope.user.role == 'admin'}">
                <c:if test="${post.isTop == 0}">
                    <a href="${pageContext.request.contextPath}/admin/post/top?id=${post.id}&level=1" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-orange-600 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 no-underline transition">
                        <i class="fa fa-arrow-up"></i> 板块置顶
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/post/top?id=${post.id}&level=2" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-orange-600 bg-orange-50 border border-orange-200 rounded hover:bg-orange-100 no-underline transition">
                        <i class="fa fa-arrow-up"></i> 全局置顶
                    </a>
                </c:if>
                <c:choose>
                    <c:when test="${post.isElite == 0}">
                        <a href="${pageContext.request.contextPath}/admin/post/elite?id=${post.id}&action=add" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-pink-600 bg-pink-50 border border-pink-200 rounded hover:bg-pink-100 no-underline transition">
                            <i class="fa fa-diamond"></i> 加精
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/admin/post/elite?id=${post.id}&action=remove" class="inline-flex items-center gap-1 px-3 py-1.5 text-sm text-pink-600 bg-pink-50 border border-pink-200 rounded hover:bg-pink-100 no-underline transition">
                            <i class="fa fa-diamond"></i> 取消加精
                        </a>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </div>
    </div>
</article>

<!-- 回复列表 -->
<section class="mb-6">
    <h3 class="text-lg font-semibold text-gray-900 mb-4">
        <i class="fa fa-comments mr-1"></i> 回复（${replyCount}）
    </h3>

    <c:choose>
        <c:when test="${empty replyList}">
            <div class="text-center py-12 bg-white rounded-lg border border-gray-100 text-gray-400">
                <i class="fa fa-commenting-o text-4xl block mb-3"></i>
                <p class="text-sm">暂无回复，快来抢沙发！</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="space-y-3">
                <c:forEach var="reply" items="${replyList}">
                    <div class="bg-white rounded-lg shadow-sm border border-gray-100 p-5">
                        <div class="flex items-center gap-3 mb-3">
                            <span class="w-7 h-7 bg-green-500 text-white rounded-full flex items-center justify-center text-xs font-bold">${fn:substring(reply.authorName, 0, 1)}</span>
                            <span class="text-sm font-medium text-gray-700">${reply.authorName}</span>
                            <span class="text-xs text-gray-400">${reply.createdAt}</span>
                            <span class="text-xs text-gray-300 ml-auto">#${reply.floor}</span>
                        </div>
                        <p class="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">${reply.content}</p>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<!-- 回复表单（仅登录用户可见） -->
<c:choose>
    <c:when test="${not empty sessionScope.user}">
        <section class="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
            <h3 class="text-base font-semibold text-gray-900 mb-4">
                <i class="fa fa-reply mr-1"></i> 发表回复
            </h3>
            <form action="${pageContext.request.contextPath}/post/reply" method="post">
                <input type="hidden" name="postId" value="${post.id}">
                <textarea name="content" rows="4" placeholder="写下你的回复..."
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-200 resize-none mb-4" required></textarea>
                <button type="submit" class="inline-flex items-center gap-1.5 px-5 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 transition cursor-pointer border-none">
                    <i class="fa fa-send"></i> 提交回复
                </button>
            </form>
        </section>
    </c:when>
    <c:otherwise>
        <div class="bg-gray-50 rounded-lg border border-gray-200 p-6 text-center">
            <p class="text-sm text-gray-500 mb-3">登录后才能发表回复</p>
            <a href="${pageContext.request.contextPath}/user/login" class="inline-flex items-center gap-1 px-4 py-2 bg-blue-500 text-white text-sm rounded-md hover:bg-blue-600 no-underline transition">
                <i class="fa fa-sign-in"></i> 立即登录
            </a>
        </div>
    </c:otherwise>
</c:choose>
