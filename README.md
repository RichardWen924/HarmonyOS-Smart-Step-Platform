# HSSP (HarmonyOS & Smart Step Platform)

## 项目结构说明
⚠️ 开发前置准备
请所有成员执行以下命令，确保 GitHub 能正确统计你的贡献值：
git config --global user.email "你的GitHub绑定邮箱"
git config --global user.name "你的GitHub用户名"
在根目录下包含以下核心工程及目录：

- **/hssp-backend** (后端父工程)：基于 Maven 多模块管理
  - `hssp-common`：公共模块（Result封装、Swagger、异常处理、工具类 等）
  - `hssp-model`：模型模块（POJO、DTO、VO）
  - `hssp-service`：业务启动模块（当前阶段作为单体运行，内置所有业务逻辑）
  - `hssp-gateway` & `hssp-feign-api`：现阶段预留，未来接入 Nacos/微服务使用

- **/hssp-web-admin**：Web 管理端文件夹（技术栈：Vue 3 + Element Plus）
- **/hssp-harmony-app**：鸿蒙移动端文件夹（技术栈：ArkTS + ArkUI）
- **/hssp-docs**：存放开发文档及设计说明文件

## 团队协作分工指引 (5人组合)

当前项目由 5 名开发人员协作完成（2名前端 + 3名后端）。为避免互相干扰，请严格根据职责划分工作区：

- **前端开发人员 x 2**：
  - 一人专职负责鸿蒙客户端开发：`/hssp-harmony-app`
  - 一人专职负责 Web 管理端开发：`/hssp-web-admin`

---

### 后端开发协作划分 (3名后端人员)

由于当前业务均集中在 `/hssp-backend/hssp-service` 单体结构中，3 名后端开发需遵循 Controller/Service 包级隔离。团队共同维护 `hssp-common` (公共组件) 和 `hssp-model` (实体类/DTO)。

- **后端开发人员 A (管理端接口)**
  - **职责**：负责所有的管理端业务后端接口（如数据统计、商品审批、内容管理等），并负责与 Web 管理端前端联调。
  - **开发区域**：`/hssp-backend/hssp-service` 内的 Admin 相关业务切片（相关的 `Controller`、`Service`、`Mapper`等）。

- **后端开发人员 B (注册登录与用户中心)**
  - **职责**：负责系统账号注册、登录、鉴权（JWT/Security），及个人中心（如我的收藏、我的数据）接口服务。
  - **开发区域**：`/hssp-backend/hssp-service` 内 Auth、User 相关的包，及负责配置拦截器鉴权代码；需配合双端前端连调。

- **后端开发人员 C (商城与排行榜基建)**
  - **职责**：负责高并发业务板块如商城（商品展示、购买流水）及基于 Redis 实现的实时积分/热度排行榜。
  - **开发区域**：`/hssp-backend/hssp-service` 内 Mall、Rank 相关的包；主导项目内各项缓存策略的落地。

---

## 预留：Redis 连接配置区 (排行榜及商城缓存基建)

供主要负责**开发者 C** 及团队统一接入 Redis 缓存时使用。所有中间件连接配置集中在此处统一管理防冲突：

- 📍 **配置文件路径**：`/hssp-backend/hssp-service/src/main/resources/application.yml`

**推荐的 Redis 配置模板结构** (团队联调时请在服务器上使用隔离的 database 或统一服务 IP)：
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:127.0.0.1} # 组内联调时，请修改为内网提供 Redis 服务的统一机器 IP
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      database: 0 # 建议不同环境使用不同 db
      lettuce:
        pool:
          max-active: 8 # 最大连接数
          max-wait: -1ms # 连接池最大阻塞等待时间
          max-idle: 8
          min-idle: 0
```

## 局域网联调指南

后端通过在 `application.yml` 设置 `server.address: 0.0.0.0` 支持了局域网泛解析调用。

### 如何联调？
1. **组长获取并公布 IP**：
   - Mac/Linux 用户终端执行：`ifconfig` 或 `ipconfig getifaddr en0`。
   - Windows 用户终端执行：`ipconfig`，找到对应网卡的 IPv4 地址。
   - 组长本地启动 `/hssp-service` 下的 `HsspApplication`。

2. **跨平台跨设备测试**：
   组内其他成员（甚至手机连接同一 WiFi 时），可通过以下方式验证后端可用性：
   - 访问 `http://192.168.59.93:8081/hello`
   - 预期返回状态码 `200` 及 JSON 数据：`{"code": 200, "msg": "HSSP服务器已启动"}`

## Git 协作规范
项目中已经生成过跨边界的全局配置，请遵循以下规范：
- 我们已在 `.gitattributes` 中设置了 `* text=auto eol=lf`（已解决 Mac 与 Win 换行符的巨型冲突）。请**切勿自行删除**。
- 我们已设定完整的 `.gitignore`，过滤掉了各类无用依赖与编译目录（如 `target`, `node_modules` 等）。
