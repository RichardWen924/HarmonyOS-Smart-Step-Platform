-- HSSP 数据库初始化样例数据
-- 适用版本: 1.1.0 (包含商城订单追踪功能)

-- 1. 管理员数据 (密码均为 123456 的 MD5)
INSERT INTO `admin` (`id`, `username`, `password`, `email`, `nickname`, `sex`, `avatar`, `create_time`, `update_time`)
VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin@hssp.com', '系统管理员', 1,
        'https://api.multiavatar.com/admin.png', NOW(), NOW()),
       (2, 'editor_wen', 'e10adc3949ba59abbe56e057f20f883e', 'wen@hssp.com', '项目总监', 1,
        'https://api.multiavatar.com/wen.png', NOW(), NOW());

-- 2. 用户基础数据
INSERT INTO `user` (`id`, `username`, `password`, `email`, `nickname`, `sex`, `total_points`, `total_step`,
                    `remaining_step`, `create_time`, `update_time`)
VALUES (1001, 'user1', 'e10adc3949ba59abbe56e057f20f883e', 'user1@qq.com', '爱跑步的张三', 1, 500, 50000, 4500, NOW(),
        NOW()),
       (1002, 'user2', 'e10adc3949ba59abbe56e057f20f883e', 'user2@qq.com', '健步如飞李四', 2, 1200, 120000, 8000, NOW(),
        NOW()),
       (1003, 'user3', 'e10adc3949ba59abbe56e057f20f883e', 'user3@qq.com', '王五爱运动', 1, 50, 5000, 500, NOW(),
        NOW());

-- 3. 积分规则数据
INSERT INTO `points_rule` (`id`, `rule_name`, `steps_required`, `points_awarded`, `is_active`)
VALUES (1, '每日基础达标', 1000, 10, 1),
       (2, '运动达人奖', 5000, 60, 1),
       (3, '万步挑战赛', 10000, 150, 1);

-- 4. 步数历史记录
INSERT INTO `step_record` (`user_id`, `record_date`, `step_count`, `last_upload_time`)
VALUES (1001, '2026-04-17', 8500, '2026-04-17 18:00:00'),
       (1001, '2026-04-18', 4500, '2026-04-18 10:00:00'),
       (1002, '2026-04-18', 12000, '2026-04-18 09:30:00');

-- 5. 商城商品数据 (is_deleted: 0-上架, 1-下架)
INSERT INTO `mall_goods` (`id`, `goods_name`, `required_points`, `cover_url`, `display_num`, `stock`, `is_deleted`,
                          `create_time`, `update_time`)
VALUES (1, '华为 Mate 60 Pro', 50000, 'https://picsum.photos/200/300?random=1', 1, 100, 0, NOW(), NOW()),
       (2, '荣耀手环 7', 2000, 'https://picsum.photos/200/300?random=2', 15, 100, 0, NOW(), NOW()),
       (3, '运动蓝牙耳机', 1500, 'https://picsum.photos/200/300?random=3', 8, 100, 0, NOW(), NOW()),
       (4, '下架测试商品', 999, 'https://picsum.photos/200/300?random=4', 0, 100, 1, NOW(), NOW());

-- 6. 商城订单记录 (status: 0-待发货, 1-已发货, 2-已完成, 3-已取消)
INSERT INTO `mall_order` (`id`, `user_id`, `goods_id`, `points_consumed`, `status`, `tracking_number`, `exchange_time`)
VALUES (20260418001, 1001, 2, 2000, 1, 'SF1423525235', '2026-04-18 09:00:00'),
       (20260418002, 1002, 3, 1500, 0, NULL, '2026-04-18 10:15:00'),
       (20260418003, 1001, 3, 1500, 2, 'JD0088776655', '2026-04-17 14:00:00');
