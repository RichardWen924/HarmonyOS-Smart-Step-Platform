# 🚶‍♂️ HarmonyOS智能步数平台

> 一个基于HarmonyOS的智能运动健康应用，提供步数记录、积分兑换、排行榜等功能

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-3.0.0-blue)
![ArkTS](https://img.shields.io/badge/ArkTS-TypeScript-green)
![Build](https://img.shields.io/badge/Build-Passing-success)

## ✨ 特性

### 🎯 核心功能
- **智能步数记录** - 支持系统步数传感器集成
- **积分兑换系统** - 步数兑换积分，积分兑换商品
- **用户排行榜** - 实时步数排名和成就展示
- **健康数据分析** - 趋势图表和个性化建议

### 🎨 用户体验
- **精美界面设计** - 统一的HarmonyOS设计语言
- **流畅交互体验** - 优化的动画和响应速度
- **多主题支持** - 适配不同使用场景
- **离线功能** - 网络异常时的数据保护

### 🔧 技术特色
- **模块化架构** - 清晰的代码组织和组件复用
- **类型安全** - 完整的TypeScript类型定义
- **状态管理** - 统一的状态管理和数据持久化
- **Mock数据** - 完整的开发测试支持

## 🚀 快速开始

### 环境要求
- HarmonyOS SDK 6.0.2(22) 或更高版本
- DevEco Studio 最新版本
- 支持HarmonyOS的设备或模拟器

### 安装步骤
1. **克隆项目**
   ```bash
   git clone <项目地址>
   cd HarmonyOS_Smart_Step_Platform
   ```

2. **导入项目**
   - 打开DevEco Studio
   - 选择 "Open" 或 "Import Project"
   - 选择项目根目录

3. **配置环境**
   - 项目已预配置所有必要权限
   - 无需额外配置即可运行

4. **运行项目**
   - 连接设备或启动模拟器
   - 点击 "Run" 按钮
   - 等待应用安装完成

### 测试账号
在Mock模式下可以使用以下测试账号：
- **邮箱**: `test@example.com`
- **密码**: `password123`

## 📱 功能演示

### 基础功能流程
1. **首次启动** → 登录页面
2. **登录/注册** → 使用测试账号或注册新用户
3. **主页面** → 查看步数、积分、排行榜
4. **个人中心** → 管理用户信息和设置

### 高级功能体验
1. **趋势分析** → 查看步数趋势图表
2. **API测试** → 测试所有后端接口
3. **状态管理** → 体验数据持久化

## 🏗️ 项目结构

```
entry/src/main/ets/
├── pages/                 # 页面组件
│   ├── LoginPage.ets      # 登录页面
│   ├── MainPage.ets       # 主页面
│   ├── ProfilePage.ets    # 个人中心
│   ├── RankingPage.ets    # 排行榜
│   ├── TrendPage.ets      # 趋势分析
│   ├── RecordPage.ets     # 兑换记录
│   ├── TestBackendPage.ets # 后端测试
│   └── APITestPage.ets    # API功能测试
├── services/              # 服务层
│   ├── ApiClient.ets      # API客户端
│   ├── StateStore.ets     # 状态管理
│   └── StepCounterService.ets # 步数服务
├── config/                # 配置
│   ├── AppConfig.ets      # 应用配置
│   ├── DesignSystem.ets   # 设计系统
│   └── AppShadows.ets     # 阴影配置
├── types/                 # 类型定义
│   └── common.ets         # 通用类型
└── utils/                 # 工具类
    └── CommonUtils.ets    # 通用工具
```

## ⚙️ 配置说明

### 应用配置 (AppConfig.ets)
```typescript
// 开发模式配置
baseUrl: 'https://api.example.com'  // API地址
enableMock: true                    // Mock数据开关
timeout: 10000                     // 请求超时
enableLog: true                    // 日志开关
```

### 切换到生产环境
1. 修改 `AppConfig.ets` 中的配置
2. 设置 `enableMock: false`
3. 配置真实的后端API地址

## 🔍 开发指南

### 添加新页面
1. 在 `pages/` 目录创建新页面组件
2. 在 `main_pages.json` 中添加路由
3. 更新导航逻辑

### 添加新API
1. 在 `ApiClient.ets` 中添加接口方法
2. 在 `types/common.ets` 中定义数据类型
3. 在相关页面中调用接口

### 自定义主题
1. 修改 `DesignSystem.ets` 中的设计变量
2. 更新颜色、字体、间距等配置
3. 重新构建应用

## 🐛 故障排除

### 常见问题

**Q: 应用启动失败**
A: 检查设备连接和HarmonyOS版本兼容性

**Q: 网络请求失败**
A: Mock模式下无需网络，真实模式检查网络连接

**Q: 页面跳转异常**
A: 检查路由配置和页面注册

**Q: 步数数据不更新**
A: 当前为模拟数据，需要集成真实传感器

### 调试技巧
- 查看控制台日志获取详细错误信息
- 使用API测试页面验证接口功能
- 检查网络请求状态和响应数据

## 📚 文档资源

- [项目状态报告](PROJECT_STATUS_REPORT.md) - 详细的项目状态说明
- [开发计划](DEVELOPMENT_PLAN.md) - 后续开发路线图
- [功能演示指南](FEATURE_DEMO.md) - 完整的功能演示流程
- [快速启动指南](QUICK_START_GUIDE.md) - 快速上手指南
- [项目总结](PROJECT_SUMMARY.md) - 完整的技术总结

## 🤝 贡献指南

我们欢迎任何形式的贡献！

### 贡献流程
1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范
- 遵循 TypeScript 最佳实践
- 使用统一的代码风格
- 添加必要的注释和文档
- 确保所有测试通过

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🏆 致谢

感谢所有为这个项目做出贡献的开发者！

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐️ 支持一下！**

[报告问题](https://github.com/your-repo/issues) • [提出建议](https://github.com/your-repo/issues) • [联系我们](mailto:your-email@example.com)

</div>