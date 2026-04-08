CREATE TABLE `mall_goods` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_name` VARCHAR(100) NOT NULL COMMENT '商品名',
  `required_points` INT NOT NULL COMMENT '所需积分',
  `cover_url` VARCHAR(255) DEFAULT NULL COMMENT '封面图',
  `display_num` INT DEFAULT 0 COMMENT '显示数字（销量/库存）',
  `is_deleted` TINYINT(1) DEFAULT 0 COMMENT '逻辑删除',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

CREATE TABLE `mall_order` (
  `id` BIGINT NOT NULL COMMENT '订单ID（雪花）',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `goods_id` BIGINT NOT NULL COMMENT '商品ID',
  `points_consumed` INT NOT NULL COMMENT '消耗积分',
  `exchange_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '兑换时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

CREATE TABLE `user_points` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID（关联User表）',
  `total_points` INT DEFAULT 0 COMMENT '当前总积分',
  `cumulative_points` INT DEFAULT 0 COMMENT '累计积分',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分表';
