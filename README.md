# HSSP (HarmonyOS & Smart Step Platform)

## 项目结构说明

在根目录下包含以下核心工程及目录：

- **/hssp-backend** (后端父工程)：基于 Maven 多模块管理
  - `hssp-common`：公共模块（Result封装、Swagger、异常处理、工具类 等）
  - `hssp-model`：模型模块（POJO、DTO、VO）
  - `hssp-service`：业务启动模块（当前阶段作为单体运行，内置所有业务逻辑）
  - `hssp-gateway` & `hssp-feign-api`：现阶段预留，未来接入 Nacos/微服务使用

- **/hssp-web-admin**：Web 管理端文件夹（技术栈：Vue 3 + Element Plus）
- **/hssp-harmony-app**：鸿蒙移动端文件夹（技术栈：ArkTS + ArkUI）
- **/hssp-docs**：存放开发文档及设计说明文件

## 5 人协作分工指引

团队成员请在各自负责的独立文件夹内进行开发和提交：

- **一人**：维护 `/hssp-backend/hssp-parent` 和 `/hssp-backend/hssp-common`。作为技术底座支撑，提供局域网环境测试并公布接口地址。
- **一人**：在 `/hssp-backend/hssp-service` 中编写业务的 Controller 和 Service 等逻辑。
- **一人**：在 `/hssp-backend/hssp-model` 中定义各种实体对象，并在 `/hssp-docs` 维护相应的接口文档和设计图。
- **一人**：在 `/hssp-web-admin` 文件夹内进行 Vue 的前端开发。联调时将 `baseUrl` 指向组长提供的机器局域网 IP。
- **一人**：在 `/hssp-harmony-app` 内进行鸿蒙原生应用的开发，通过真机或模拟器连接并调试组长机器上的 IP 接口。

## 局域网联调指南

后端通过在 `application.yml` 设置 `server.address: 0.0.0.0` 支持了局域网泛解析调用。

### 如何联调？
1. **组长获取并公布 IP**：
   - Mac/Linux 用户终端执行：`ifconfig` 或 `ipconfig getifaddr en0`。
   - Windows 用户终端执行：`ipconfig`，找到对应网卡的 IPv4 地址。
   - 组长本地启动 `/hssp-service` 下的 `HsspApplication`。

2. **跨平台跨设备测试**：
   组内其他成员（甚至手机连接同一 WiFi 时），可通过以下方式验证后端可用性：
   - 访问 `http://192.168.59.155:8081/hello`
   - 预期返回状态码 `200` 及 JSON 数据：`{"code": 200, "msg": "HSSP服务器已启动"}`

## Git 协作规范
项目中已经生成过跨边界的全局配置，请遵循以下规范：
- 我们已在 `.gitattributes` 中设置了 `* text=auto eol=lf`（已解决 Mac 与 Win 换行符的巨型冲突）。请**切勿自行删除**。
- 我们已设定完整的 `.gitignore`，过滤掉了各类无用依赖与编译目录（如 `target`, `node_modules` 等）。
