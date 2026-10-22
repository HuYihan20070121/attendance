# syntax=docker/dockerfile:1
# ---------------------------------------------------------------------------
# Simple Attendance by Seat Id
# ---------------------------------------------------------------------------
# 讲义（RenderLab.docx 6.1）要求先在 NetBeans/Ant 里打出 attendance.war 再上传。
# 这个 Dockerfile 把"编译 + 打包"这一步搬进镜像里做，所以仓库里只需要 Java 源码:
# 本机不需要 JDK、不需要 NetBeans、也不需要任何 .war 文件，Render 构建时自己编译。
#
# 应用发布在 context path /attendance/（与讲义一致: webapps 下的目录名就是 context path）,
# 所以访问地址是 https://<服务名>.onrender.com/attendance/
# ---------------------------------------------------------------------------
FROM tomcat:9.0-jdk11-corretto

# 删掉 Tomcat 自带的示例应用，只保留本应用（讲义 6.2 节同样做法）
RUN rm -rf /usr/local/tomcat/webapps/ROOT \
           /usr/local/tomcat/webapps/docs \
           /usr/local/tomcat/webapps/examples \
           /usr/local/tomcat/webapps/host-manager \
           /usr/local/tomcat/webapps/manager

# 源码与静态文件放在 webapps 之外，避免被直接下载
COPY src/ /opt/app/src/
COPY web/ /opt/app/web/

# 1) 用 Tomcat 自带的 servlet-api.jar 编译 Attend.java（等价于 NetBeans 的 Build）
# 2) 组装成 exploded web application: webapps/attendance
RUN set -eux; \
    mkdir -p /tmp/app/WEB-INF/classes; \
    javac -encoding UTF-8 \
          -cp /usr/local/tomcat/lib/servlet-api.jar \
          -d /tmp/app/WEB-INF/classes \
          /opt/app/src/attendance/Attend.java; \
    cp -R /opt/app/web/. /tmp/app/; \
    cp -R /tmp/app /usr/local/tomcat/webapps/attendance; \
    rm -rf /opt/app /tmp/app; \
    echo "--- deployed ---"; \
    find /usr/local/tomcat/webapps/attendance -type f

# Render 会注入 PORT；entrypoint.sh 在启动前把 Tomcat 的 8080 改成 $PORT
COPY entrypoint.sh /usr/local/tomcat/bin/entrypoint.sh
RUN chmod +x /usr/local/tomcat/bin/entrypoint.sh

EXPOSE 8080
CMD ["/usr/local/tomcat/bin/entrypoint.sh"]
