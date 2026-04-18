# 步数自动清零和积分兑换功能说明

## 一、每日凌晨自动上传步数并清零功能

### 1. 功能概述
系统每天凌晨0点自动执行定时任务，将用户昨天的剩余步数保存到历史记录中，并将今日步数清零。

### 2. 实现细节

#### 2.1 定时任务配置
- **配置类**: `ScheduleConfig.java`
- **位置**: `hssp-service/hssp-user/src/main/java/com/hssp/service/config/ScheduleConfig.java`
- **功能**: 启用Spring Boot的定时任务支持（`@EnableScheduling`）

#### 2.2 定时任务服务
- **服务类**: `StepScheduleTask.java`
- **位置**: `hssp-service/hssp-user/src/main/java/com/hssp/service/task/StepScheduleTask.java`
- **执行时间**: 每天凌晨0点（cron表达式: `0 0 0 * * ?`）

#### 2.3 任务执行流程
1. **查询用户**: 查找所有有剩余步数的用户
2. **保存历史**: 检查昨天是否有步数记录，如果没有则创建昨天的步数记录
3. **清零步数**: 将所有用户的剩余步数（remaining_step）设置为0
4. **清理缓存**: 清理7天前的Redis排行榜数据，保留最近7天的日榜数据

#### 2.4 日志记录
- 记录处理的用户数量
- 记录每个用户的步数保存情况
- 记录异常信息便于排查问题

### 3. 注意事项
- 定时任务在事务中执行，确保数据一致性
- 即使某个用户处理失败，也不影响其他用户的处理
- Redis排行榜数据只保留最近7天，避免占用过多内存

---

## 二、积分兑换功能（从数据库查询规则）

### 1. 功能概述
用户在兑换积分时，系统会从数据库查询激活的积分兑换规则，根据规则计算可获得的积分。

### 2. 实现细节

#### 2.1 积分规则表
- **表名**: `points_rule`
- **字段说明**:
  - `id`: 规则ID（主键）
  - `rule_name`: 规则名称
  - `steps_required`: 需要的步数
  - `points_awarded`: 获得的积分
  - `is_active`: 是否启用（ENABLE/DISABLE）

#### 2.2 核心服务类
- **服务类**: `UserPointsServiceImpl.java`
- **位置**: `hssp-service/hssp-mall/src/main/java/com/hssp/service/mall/service/impl/UserPointsServiceImpl.java`
- **Mapper**: `PointRulesMapper.java`（新增）

#### 2.3 兑换逻辑
1. **查询规则**: 从数据库查询所有启用的积分兑换规则，按所需步数升序排列
2. **应用规则**: 按照步数要求从低到高依次应用所有启用的规则
3. **计算积分**: 
   - 对于每条规则，计算可以兑换的次数
   - 累加所有规则获得的积分
4. **更新积分**: 将计算出的积分添加到用户的总积分和累计积分中

#### 2.4 示例场景

**场景1: 只有基础规则（1000步=1积分）**
- 用户有5000步
- 可兑换: 5000 / 1000 = 5次
- 获得积分: 5 × 1 = 5积分
- 剩余步数: 0

**场景2: 同时启用基础规则和进阶规则**
- 基础规则: 1000步=1积分
- 进阶规则: 5000步=6积分
- 用户有6000步
- 兑换过程:
  1. 先用5000步兑换6积分（进阶规则）
  2. 剩余1000步兑换1积分（基础规则）
  3. 总共获得7积分
- 剩余步数: 0

**场景3: 没有配置规则**
- 如果数据库中没有启用的规则，系统会使用默认规则: 1000步=1积分

### 3. 初始化数据
执行SQL脚本初始化默认的积分兑换规则：
```bash
mysql -u root -p your_database < hssp-backend/sql/init_points_rules.sql
```

### 4. 管理积分规则
可以通过管理后台的接口管理积分规则：
- **查询所有规则**: `GET /admin/points`
- **查询单个规则**: `GET /admin/points/{id}`
- **新增规则**: `POST /admin/points`
- **修改规则**: `PUT /admin/points`
- **删除规则**: `DELETE /admin/points`
- **分页查询**: `GET /admin/points/page?current=1&size=10`

---

## 三、测试建议

### 1. 测试定时任务
#### 方法1: 修改cron表达式进行测试
```java
// 改为每分钟执行一次（仅用于测试）
@Scheduled(cron = "0 * * * * ?")
public void resetDailySteps() {
    // ...
}
```

#### 方法2: 手动触发
创建一个Controller接口手动触发定时任务：
```java
@RestController
@RequestMapping("/test")
public class TestController {
    @Autowired
    private StepScheduleTask stepScheduleTask;
    
    @PostMapping("/reset-steps")
    public Result testResetSteps() {
        stepScheduleTask.resetDailySteps();
        return Result.success("步数清零任务执行成功");
    }
}
```

### 2. 测试积分兑换
1. **准备测试数据**:
   ```sql
   -- 确保有启用的积分规则
   SELECT * FROM points_rule WHERE is_active = 'ENABLE';
   
   -- 确保用户有步数
   SELECT id, username, remaining_step, total_points FROM user WHERE id = 1;
   ```

2. **调用兑换接口**:
   ```bash
   curl -X POST http://localhost:8080/points/exchange \
     -H "Content-Type: application/json" \
     -d '{"steps": 5000}'
   ```

3. **验证结果**:
   ```sql
   -- 检查用户积分是否增加
   SELECT total_points, cumulative_points FROM user_points WHERE user_id = 1;
   
   -- 检查积分兑换日志
   SELECT * FROM points_log WHERE user_id = 1 ORDER BY create_time DESC LIMIT 5;
   ```

---

## 四、常见问题

### Q1: 定时任务没有执行？
**A**: 检查以下几点：
1. 确认`ScheduleConfig`类上有`@EnableScheduling`注解
2. 确认`StepScheduleTask`类上有`@Component`注解
3. 确认方法上有`@Scheduled`注解
4. 查看应用启动日志，确认定时任务已注册

### Q2: 积分兑换时提示"步数不足"？
**A**: 可能的原因：
1. 用户步数少于所有启用规则的最小步数要求
2. 数据库中没有启用的积分规则
3. 检查`points_rule`表中是否有`is_active='ENABLE'`的记录

### Q3: 如何调整定时任务的执行时间？
**A**: 修改`StepScheduleTask`中的cron表达式：
```java
// 每天凌晨2点执行
@Scheduled(cron = "0 0 2 * * ?")

// 每周一凌晨0点执行
@Scheduled(cron = "0 0 0 ? * MON")
```

### Q4: 积分规则可以同时启用多个吗？
**A**: 可以！系统会按照步数要求从低到高依次应用所有启用的规则，这样可以实现阶梯式兑换，给用户更多优惠。

---

## 五、后续优化建议

1. **定时任务优化**:
   - 添加任务执行状态监控
   - 添加任务执行告警机制
   - 考虑使用分布式定时任务框架（如XXL-JOB）

2. **积分兑换优化**:
   - 添加积分兑换上限限制
   - 添加每日兑换次数限制
   - 添加积分有效期机制

3. **性能优化**:
   - 对积分规则进行缓存，减少数据库查询
   - 批量处理用户步数清零，提高执行效率
   - 添加异步处理机制

---

## 六、相关文件清单

### 后端文件
1. `ScheduleConfig.java` - 定时任务配置类
2. `StepScheduleTask.java` - 步数定时任务服务
3. `UserPointsServiceImpl.java` - 积分兑换服务（已修改）
4. `PointRulesMapper.java` - 积分规则Mapper（新增）
5. `init_points_rules.sql` - 积分规则初始化SQL脚本

### 前端文件（无需修改）
- 前端已有的兑换积分功能会自动使用新的规则引擎

---

**完成日期**: 2026-04-12  
**版本**: v1.0.0
