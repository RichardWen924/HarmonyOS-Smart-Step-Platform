-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS step_counter_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE step_counter_db;

-- 1. 用户表 (user)
CREATE TABLE `user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名/账号',
    `password` VARCHAR(100) NOT NULL DEFAULT '123456' COMMENT '密码',
    `email` VARCHAR(50) DEFAULT NULL COMMENT '邮箱地址',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `sex` SMALLINT DEFAULT 1 COMMENT '性别 (1：男 2：女)',
    `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像 URL',
    `total_points` INT DEFAULT 0 COMMENT '当前总积分',
    `total_step` INT DEFAULT 0 COMMENT '总步数',
    `remaining_step` INT DEFAULT 0 COMMENT '剩余步数',
    `max_daily_steps` INT DEFAULT 0 COMMENT '历史个人单日最高步数',
    `is_deleted` TINYINT(1) DEFAULT 0 COMMENT '逻辑删除 (0：未被删除 1：已删除)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 管理员表 (admin)
CREATE TABLE `admin` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名/账号',
    `password` VARCHAR(100) NOT NULL DEFAULT '123456' COMMENT '密码',
    `email` VARCHAR(50) DEFAULT NULL COMMENT '邮箱地址',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `sex` SMALLINT DEFAULT 1 COMMENT '性别 (1：男 2：女)',
    `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像 URL',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 3. 每日步数记录表 (step_record)
CREATE TABLE `step_record` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
    `user_id` BIGINT NOT NULL COMMENT '用户 ID',
    `record_date` DATE NOT NULL COMMENT '记录日期 (YYYY-MM-DD)',
    `step_count` INT DEFAULT 0 COMMENT '今日步数累计',
    `last_upload_time` DATETIME DEFAULT NULL COMMENT '最后同步时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_date` (`user_id`, `record_date`), -- 联合索引，防止同用户同日期重复插入
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日步数记录表';

-- 4. 积分兑换规则表 (points_rule)
CREATE TABLE `points_rule` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '规则 ID',
    `rule_name` VARCHAR(50) NOT NULL COMMENT '规则名称',
    `steps_required` INT NOT NULL COMMENT '所需步数',
    `points_awarded` INT NOT NULL COMMENT '获得积分',
    `is_active` TINYINT DEFAULT 1 COMMENT '是否启用 (1-启用，0-禁用)',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分兑换规则表';

-- 5. 积分兑换日志表 (points_log)
CREATE TABLE `points_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
    `user_id` BIGINT NOT NULL COMMENT '用户 ID',
    `before_step` INT DEFAULT 0 COMMENT '兑换前的步数',
    `after_step` INT DEFAULT 0 COMMENT '兑换后的步数',
    `points_amount` INT DEFAULT 0 COMMENT '兑换获得的积分',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分兑换日志表';

-- 6. 往期排行榜汇总表 (step_rank_history)
CREATE TABLE `step_rank_history` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
    `user_id` BIGINT NOT NULL COMMENT '用户 ID',
    `period_type` TINYINT NOT NULL COMMENT '周期类型 (1:日排行，2:周排行，3:月排行)',
    `period_ident` VARCHAR(20) NOT NULL COMMENT '周期标识 (如：2026-03-25)',
    `total_steps` INT DEFAULT 0 COMMENT '周期内总步数',
    `rank_num` INT NOT NULL COMMENT '最终名次',
    `settle_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '结算时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_period` (`period_type`, `period_ident`) -- 优化排行榜查询
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='往期排行榜汇总表';