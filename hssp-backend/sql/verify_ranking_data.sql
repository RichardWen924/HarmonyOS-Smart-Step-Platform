-- 检查并插入测试用户和步数记录，用于测试排行榜功能
USE step_counter_db;

-- 1. 查看当前所有用户
SELECT '=== 当前所有用户 ===' AS info;
SELECT id, username, email, nickname, total_step, remaining_step FROM user;

-- 2. 查看今天的步数记录
SELECT '=== 今天的步数记录 ===' AS info;
SELECT sr.id, u.nickname, u.username, sr.user_id, sr.record_date, sr.step_count 
FROM step_record sr
JOIN user u ON sr.user_id = u.id
WHERE sr.record_date = CURDATE()
ORDER BY sr.step_count DESC;

-- 3. 如果只有一个用户有步数记录，插入更多测试数据
-- 首先检查是否有多个用户
SET @user_count = (SELECT COUNT(*) FROM user);

-- 如果用户数量少于5个，创建测试用户
INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) 
SELECT 'testuser1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test1@example.com', '张三', 1, 100, 15000, 15000, 15000
WHERE NOT EXISTS (SELECT 1 FROM user WHERE username = 'testuser1');

INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) 
SELECT 'testuser2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test2@example.com', '李四', 2, 80, 12000, 12000, 12000
WHERE NOT EXISTS (SELECT 1 FROM user WHERE username = 'testuser2');

INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) 
SELECT 'testuser3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test3@example.com', '王五', 1, 150, 20000, 20000, 20000
WHERE NOT EXISTS (SELECT 1 FROM user WHERE username = 'testuser3');

INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) 
SELECT 'testuser4', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test4@example.com', '赵六', 2, 50, 8000, 8000, 8000
WHERE NOT EXISTS (SELECT 1 FROM user WHERE username = 'testuser4');

INSERT INTO `user` (`username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`) 
SELECT 'testuser5', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lqkkO9QS3TzCjH3rS', 'test5@example.com', '孙七', 1, 200, 25000, 25000, 25000
WHERE NOT EXISTS (SELECT 1 FROM user WHERE username = 'testuser5');

-- 4. 为测试用户插入今天的步数记录
-- 获取用户ID（根据实际情况调整）
SET @user1_id = (SELECT id FROM user WHERE username = 'testuser1' LIMIT 1);
SET @user2_id = (SELECT id FROM user WHERE username = 'testuser2' LIMIT 1);
SET @user3_id = (SELECT id FROM user WHERE username = 'testuser3' LIMIT 1);
SET @user4_id = (SELECT id FROM user WHERE username = 'testuser4' LIMIT 1);
SET @user5_id = (SELECT id FROM user WHERE username = 'testuser5' LIMIT 1);

-- 插入今日步数记录（如果不存在则插入，存在则更新）
INSERT INTO `step_record` (`user_id`, `record_date`, `step_count`, `last_upload_time`) 
VALUES 
(@user1_id, CURDATE(), 15000, NOW()),
(@user2_id, CURDATE(), 12000, NOW()),
(@user3_id, CURDATE(), 20000, NOW()),
(@user4_id, CURDATE(), 8000, NOW()),
(@user5_id, CURDATE(), 25000, NOW())
ON DUPLICATE KEY UPDATE 
    `step_count` = VALUES(`step_count`),
    `last_upload_time` = NOW();

-- 5. 验证数据
SELECT '=== 验证：今日步数排行榜 ===' AS info;
SELECT 
    ROW_NUMBER() OVER (ORDER BY sr.step_count DESC) AS rank,
    u.nickname,
    u.username,
    sr.user_id,
    sr.step_count,
    sr.record_date
FROM step_record sr
JOIN user u ON sr.user_id = u.id
WHERE sr.record_date = CURDATE()
ORDER BY sr.step_count DESC;

SELECT '=== 验证：用户总步数统计 ===' AS info;
SELECT id, nickname, username, total_step, remaining_step, max_daily_steps 
FROM user 
ORDER BY total_step DESC;
