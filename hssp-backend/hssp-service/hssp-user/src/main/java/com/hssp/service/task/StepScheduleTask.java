package com.hssp.service.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hssp.model.user.po.StepRecord;
import com.hssp.model.user.po.User;
import com.hssp.service.mapper.StepRecordMapper;
import com.hssp.service.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 步数定时任务服务
 * 每天凌晨自动处理步数数据
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class StepScheduleTask {

    private final UserMapper userMapper;
    private final StepRecordMapper stepRecordMapper;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String DAILY_RANK_KEY_PREFIX = "hssp:rank:daily:";

    /**
     * 每天凌晨0点执行
     * 将昨天的剩余步数清零，但不删除历史记录
     */
    @Scheduled(cron = "0 0 0 * * ?")
    @Transactional(rollbackFor = Exception.class)
    public void resetDailySteps() {
        log.info("========== 开始执行每日步数清零任务 ==========");
        
        try {
            LocalDate yesterday = LocalDate.now().minusDays(1);
            String yesterdayStr = yesterday.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            
            // 1. 查询所有有剩余步数的用户
            List<User> users = userMapper.selectList(
                new LambdaQueryWrapper<User>()
                    .gt(User::getRemainingStep, 0)
            );
            
            log.info("找到 {} 个需要清零步数的用户", users.size());
            
            int processedCount = 0;
            for (User user : users) {
                try {
                    // 2. 检查昨天是否有步数记录，如果没有则创建
                    StepRecord yesterdayRecord = stepRecordMapper.selectOne(
                        new LambdaQueryWrapper<StepRecord>()
                            .eq(StepRecord::getUserId, user.getId())
                            .eq(StepRecord::getRecordDate, yesterday)
                    );
                    
                    if (yesterdayRecord == null && user.getRemainingStep() > 0) {
                        // 如果昨天没有记录但有剩余步数，创建昨天的记录
                        StepRecord newRecord = new StepRecord();
                        newRecord.setUserId(user.getId());
                        newRecord.setRecordDate(yesterday);
                        newRecord.setStepCount(user.getRemainingStep());
                        newRecord.setLastUploadTime(LocalDateTime.now());
                        stepRecordMapper.insert(newRecord);
                        
                        log.info("为用户 {} 创建昨天的步数记录: {} 步", 
                            user.getId(), user.getRemainingStep());
                    }
                    
                    // 3. 将用户的剩余步数清零（为今天做准备）
                    user.setRemainingStep(0);
                    userMapper.updateById(user);
                    
                    processedCount++;
                    
                } catch (Exception e) {
                    log.error("处理用户 {} 的步数清零失败", user.getId(), e);
                }
            }
            
            // 4. 清理过期的Redis排行榜数据（保留最近7天）
            cleanupExpiredRedisRankings();
            
            log.info("========== 每日步数清零任务完成，共处理 {} 个用户 ==========", processedCount);
            
        } catch (Exception e) {
            log.error("每日步数清零任务执行失败", e);
        }
    }
    
    /**
     * 清理过期的Redis排行榜数据
     * 保留最近7天的日榜数据
     */
    private void cleanupExpiredRedisRankings() {
        try {
            LocalDate today = LocalDate.now();
            
            // 清理7天前的日榜数据
            for (int i = 7; i <= 30; i++) {
                LocalDate oldDate = today.minusDays(i);
                String oldKey = DAILY_RANK_KEY_PREFIX + 
                    oldDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
                
                Boolean exists = redisTemplate.hasKey(oldKey);
                if (Boolean.TRUE.equals(exists)) {
                    redisTemplate.delete(oldKey);
                    log.info("清理过期Redis排行榜: {}", oldKey);
                }
            }
        } catch (Exception e) {
            log.error("清理过期Redis排行榜失败", e);
        }
    }
}
