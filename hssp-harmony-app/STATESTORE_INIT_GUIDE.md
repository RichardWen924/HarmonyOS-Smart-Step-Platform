# StateStore 初始化指南

## 问题说明

之前的代码使用 `globalThis.context` 会导致 ArkTS 编译错误，因为 ArkTS 不支持直接访问 `globalThis` 的属性。

## 解决方案

已将 `StateStore` 重构为**显式初始化模式**：

### 修改内容

1. **移除构造函数中的自动初始化**
   - 之前：`private constructor() { this.initPreferences() }`
   - 现在：构造函数不再初始化 preferences

2. **新增 `initialize()` 方法**
   ```typescript
   async initialize(context: Context): Promise<boolean>
   ```
   - 需要外部传入 context
   - 返回初始化是否成功
   - 自动加载已保存的数据

3. **添加初始化检查**
   - 所有使用 preferences 的方法都会检查是否已初始化
   - 未初始化时会返回默认值或 false

---

## 使用方法

### 在 EntryAbility 中初始化（推荐）

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets
import StateStore from '../services/StateStore'

export default class EntryAbility extends Ability {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.info('EntryAbility onCreate')
    
    // 初始化 StateStore（必须在应用启动时调用）
    const context = this.context
    const success = await StateStore.getInstance().initialize(context)
    
    if (success) {
      console.info('StateStore initialized successfully')
    } else {
      console.error('Failed to initialize StateStore')
    }
  }
}
```

### 在页面中使用

```typescript
// 在任意页面中
import StateStore from '../services/StateStore'

@Entry
@Component
struct Index {
  private stateStore = StateStore.getInstance()
  
  aboutToAppear() {
    // 可以直接使用 stateStore 的方法
    this.loadUserData()
  }
  
  async loadUserData() {
    const userInfo = await this.stateStore.getUserInfo()
    const stepData = await this.stateStore.getStepData()
    // ... 使用数据
  }
}
```

---

## API 变更总结

| 旧方法 | 新方法 | 说明 |
|-------|--------|------|
| `initPreferences()` | `initialize(context: Context)` | 需要传入 context |
| 构造函数自动初始化 | 手动调用 `initialize()` | 更灵活的控制 |
| 无初始化检查 | `ensureInitialized()` | 自动检查初始化状态 |

---

## 注意事项

⚠️ **重要**：
1. 必须在应用启动时（如 EntryAbility.onCreate）调用 `initialize()`
2. 所有异步方法都会在未初始化时返回默认值
3. `initialize()` 可以多次调用，但只有第一次会真正初始化

---

## 优势

✅ **类型安全**：不再使用 `globalThis.context`，符合 ArkTS 规范  
✅ **解耦设计**：StateStore 不依赖全局变量，更易测试  
✅ **明确生命周期**：初始化时机由开发者控制  
✅ **错误处理**：未初始化时有明确的日志提示  

---

## 示例代码

完整的 EntryAbility 示例：

```typescript
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import StateStore from '../services/StateStore'

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    console.info('EntryAbility onCreate')
    
    try {
      // 初始化 StateStore
      const success = await StateStore.getInstance().initialize(this.context)
      
      if (success) {
        console.info('✓ StateStore initialized')
        
        // 验证是否可以读取数据
        const userInfo = await StateStore.getInstance().getUserInfo()
        console.info('Current user:', userInfo.nickname)
      }
    } catch (error) {
      console.error('✗ StateStore initialization failed:', error)
    }
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    console.info('EntryAbility onWindowStageCreate')
    
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load content:', JSON.stringify(err))
        return
      }
      console.info('Succeeded in loading content:', JSON.stringify(data))
    })
  }
}
```

---

## 迁移指南

如果您的项目已经在使用 StateStore，需要：

1. **添加初始化代码**：在 EntryAbility 中调用 `initialize()`
2. **移除旧代码**：删除任何尝试获取 `globalThis.context` 的代码
3. **测试功能**：确保所有数据存储和读取功能正常

---

## 常见问题

**Q: 可以在页面中初始化吗？**  
A: 可以，但不推荐。最好在 EntryAbility 中统一初始化。

**Q: 如果忘记初始化会怎样？**  
A: 所有数据操作方法会返回默认值，并输出警告日志。

**Q: 可以多次调用 `initialize()` 吗？**  
A: 可以，但只有第一次会真正执行初始化，后续调用会直接返回 true。

---

**更新日期**: 2024-03-30  
**影响范围**: StateStore.ets 及所有使用该服务的页面
