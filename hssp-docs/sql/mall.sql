CREATE TABLE `mall_goods`
(
    `id`              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `goods_name`      VARCHAR(100) NOT NULL COMMENT '商品名',
    `required_points` INT          NOT NULL COMMENT '所需积分',
    `cover_url`       VARCHAR(255) DEFAULT NULL COMMENT '封面图URL',
    `display_num`     INT          DEFAULT 0 COMMENT '销量',
    `stock`           INT          DEFAULT 0 COMMENT '库存数量',
    `is_deleted`      TINYINT(1)   DEFAULT 0 COMMENT '逻辑删除 (0:未删除 1:已删除)',
    `create_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_required_points` (`required_points`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='商城商品表';

CREATE TABLE `mall_order`
(
    `id`              bigint NOT NULL COMMENT '订单主键ID (分布式ID)',
    `user_id`         bigint NOT NULL COMMENT '用户ID',
    `goods_id`        bigint NOT NULL COMMENT '商品ID',
    `points_consumed` int    NOT NULL COMMENT '消耗积分数量',
    `status`          tinyint      DEFAULT '0' COMMENT '订单状态：0-待发货, 1-已发货, 2-已完成, 3-已取消',
    `tracking_number` varchar(100) DEFAULT NULL COMMENT '物流单号',
    `exchange_time`   datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_exchange_time` (`exchange_time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci COMMENT ='商城订单记录表';

CREATE TABLE `user_points`
(
    `user_id`           BIGINT NOT NULL COMMENT '用户ID（关联User表）',
    `total_points`      INT      DEFAULT 0 COMMENT '当前总积分',
    `cumulative_points` INT      DEFAULT 0 COMMENT '累计积分',
    `update_time`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户积分表';
