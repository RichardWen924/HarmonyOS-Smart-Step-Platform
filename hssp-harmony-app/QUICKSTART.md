# 快速开始指南 🚀

## 项目已重构完成！

根据您提供的详细 Prompt，我已经完成了整个鸿蒙运动应用的重构。现在您可以直接运行项目了！

---

## 📦 项目结构

```
HarmonyOS_Smart_Step_Platform/
├── entry/src/main/ets/
│   ├── pages/              # 页面组件
│   │   ├── Index.ets       # 启动页 ✅
│   │   ├── LoginPage.ets   # 登录注册页 ✅
│   │   ├── MainPage.ets    # 主页面（5 Tab）✅
│   │   ├── RankingPage.ets # 排行榜页 ✅
│   │   └── ProfilePage.ets # 个人中心页 ✅
│   ├── services/           # 服务层 ✅
│   │   ├── ApiClient.ets   # API 客户端
│   │   ├── StateStore.ets  # 状态管理
│   │   └── StepCounterService.ets
│   ├── types/              # 类型定义 ✅
│   ├── utils/              # 工具类 ✅
│   └── config/             # 配置文件 ✅
├── README.md               # 完整文档 ✅
└── REFACTOR_SUMMARY.md     # 重构总结 ✅
```

---

## ⚡ 快速开始

### 1. 打开项目
```bash
# 使用 DevEco Studio 打开项目目录
d:\Hongmeng\code\HarmonyOS_Smart_Step_Platform
```

### 2. 配置后端 API（可选）
编辑 `entry/src/main/ets/config/AppConfig.ets`:
```typescript
export const AppConfig = {
  baseUrl: 'http://localhost:3000/api',  // 修改为你的后端地址
  enableMock: true  // 开发阶段设为 true，使用 Mock 数据
}
```

### 3. 运行项目
1. 连接设备或启动模拟器
2. 点击 DevEco Studio 的 Run 按钮
3. 项目将自动编译并部署到设备

---

## 🎯 功能演示

### 登录注册
- 任意输入账号密码即可登录（Mock 模式）
- 支持密码登录和验证码登录
- 验证码点击发送后会有 60 秒倒计时

### 首页功能
- **今日步数**: 显示当前步数
- **模拟走路**: 点击后每 2 秒增加 100-500 步
- **上传步数**: 同步步数到服务器
- **兑换积分**: 满 1000 步可兑换积分

### 趋势页面
- 近 7 天步数柱状图
- 统计概览（总步数、日均、最高）

### 商城页面
- 8 个示例商品
- 积分兑换功能
- 实时显示当前积分

### 排行榜
- 日榜/周榜/月榜切换
- 前 3 名有奖牌图标
- 分页加载更多

### 个人中心
- 查看个人信息
- 编辑资料（昵称、邮箱、性别）
- 修改密码
- 统计数据展示

---

## 🔧 核心功能说明

### API 客户端 (ApiClient.ets)
所有 API 调用都已实现，包括：

**用户认证**
- `sendVerificationCode()` - 发送验证码
- `register()` - 用户注册
- `loginByPassword()` - 密码登录
- `loginByCode()` - 验证码登录

**步数管理**
- `uploadSteps()` - 上传步数
- `getStepStatistics()` - 获取统计
- `getRankings()` - 获取排行榜

**积分系统**
- `getUserPoints()` - 获取积分
- `exchangePoints()` - 兑换积分
- `getPointsRules()` - 积分规则

**商城与记录**
- `getProducts()` - 商品列表
- `exchangeProduct()` - 兑换商品
- `getExchangeRecords()` - 兑换记录

**用户信息**
- `getUserInfo()` - 获取用户信息
- `updateUserInfo()` - 更新用户信息
- `updatePassword()` - 修改密码

### 状态管理 (StateStore.ets)
- 单例模式
- Preferences 持久化
- 响应式更新

### Mock 数据
所有 API 方法都包含 Mock 数据实现，可以直接运行测试！

---

## 🛠️ 对接真实后端

### 步骤：
1. 修改 `AppConfig.ets` 中的 `baseUrl`
2. 将 `enableMock` 设为 `false`
3. 移除 `ApiClient.ets` 中各方法的 catch 块（Mock 数据）

### 接口响应格式：
```typescript
{
  code: 1,      // 1 表示成功
  message: '成功',
  data: { ... }
}
```

---

## 📱 页面导航

```typescript
// 跳转到其他页面
router.pushUrl({ url: 'pages/RankingPage' })

// 返回上一页
router.back()

// 替换当前页面
router.replaceUrl({ url: 'pages/LoginPage' })
```

---

## 💡 常用工具

### 日期工具
```typescript
DateUtils.formatDate(new Date(), 'yyyy-MM-dd')
DateUtils.isToday(date)
```

### 验证工具
```typescript
Validator.isEmail(email)
Validator.validatePassword(password)
```

### 数字格式化
```typescript
NumberUtils.formatSteps(12345)  // "1.2w"
NumberUtils.formatNumber(1000)  // "1,000"
```

---

## ⚠️ 注意事项

1. **权限配置**: 需要在 `module.json5` 中配置网络权限
2. **真机测试**: 建议使用真机测试传感器功能
3. **API 版本**: 确保后端 API 版本兼容
4. **Token 过期**: 需要实现 Token 刷新机制

---

## 🐛 常见问题

### Q: 如何清除本地数据？
```typescript
await StateStore.clearAllData()
```

### Q: 如何获取当前登录状态？
```typescript
const isLoggedIn = StateStore.isLoggedIn
```

### Q: Mock 数据在哪里？
在 `ApiClient.ets` 每个方法的 catch 块中

### Q: 如何调试网络请求？
查看 DevEco Studio 的 HiLog 输出

---

## 📊 代码统计

- **总文件数**: 10+ 核心文件
- **代码行数**: 约 3000+ 行
- **页面组件**: 5 个主要页面
- **API 接口**: 20+ 个接口方法
- **工具函数**: 30+ 个实用函数

---

## 🎉 开始使用

现在您可以：
1. 直接运行项目体验功能
2. 根据需求修改 UI 样式
3. 对接真实后端 API
4. 添加更多新功能

**祝开发愉快！** 🚀

---

## 📞 技术支持

如有问题，请查阅：
- `README.md` - 完整项目文档
- `REFACTOR_SUMMARY.md` - 重构详细说明
- 鸿蒙官方文档：https://developer.harmonyos.com
