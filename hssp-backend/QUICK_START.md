# 快速开始指南

## 🚀 5分钟快速体验新功能

### 第一步：初始化数据库

```bash
# 进入SQL目录
cd hssp-backend/sql

# 执行积分规则初始化脚本
mysql -u root -p your_database < init_points_rules.sql
```

或者手动执行SQL：
```sql
INSERT INTO `points_rule` (`rule_name`, `steps_required`, `points_awarded`, `is_active`) 
VALUES 
('基础兑换规则', 1000, 1, 'ENABLE');
```

### 第二步：启动后端服务

```bash
# 进入后端目录
cd hssp-backend

# 编译项目
mvn clean install -DskipTests

# 启动用户服务（包含定时任务）
cd hssp-service/hssp-user
mvn spring-boot:run

# 启动商城服务（包含积分兑换）
# 在另一个终端
cd hssp-service/hssp-mall
mvn spring-boot:run
```

### 第三步：测试功能

#### 测试1: 手动触发步数清零任务

```bash
curl -X POST http://localhost:8080/test/reset-steps
```

预期响应：
```json
{
  "code": 1,
  "msg": "步数清零任务执行成功",
  "data": null
}
```

查看日志确认：
```
INFO ... : ========== 开始执行每日步数清零任务 ==========
INFO ... : 找到 X 个需要清零步数的用户
INFO ... : ========== 每日步数清零任务完成，共处理 X 个用户 ==========
```

#### 测试2: 积分兑换

首先确保用户有步数：
```sql
-- 设置测试用户的步数
UPDATE user SET remaining_step = 5000 WHERE id = 1;
```

然后调用兑换接口：
```bash
curl -X POST http://localhost:8081/points/exchange \
  -H "Content-Type: application/json" \
  -d '{"steps": 5000}'
```

注意：端口号根据实际配置调整（可能是8080或其他）

预期响应：
```json
{
  "code": 1,
  "msg": "兑换积分成功",
  "data": null
}
```

验证积分是否增加：
```sql
SELECT user_id, total_points, cumulative_points 
FROM user_points 
WHERE user_id = 1;
```

---

## 🔧 配置说明

### 修改定时任务执行时间

编辑文件：`StepScheduleTask.java`

```java
// 当前配置：每天凌晨0点执行
@Scheduled(cron = "0 0 0 * * ?")

// 测试配置：每分钟执行一次（仅用于测试）
@Scheduled(cron = "0 * * * * ?")

// 其他常用配置：
// 每天凌晨2点：@Scheduled(cron = "0 0 2 * * ?")
// 每周一凌晨0点：@Scheduled(cron = "0 0 0 ? * MON")
// 每月1号凌晨0点：@Scheduled(cron = "0 0 0 1 * ?")
```

### 添加更多积分规则

```sql
-- 添加进阶规则（更优惠）
INSERT INTO `points_rule` (`rule_name`, `steps_required`, `points_awarded`, `is_active`) 
VALUES ('进阶兑换规则', 5000, 6, 'ENABLE');

-- 添加高级规则（最优惠）
INSERT INTO `points_rule` (`rule_name`, `steps_required`, `points_awarded`, `is_active`) 
VALUES ('高级兑换规则', 10000, 15, 'ENABLE');
```

启用多个规则后，系统会自动按最优方式计算积分。

---

## 📊 监控和日志

### 查看定时任务日志

```bash
# 查看应用日志
tail -f hssp-user/logs/application.log | grep "步数清零"
```

关键日志：
- `========== 开始执行每日步数清零任务 ==========`
- `找到 X 个需要清零步数的用户`
- `为用户 XXX 创建昨天的步数记录: XXXX 步`
- `========== 每日步数清零任务完成，共处理 X 个用户 ==========`

### 查看积分兑换日志

```bash
tail -f hssp-mall/logs/application.log | grep "兑换"
```

关键日志：
- `应用规则: XXX, 需要步数: XXX, 获得积分: XXX, 兑换次数: X`
- `用户 XXX 兑换步数: XXX, 获得积分: XXX, 剩余步数: XXX`

---

## ❓ 常见问题

### Q1: 定时任务没有执行？

**检查清单**:
1. ✅ 确认`ScheduleConfig`类存在且有`@EnableScheduling`注解
2. ✅ 确认`StepScheduleTask`类有`@Component`注解
3. ✅ 查看启动日志，确认定时任务已注册
4. ✅ 确认应用正常运行，没有被暂停或停止

### Q2: 积分兑换失败？

**可能原因**:
1. 用户步数不足
2. 没有启用的积分规则
3. 数据库连接问题

**解决方法**:
```sql
-- 检查是否有启用的规则
SELECT * FROM points_rule WHERE is_active = 'ENABLE';

-- 检查用户步数
SELECT id, username, remaining_step FROM user WHERE id = 1;

-- 如果没有规则，执行初始化脚本
source hssp-backend/sql/init_points_rules.sql;
```

### Q3: 如何禁用测试接口？

**方法1**: 删除TestController.java文件

**方法2**: 使用Profile控制
```java
@RestController
@RequestMapping("/test")
@Profile("dev")  // 只在开发环境启用
public class TestController {
    // ...
}
```

然后在生产环境使用：
```bash
java -jar app.jar --spring.profiles.active=prod
```

---

## 🎯 下一步

1. **查看详细文档**: `FEATURE_IMPLEMENTATION_GUIDE.md`
2. **了解实现细节**: `IMPLEMENTATION_SUMMARY.md`
3. **管理积分规则**: 使用管理后台接口或数据库直接操作
4. **监控系统运行**: 查看日志和数据库变化

---

## 📞 需要帮助？

如果遇到问题：
1. 查看日志文件，寻找错误信息
2. 检查数据库连接和配置
3. 参考详细文档 `FEATURE_IMPLEMENTATION_GUIDE.md`
4. 确认所有依赖都已正确安装

---

**祝使用愉快！** 🎉
