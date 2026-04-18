-- 测试数据：插入多个用户和步数记录，用于测试排行榜功能
USE step_counter_db;

-- 插入测试用户（如果不存在）
INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) VALUES
('testuser1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test1@example.com', '张三', 1, 100, 15000, 15000, 15000),
('testuser2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test2@example.com', '李四', 2, 80, 12000, 12000, 12000),
('testuser3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test3@example.com', '王五', 1, 150, 20000, 20000, 20000),
('testuser4', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test4@example.com', '赵六', 2, 50, 8000, 8000, 8000),
('testuser5', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test5@example.com', '孙七', 1, 200, 25000, 25000, 25000)
ON DUPLICATE KEY UPDATE `nickname`=VALUES(`nickname`);

-- 获取用户ID（假设自增ID从1开始，根据实际情况调整）
-- 注意：以下SQL中的user_id需要根据实际插入后的ID进行调整

-- 插入今日步数记录（使用当前日期）
INSERT INTO `step_record` (`user_id`, `record_date`, `step_count`, `last_upload_time`) VALUES
(1, CURDATE(), 15000, NOW()),
(2, CURDATE(), 12000, NOW()),
(3, CURDATE(), 20000, NOW()),
(4, CURDATE(), 8000, NOW()),
(5, CURDATE(), 25000, NOW())
ON DUPLICATE KEY UPDATE 
    `step_count` = VALUES(`step_count`),
    `last_upload_time` = NOW();

-- 插入昨日步数记录
INSERT INTO `step_record` (`user_id`, `record_date`, `step_count`, `last_upload_time`) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 13000, NOW()),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 11000, NOW()),
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 18000, NOW()),
(4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 7500, NOW()),
(5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 22000, NOW())
ON DUPLICATE KEY UPDATE 
    `step_count` = VALUES(`step_count`),
    `last_upload_time` = NOW();

-- 查询验证
SELECT '=== 今日步数记录 ===' AS info;
SELECT sr.id, u.nickname, sr.record_date, sr.step_count 
FROM step_record sr
JOIN user u ON sr.user_id = u.id
WHERE sr.record_date = CURDATE()
ORDER BY sr.step_count DESC;

SELECT '=== 用户总步数统计 ===' AS info;
SELECT id, nickname, total_step, remaining_step, max_daily_steps 
FROM user 
WHERE username LIKE 'testuser%'
ORDER BY total_step DESC;
