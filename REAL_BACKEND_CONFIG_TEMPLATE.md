# 🔗 真实后端连接配置指南

## 📋 配置信息收集表

请填写以下信息：

### 1. 基础信息
- [ ] **后端服务器地址**: _________________________
  - 示例: `http://localhost:8080` 或 `https://api.example.com`
- [ ] **API基础路径**: _________________________
  - 示例: `/api` 或 `/v1`

### 2. 认证信息
- [ ] **认证方式**: □ JWT Token □ OAuth □ 其他: _________
- [ ] **Token前缀**: □ Bearer □ 其他: _________

### 3. API端点结构
请确认您的后端是否支持以下端点：

#### 认证相关
- [ ] `POST /auth/login` - 密码登录
- [ ] `POST /auth/login-by-code` - 验证码登录
- [ ] `POST /auth/register` - 用户注册
- [ ] `POST /auth/send-code` - 发送验证码

#### 用户相关
- [ ] `GET /user/info` - 获取用户信息
- [ ] `PUT /user/info` - 更新用户信息
- [ ] `PUT /user/password` - 修改密码

#### 步数相关
- [ ] `POST /steps/upload` - 上传步数
- [ ] `GET /steps/statistics` - 获取步数统计

#### 排行榜相关
- [ ] `GET /ranking/daily` - 日榜
- [ ] `GET /ranking/weekly` - 周榜
- [ ] `GET /ranking/monthly` - 月榜

#### 积分兑换
- [ ] `POST /exchange/points` - 步数兑换积分
- [ ] `GET /exchange/records` - 获取兑换记录

### 4. 请求/响应格式

#### 请求头
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

#### 响应格式
```typescript
interface ApiResponse<T> {
  code: number;    // 1=成功, 其他=错误
  message: string; // 响应消息
  data?: T;        // 响应数据
}
```

## 🔧 快速配置

### 如果您已有可用的后端服务：

1. **修改 AppConfig.ets**
```typescript
// API 基础地址
baseUrl: string = '您的后端地址/api'

// 关闭Mock模式
enableMock: boolean = false
```

2. **测试连接**
使用网络诊断工具验证连接状态

### 如果您需要创建后端：

我也可以为您提供一个简单的后端服务示例。

## 📞 技术支持

### 常见配置问题
- **CORS问题**: 确保后端配置了正确的跨域设置
- **HTTPS证书**: 如果使用HTTPS，确保证书有效
- **防火墙**: 检查端口是否开放
- **网络权限**: 确认应用有网络访问权限

### 调试工具
- 使用网络诊断页面
- 查看控制台日志
- 使用API测试功能

---

💡 **请提供您的后端信息，我将帮您完成配置！**