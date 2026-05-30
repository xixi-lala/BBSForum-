package com.bbs;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * BBS论坛系统 - 唯一启动入口
 * 右键此类 → Run 'Main' 即可启动
 */
public class Main {

    public static void main(String[] args) throws Exception {
        int port = 8088;

        // 找项目根目录
        File projectRoot = new File(System.getProperty("user.dir"));
        // 如果当前目录是子目录，向上找
        while (projectRoot != null && !new File(projectRoot, "src/main/webapp").exists()) {
            projectRoot = projectRoot.getParentFile();
        }

        if (projectRoot == null || !new File(projectRoot, "src/main/webapp").exists()) {
            System.err.println("错误：找不到 src/main/webapp 目录！");
            System.err.println("请在 IDE 中右键 Main.java → Run，不要直接 java -jar");
            System.exit(1);
        }

        File webappDir = new File(projectRoot, "src/main/webapp");
        System.out.println("项目根目录: " + projectRoot.getAbsolutePath());
        System.out.println("Web资源目录: " + webappDir.getAbsolutePath());

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector();

        // 创建 context
        String contextPath = "/BBSForum";
        StandardContext ctx = (StandardContext) tomcat.addWebapp(contextPath, webappDir.getAbsolutePath());
        ctx.setReloadable(true);

        // 让 Tomcat 能加载 WEB-INF/classes 中的类
        File classesDir = new File(projectRoot, "target/classes");
        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes", classesDir.getAbsolutePath(), "/"));
        ctx.setResources(resources);

        tomcat.start();

        System.out.println();
        System.out.println("==========================================");
        System.out.println("  BBS技术社区 启动成功！");
        System.out.println("  http://localhost:" + port + contextPath + "/");
        System.out.println("==========================================");

        tomcat.getServer().await();
    }
}
