
-- 1. 管理员表 (admin)
-- 密码均为 123456 的 MD5: e10adc3949ba59abbe56e057f20f883e
INSERT INTO `admin` (`id`, `username`, `password`, `email`, `nickname`, `sex`, `avatar`, `create_time`, `update_time`) VALUES
(1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin@hssp.com', '系统管理员', 1, 'https://api.multiavatar.com/admin.png', NOW(), NOW()),
(2, 'editor_wen', 'e10adc3949ba59abbe56e057f20f883e', 'wen@hssp.com', '项目总监', 1, 'https://api.multiavatar.com/wen.png', NOW(), NOW()),
(3, 'manager_li', 'e10adc3949ba59abbe56e057f20f883e', 'li@hssp.com', '商城主管', 2, 'https://api.multiavatar.com/li.png', NOW(), NOW()),
(4, 'test_dev', 'e10adc3949ba59abbe56e057f20f883e', 'dev@hssp.com', '测试开发', 1, 'https://api.multiavatar.com/dev.png', NOW(), NOW()),
(5, 'guest', 'e10adc3949ba59abbe56e057f20f883e', 'guest@hssp.com', '访客', 0, 'https://api.multiavatar.com/guest.png', NOW(), NOW());

-- 2. 积分兑换规则表 (points_rule)
INSERT INTO `points_rule` (`rule_name`, `steps_required`, `points_awarded`, `is_active`) VALUES
('每日基础达标', 1000, 10, 1),
('运动达人奖', 5000, 60, 1),
('万步挑战赛', 10000, 150, 1),
('马拉松精神', 30000, 500, 1),
('周末双倍赛', 5000, 120, 0);

-- 3. 用户表 (user)
-- 密码默认为 123456 的 MD5: e10adc3949ba59abbe56e057f20f883e
INSERT INTO `user` (`id`, `username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`, `remaining_step`, `max_daily_steps`, `is_deleted`, `create_time`, `update_time`) VALUES
(1001, 'user1', 'e10adc3949ba59abbe56e057f20f883e', 'user1@qq.com', '爱跑步的张三', 1, 500, 50000, 4500, 12000, 0, NOW(), NOW()),
(1002, 'user2', 'e10adc3949ba59abbe56e057f20f883e', 'user2@qq.com', '健步如飞李四', 2, 1200, 120000, 8000, 15000, 0, NOW(), NOW()),
(1003, 'user3', 'e10adc3949ba59abbe56e057f20f883e', 'user3@qq.com', '王五爱运动', 1, 50, 5000, 500, 6000, 0, NOW(), NOW()),
(1004, 'user4', 'e10adc3949ba59abbe56e057f20f883e', 'user4@qq.com', '资深跑者赵六', 1, 3500, 300000, 2000, 42195, 0, NOW(), NOW()),
(1005, 'user5', 'e10adc3949ba59abbe56e057f20f883e', 'user5@qq.com', '活力少女孙七', 2, 800, 85000, 3000, 10000, 0, NOW(), NOW());

-- 4. 商城商品表 (mall_goods)
INSERT INTO `mall_goods` (`goods_name`, `required_points`, `cover_url`, `display_num`, `is_deleted`, `create_time`, `update_time`) VALUES
('华为 Mate 60 Pro', 50000, 'https://picsum.photos/200/300?random=1', 1, 0, NOW(), NOW()),
('荣耀手环 7', 2000, 'https://picsum.photos/200/300?random=2', 0, 0, NOW(), NOW()),
('大容量运动水杯', 500, 'https://picsum.photos/200/300?random=3', 2, 0, NOW(), NOW()),
('运动蓝牙耳机', 1500, 'https://picsum.photos/200/300?random=4', 3, 0, NOW(), NOW()),
('定制精美T恤', 800, 'https://picsum.photos/200/300?random=5', 5, 0, NOW(), NOW());

-- 5. 用户积分统计表 (user_points) (统计用户当前剩余积分与累计积分)
INSERT INTO `user_points` (`user_id`, `total_points`, `cumulative_points`, `update_time`) VALUES
(1001, 500, 1500, NOW()),
(1002, 1200, 5000, NOW()),
(1003, 50, 100, NOW()),
(1004, 3500, 12000, NOW()),
(1005, 800, 2500, NOW());

-- 6. 商城订单记录 (mall_order)
INSERT INTO `mall_order` (`id`, `user_id`, `goods_id`, `points_consumed`, `exchange_time`) VALUES
(20260406001, 1001, 3, 500, NOW()),
(20260406002, 1002, 3, 500, NOW()),
(20260406003, 1004, 4, 1500, NOW()),
(20260406004, 1005, 5, 800, NOW()),
(20260406005, 1002, 5, 800, NOW());
