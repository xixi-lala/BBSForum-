package com.bbs.util;

/**
 * 内容渲染工具
 * 支持 Markdown 图片语法 ![描述](URL) 和内联图片
 */
public class ContentUtil {

    /**
     * 将帖子内容渲染为 HTML
     * 支持：![描述](URL) 渲染为图片、**文字** 加粗、空行分段
     * 其他 HTML 特殊字符会被转义，防止 XSS
     */
    public static String render(String content) {
        if (content == null || content.isEmpty()) {
            return "";
        }

        // 1. 先转义 HTML 防止 XSS
        String html = escapeHtml(content);

        // 2. 图片语法 ![alt](url) → <img>
        html = html.replaceAll("!\\[([^\\]]*)\\]\\(([^)]+)\\)",
                "<img src=\"$2\" alt=\"$1\" class=\"max-w-full rounded-lg my-3\" loading=\"lazy\" onerror=\"this.style.display='none'\">");

        // 3. 链接语法 [text](url) → <a> (但不影响已处理的图片)
        html = html.replaceAll("(?<!!)\\[([^\\]]*)\\]\\(([^)]+)\\)",
                "<a href=\"$2\" target=\"_blank\" class=\"text-blue-500 hover:text-blue-600 underline\">$1</a>");

        // 4. **加粗**
        html = html.replaceAll("\\*\\*(.+?)\\*\\*", "<strong>$1</strong>");

        // 5. 连续两个换行 → 段落
        html = html.replaceAll("(\r?\n){2,}", "</p><p class=\"mb-3\">");

        // 6. 单个换行 → <br>
        html = html.replaceAll("(\r?\n)", "<br>");

        // 包裹在段落中
        html = "<p class=\"mb-3\">" + html + "</p>";

        return html;
    }

    /** 获取内容纯文本摘要（去除图片和HTML） */
    public static String summary(String content, int maxLen) {
        if (content == null || content.isEmpty()) {
            return "";
        }
        // 去掉图片语法
        String text = content.replaceAll("!\\[([^\\]]*)\\]\\([^)]+\\)", "[图片]");
        // 去掉链接语法保留文字
        text = text.replaceAll("\\[([^\\]]*)\\]\\([^)]+\\)", "$1");
        // 去掉Markdown标记
        text = text.replaceAll("\\*\\*(.+?)\\*\\*", "$1");

        if (text.length() > maxLen) {
            text = text.substring(0, maxLen) + "...";
        }
        return text;
    }

    private static String escapeHtml(String input) {
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
