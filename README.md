# attendance —— Simple Attendance by Seat Id

Java Servlet（Tomcat 9 + JDK 11）实现的课堂签到小应用，按 `RenderLab.docx` 完成，
部署到 Render.com 后的地址是：

```
https://attend95584.onrender.com/attendance/
```

## 为什么仓库里没有 .war

讲义 6.1 节要求先在 NetBeans/Ant 里 `jar -cvf attendance.war` 再上传。
这个仓库把「编译 + 组装」放进了 `Dockerfile`：镜像构建时用 Tomcat 自带的
`servlet-api.jar` 执行 `javac`，再拼出 exploded webapp。

好处：**本地不需要 JDK / NetBeans / war 文件**，直接推源码，Render 构建时编译。
如果你已经按讲义打好了 `attendance.war`，请改用 `Dockerfile.war-baseline.example`
（把它改名为 `Dockerfile`），那是讲义 6.2 节的原版写法。

## 文件

| 文件 | 作用 | 讲义出处 |
| --- | --- | --- |
| `Dockerfile` | 在镜像内编译并发布到 `/attendance` | 改造自 6.2 节 |
| `entrypoint.sh` | 启动前把 Tomcat 端口改成 Render 的 `$PORT` | 6.3 节 |
| `render.yaml` | 一键创建 Web Service 的 Blueprint | — |
| `src/attendance/Attend.java` | Servlet（第 3 题答案：`TreeMap`，名单按学号升序） | 4.5 节 |
| `web/index.html` | 签到表单 | 4.3 节 |
| `web/WEB-INF/web.xml` | 部署描述符，欢迎文件 `index.html` | 4.4 节 |

> `Attend.java` 与讲义原文只差两行：`HashMap` → `TreeMap`（import 与第 27 行字段），
> 这就是第 3 题「让 Attendee List 按学号排序」的答案。

## 部署（约 5 分钟，纯网页操作）

1. **上传到 GitHub**：打开 `https://github.com/HuYihan20070121/attendance`
   → *Add file* → *Upload files* → 把这些拖进去（**保持目录结构**）：
   `Dockerfile`、`entrypoint.sh`、`render.yaml`、`README.md`、`src/`、`web/`
   → *Commit changes*。
   （如果仓库里已有旧的 `Dockerfile`，会被覆盖，这是预期的。）
2. **创建服务**，二选一：
   - Blueprint：`https://dashboard.render.com/blueprints` → *New Blueprint Instance* →
     选 `attendance` 仓库 → 它会按 `render.yaml` 建好（名字 `attend95584`、Free、Singapore）。
   - 手动：Dashboard → *New +* → *Web Service* → 选仓库 →
     Name `attend95584`、Region Singapore、Runtime Docker（自动识别）、
     Branch `main`、Instance Type **Free** → *Create Web Service*。
3. 等日志出现 `Live`（首次构建 3–8 分钟，日志里能看到 `--- deployed ---` 和编译产物）。
4. 打开验证：

| 地址 | 期望 |
| --- | --- |
| `https://attend95584.onrender.com/attendance/` | 出现 Student Id / Seat Id 表单 |
| 提交 `001` / `A1` | `001:A1 is recorded:` |
| 点 *Attendee List* | `001 : A1`，且多条记录按学号升序 |
| 学号留空提交 | `Student Id can not be blank` |

## 注意

- **只提交 `/attendance/` 这个地址。** 镜像删除了 `webapps/ROOT`，所以域名根路径
  `https://attend95584.onrender.com/` 会返回 404 —— 这是讲义的部署方式决定的，不是故障。
- 免费实例闲置 15 分钟休眠，下次请求约需 1 分钟唤醒；第一次打开慢或短暂 502 属正常。
- 记录存在 JVM 的静态 `Map` 里，重启/重新部署即清空（讲义 11.1 节已说明）。
