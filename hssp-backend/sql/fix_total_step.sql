-- 诊断和修复 total_step 字段问题
USE step_counter_db;

-- 1. 查看所有用户的步数统计
SELECT '=== 所有用户步数统计 ===' AS info;
SELECT 
    id,
    username,
    nickname,
    total_step AS '总步数',
    remaining_step AS '剩余步数(今日)',
    max_daily_steps AS '最大日步数',
    total_points AS '总积分'
FROM user
ORDER BY id;

-- 2. 查看每个用户的步数记录总数
SELECT '=== 每个用户的步数记录数量 ===' AS info;
SELECT 
    u.id,
    u.nickname,
    COUNT(sr.id) AS '记录天数',
    SUM(sr.step_count) AS '步数记录总和',
    u.total_step AS '数据库总步数',
    CASE 
        WHEN SUM(sr.step_count) != u.total_step THEN '❌ 不一致'
        ELSE '✅ 一致'
    END AS '状态'
FROM user u
LEFT JOIN step_record sr ON u.id = sr.user_id
GROUP BY u.id, u.nickname, u.total_step
ORDER BY u.id;

-- 3. 查看今天的步数记录
SELECT '=== 今天的步数记录 ===' AS info;
SELECT 
    sr.id,
    u.id AS user_id,
    u.nickname,
    sr.record_date,
    sr.step_count,
    sr.last_upload_time
FROM step_record sr
JOIN user u ON sr.user_id = u.id
WHERE sr.record_date = CURDATE()
ORDER BY sr.step_count DESC;

-- 4. 修复 total_step 字段（重新计算所有用户的总步数）
SELECT '=== 开始修复 total_step 字段 ===' AS info;

UPDATE user u
SET u.total_step = (
    SELECT COALESCE(SUM(sr.step_count), 0)
    FROM step_record sr
    WHERE sr.user_id = u.id
)
WHERE u.id IN (SELECT DISTINCT user_id FROM step_record);

-- 5. 验证修复结果
SELECT '=== 修复后的验证 ===' AS info;
SELECT 
    u.id,
    u.nickname,
    COUNT(sr.id) AS '记录天数',
    SUM(sr.step_count) AS '重新计算的总步数',
    u.total_step AS '数据库中的总步数',
    CASE 
        WHEN SUM(sr.step_count) = u.total_step THEN '✅ 已修复'
        ELSE '❌ 仍有问题'
    END AS '状态'
FROM user u
LEFT JOIN step_record sr ON u.id = sr.user_id
GROUP BY u.id, u.nickname, u.total_step
HAVING COUNT(sr.id) > 0
ORDER BY u.id;

-- 6. 设置 remaining_step 为今天的步数（如果今天有记录）
UPDATE user u
SET u.remaining_step = (
    SELECT sr.step_count
    FROM step_record sr
    WHERE sr.user_id = u.id AND sr.record_date = CURDATE()
)
WHERE EXISTS (
    SELECT 1 FROM step_record sr 
    WHERE sr.user_id = u.id AND sr.record_date = CURDATE()
);

-- 7. 最终检查结果
SELECT '=== 最终检查结果 ===' AS info;
SELECT 
    id,
    username,
    nickname,
    total_step AS '总步数',
    remaining_step AS '今日步数',
    max_daily_steps AS '最大日步数'
FROM user
ORDER BY id;
