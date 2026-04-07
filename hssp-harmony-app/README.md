# 鸿蒙运动应用 - Smart Step Platform

## 项目概述

这是一个基于 **HarmonyOS + ArkTS** 开发的运动主题移动应用，主要功能包括：
- 📊 步数统计与趋势分析
- 🏆 步数排行榜（日榜/周榜/月榜）
- 💰 积分系统与商城兑换
- 👤 用户中心与个人信息管理

## 技术栈

- **开发环境**: DevEco Studio
- **语言**: ArkTS（声明式 UI）
- **状态管理**: @State / @Observed / AppStorage
- **网络请求**: @ohos.net.http
- **数据持久化**: @ohos.data.preferences
- **路由导航**: @ohos.router

## 项目结构

```
entry/src/main/ets/
├── pages/                  # 页面组件
│   ├── Index.ets          # 启动页
│   ├── LoginPage.ets      # 登录注册页
│   ├── MainPage.ets       # 主页面（5 个 Tab）
│   ├── RankingPage.ets    # 排行榜页
│   └── ProfilePage.ets    # 个人中心页
├── services/               # 服务层
│   ├── ApiClient.ets      # API 客户端
│   ├── StateStore.ets     # 状态管理
│   └── StepCounterService.ets  # 步数计数服务
├── types/                  # 类型定义
│   └── common.ets         # 通用类型接口
├── utils/                  # 工具类
│   └── CommonUtils.ets    # 常用工具函数
└── config/                 # 配置文件
    └── AppConfig.ets      # 应用配置
```

## 功能特性

### 1. 用户认证
- ✅ 邮箱注册
- ✅ 密码登录 / 验证码登录
- ✅ 发送验证码
- ✅ 自动登录（Token 持久化）

### 2. 步数管理
- ✅ 今日步数展示
- ✅ 模拟走路（随机增加步数）
- ✅ 手动上传步数
- ✅ 步数趋势图表（近 7 天）
- ✅ 自动同步（每日 22:00）

### 3. 积分系统
- ✅ 步数兑换积分（100 步 = 1 积分）
- ✅ 积分查询
- ✅ 积分规则展示
- ✅ 每日兑换限制

### 4. 排行榜
- ✅ 日榜 / 周榜 / 月榜
- ✅ 分页加载
- ✅ 我的排名展示
- ✅ 前 3 名奖牌图标

### 5. 积分商城
- ✅ 商品列表
- ✅ 积分兑换
- ✅ 库存显示
- ✅ 兑换记录

### 6. 个人中心
- ✅ 个人信息编辑（昵称/邮箱/性别）
- ✅ 修改密码
- ✅ 统计数据展示
- ✅ 退出登录

## API 接口对接

### 后端接口地址
在 `config/AppConfig.ets` 中配置：
```typescript
export const AppConfig = {
  baseUrl: 'http://localhost:3000/api'
}
```

### 主要接口列表

#### 用户认证
- `POST /send-verification` - 发送验证码
- `POST /register` - 用户注册
- `POST /login` - 用户登录

#### 步数管理
- `POST /user/steps` - 上传步数
- `GET /user/steps/statistics?days=7` - 获取步数统计
- `GET /user/rankings?periodType=day` - 获取排行榜

#### 积分系统
- `GET /user/points` - 获取积分
- `POST /user/exchange` - 兑换积分
- `GET /user/rules` - 获取积分规则

#### 商城与记录
- `GET /mall/products?page=1&pageSize=10` - 商品列表
- `POST /mall/exchange` - 兑换商品
- `GET /user/exchange-records` - 兑换记录

#### 用户信息
- `GET /user` - 获取用户信息
- `PUT /user` - 更新用户信息
- `PUT /user/password` - 修改密码

### 接口响应格式
所有接口统一返回格式：
```typescript
{
  code: number,      // 1: 成功，其他：失败
  message: string,   // 响应消息
  data: any         // 响应数据
}
```

## Mock 数据

当前项目使用 Mock 数据进行开发，位于 `ApiClient.ets` 中。对接真实接口时：

1. 修改 `baseUrl` 为实际地址
2. 将 `enableMock` 设置为 `false`
3. 移除各方法中的 Mock 数据返回逻辑

## 状态管理

### StateStore 单例模式
```typescript
import StateStore from '../services/StateStore'

// 使用示例
const userInfo = await StateStore.getUserInfo()
await StateStore.login(userInfo, token)
await StateStore.logout()
```

### 全局状态
- `isLoggedIn`: 登录状态
- `userInfo`: 用户信息对象
- `todaySteps`: 今日步数
- `totalPoints`: 总积分

## 常用工具

### DateUtils - 日期工具
```typescript
DateUtils.formatDate(new Date(), 'yyyy-MM-dd')
DateUtils.isToday(date)
DateUtils.getRelativeTime(date)
```

### Validator - 数据验证
```typescript
Validator.isEmail(email)
Validator.validatePassword(password)
Validator.validateNickname(nickname)
```

### NumberUtils - 数字格式化
```typescript
NumberUtils.formatSteps(12345)  // "1.2w"
NumberUtils.formatNumber(1000)  // "1,000"
```

## 开发指南

### 1. 环境准备
1. 安装 DevEco Studio 4.0+
2. 配置 HarmonyOS SDK
3. 创建或导入项目

### 2. 运行项目
1. 连接真机或启动模拟器
2. 点击 Run 按钮运行项目
3. 查看日志调试

### 3. 添加新页面
```typescript
// 1. 在 pages/ 目录创建新页面
@Entry
@Component
struct NewPage {
  build() {
    Column() {
      Text('新页面')
    }
  }
}

// 2. 使用 router 跳转
router.pushUrl({
  url: 'pages/NewPage'
})
```

### 4. 调用 API
```typescript
import ApiClient from '../services/ApiClient'

// 调用示例
const response = await ApiClient.getUserPoints()
if (response.code === 1) {
  // 处理成功响应
} else {
  // 处理错误
}
```

## 构建发布

### 调试版本
```bash
npm run debug
```

### 发布版本
```bash
npm run release
```

## 常见问题

### Q: 如何修改 API 地址？
A: 编辑 `config/AppConfig.ets` 文件中的 `baseUrl`

### Q: Mock 数据在哪里？
A: `services/ApiClient.ets` 中每个方法的 catch 块内

### Q: 如何清除本地数据？
A: 调用 `StateStore.clearAllData()`

### Q: 自动同步如何实现？
A: 使用 `@ohos.backgroundTaskManager` 在后台定时任务中调用同步接口

## 后续优化

- [ ] 接入真实传感器数据
- [ ] 添加健康 Kit 集成
- [ ] 实现后台自动同步
- [ ] 增加图表库（折线图/饼图）
- [ ] 社交分享功能
- [ ] 成就系统
- [ ] 消息推送
- [ ] 多语言支持

## 开发者

如有问题请联系开发团队或提交 Issue。

## 许可证

Apache License 2.0
