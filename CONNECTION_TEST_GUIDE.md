# 🔗 Spring Boot后端连接测试指南

## ✅ 配置状态检查

### 前端配置状态
- ✅ AppConfig已配置为真实后端模式
- ✅ API地址: `http://localhost:8080/api`
- ✅ Mock模式: 已关闭
- ✅ JWT Token处理: 已配置

## 🚀 快速测试步骤

### 步骤1: 启动Spring Boot后端
确保您的Spring Boot应用正在运行：
```bash
# 在Spring Boot项目目录中
mvn spring-boot:run

# 或
java -jar target/your-app.jar
```

**验证后端运行**: 浏览器访问 `http://localhost:8080/api/health` 应该返回JSON响应

### 步骤2: 测试HarmonyOS应用连接

#### 方法一: 使用网络诊断工具
1. 启动HarmonyOS应用
2. 在登录页面点击"测试后端连接"
3. 进入网络诊断页面
4. 运行"完整诊断"

#### 方法二: 直接登录测试
1. 使用您后端已有的账号登录
2. 或注册新用户进行测试

## 🔧 故障排除清单

### 如果连接失败，按顺序检查：

#### 1. 后端服务状态
```bash
# 检查端口8080是否被占用
netstat -ano | findstr :8080

# 检查Spring Boot日志
# 应该看到类似信息:
# Started Application in 2.345 seconds
```

#### 2. CORS配置检查
确保Spring Boot配置了CORS：
```java
// 在CorsConfig中确认配置了允许所有来源
config.addAllowedOrigin("*");
```

#### 3. 网络连通性测试
在HarmonyOS应用中运行网络诊断：
- ✅ 基础网络连接
- ✅ DNS解析测试  
- ❌ API服务器连接（如果失败，说明后端问题）
- ✅ HTTPS连接测试

#### 4. 特殊环境配置
**如果是模拟器环境**：
```typescript
// 修改AppConfig.ets中的地址
baseUrl: string = 'http://10.0.2.2:8080/api'
```

## 📋 完整测试流程

### 测试1: 健康检查
**端点**: `GET /api/health`
**预期响应**: 
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T10:00:00"
}
```

### 测试2: 用户注册
**端点**: `POST /api/auth/register`
**请求数据**:
```json
{
  "email": "test@example.com",
  "password": "password123",
  "verificationCode": "123456",
  "nickname": "测试用户"
}
```

### 测试3: 用户登录
**端点**: `POST /api/auth/login`
**请求数据**:
```json
{
  "account": "test@example.com",
  "password": "password123",
  "loginType": 1
}
```

### 测试4: 获取用户信息
**端点**: `GET /api/user/info`
**要求**: 需要有效的JWT Token

## 🐛 常见错误及解决方案

### 错误1: "Connection refused"
**原因**: 后端服务未启动或端口被占用
**解决**: 
- 检查Spring Boot是否正常运行
- 确认端口8080可用
- 重启后端服务

### 错误2: "CORS policy" 错误
**原因**: 跨域请求被阻止
**解决**: 
- 检查Spring Boot CORS配置
- 确保允许所有HTTP方法
- 重启后端服务

### 错误3: "404 Not Found"
**原因**: API端点路径不匹配
**解决**: 
- 确认后端控制器路径为`/api/**`
- 检查请求URL是否正确
- 验证端点是否存在

### 错误4: "401 Unauthorized"
**原因**: JWT Token无效或过期
**解决**: 
- 检查Token生成逻辑
- 验证Token签名密钥
- 重新登录获取新Token

## 🔍 调试技巧

### 前端调试
1. **查看控制台日志**: 应用中会输出详细的请求信息
2. **使用网络诊断工具**: 提供详细的连接状态信息
3. **检查请求头**: 确认Authorization头是否正确添加

### 后端调试
1. **查看Spring Boot日志**: 确认请求是否到达后端
2. **使用Postman测试**: 直接测试API端点
3. **检查数据库连接**: 确认数据持久化正常

## 📊 测试结果记录

请记录以下测试结果：

### 基础连接测试
- [ ] 后端服务启动成功
- [ ] 健康检查端点响应正常
- [ ] CORS配置正确

### 认证功能测试
- [ ] 用户注册功能正常
- [ ] 用户登录功能正常
- [ ] JWT Token生成和验证正常

### 业务功能测试
- [ ] 获取用户信息正常
- [ ] 步数上传功能正常
- [ ] 排行榜功能正常

## 🎯 成功标志

当看到以下结果时，说明连接成功：

### 网络诊断页面
- ✅ 基础网络连接正常
- ✅ DNS解析正常  
- ✅ API服务器连接正常
- ✅ 诊断总结: 4/4 项测试通过

### 应用功能
- ✅ 可以正常登录/注册
- ✅ 用户信息正确显示
- ✅ 所有页面功能正常使用

---

💡 **提示**: 如果遇到问题，请先运行网络诊断工具，它会提供具体的错误信息和解决方案建议。