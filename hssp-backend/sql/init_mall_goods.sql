-- =============================================
-- 商城商品表 (mall_goods) 初始化数据
-- =============================================

-- 1. 创建表结构（如果不存在）
CREATE TABLE IF NOT EXISTS `mall_goods` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_name` VARCHAR(100) NOT NULL COMMENT '商品名',
  `required_points` INT NOT NULL COMMENT '所需积分',
  `cover_url` VARCHAR(255) DEFAULT NULL COMMENT '封面图URL',
  `display_num` INT DEFAULT 0 COMMENT '显示数字（销量/库存）',
  `is_deleted` TINYINT(1) DEFAULT 0 COMMENT '逻辑删除 (0:未删除 1:已删除)',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_required_points` (`required_points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商城商品表';

-- 2. 清空现有数据（可选，谨慎使用）
-- TRUNCATE TABLE `mall_goods`;

-- 3. 插入虚拟商品数据
INSERT INTO `mall_goods` (`goods_name`, `required_points`, `cover_url`, `display_num`, `is_deleted`, `create_time`, `update_time`) VALUES
-- ===== 电子产品类 =====
('华为 Mate 60 Pro 手机', 50000, 'https://picsum.photos/seed/huawei-mate60/400/400.jpg', 5, 0, NOW(), NOW()),
('小米14 Ultra 智能手机', 45000, 'https://picsum.photos/seed/xiaomi-14/400/400.jpg', 8, 0, NOW(), NOW()),
('Apple AirPods Pro 2', 15000, 'https://picsum.photos/seed/airpods-pro/400/400.jpg', 15, 0, NOW(), NOW()),
('索尼 WH-1000XM5 耳机', 18000, 'https://picsum.photos/seed/sony-wh1000/400/400.jpg', 12, 0, NOW(), NOW()),
('iPad Air 平板电脑', 35000, 'https://picsum.photos/seed/ipad-air/400/400.jpg', 6, 0, NOW(), NOW()),
('Kindle Paperwhite 电子书', 8000, 'https://picsum.photos/seed/kindle-pw/400/400.jpg', 20, 0, NOW(), NOW()),

-- ===== 运动健身类 =====
('荣耀手环 7', 2000, 'https://picsum.photos/seed/honor-band7/400/400.jpg', 50, 0, NOW(), NOW()),
('小米运动手环 8', 1800, 'https://picsum.photos/seed/mi-band8/400/400.jpg', 60, 0, NOW(), NOW()),
('专业瑜伽垫', 1200, 'https://picsum.photos/seed/yoga-mat/400/400.jpg', 100, 0, NOW(), NOW()),
('智能跳绳计数器', 800, 'https://picsum.photos/seed/jump-rope/400/400.jpg', 80, 0, NOW(), NOW()),
('运动腰包', 500, 'https://picsum.photos/seed/sports-belt/400/400.jpg', 150, 0, NOW(), NOW()),
('健身阻力带套装', 600, 'https://picsum.photos/seed/resistance-band/400/400.jpg', 120, 0, NOW(), NOW()),

-- ===== 生活用品类 =====
('大容量运动水杯 1L', 500, 'https://picsum.photos/seed/water-bottle/400/400.jpg', 200, 0, NOW(), NOW()),
('保温杯 500ml', 450, 'https://picsum.photos/seed/thermos/400/400.jpg', 180, 0, NOW(), NOW()),
('便携式充电宝 20000mAh', 1500, 'https://picsum.photos/seed/power-bank/400/400.jpg', 90, 0, NOW(), NOW()),
('无线鼠标', 800, 'https://picsum.photos/seed/wireless-mouse/400/400.jpg', 110, 0, NOW(), NOW()),
('机械键盘', 2500, 'https://picsum.photos/seed/mechanical-keyboard/400/400.jpg', 45, 0, NOW(), NOW()),
('USB-C 数据线套装', 300, 'https://picsum.photos/seed/usb-cable/400/400.jpg', 300, 0, NOW(), NOW()),

-- ===== 服装配饰类 =====
('定制精美T恤', 800, 'https://picsum.photos/seed/custom-tshirt/400/400.jpg', 150, 0, NOW(), NOW()),
('运动速干衣', 1000, 'https://picsum.photos/seed/dry-fit-shirt/400/400.jpg', 130, 0, NOW(), NOW()),
('跑步运动鞋', 3000, 'https://picsum.photos/seed/running-shoes/400/400.jpg', 70, 0, NOW(), NOW()),
('运动帽子', 400, 'https://picsum.photos/seed/sports-cap/400/400.jpg', 200, 0, NOW(), NOW()),
('运动袜子 3双装', 350, 'https://picsum.photos/seed/sports-socks/400/400.jpg', 250, 0, NOW(), NOW()),
('防晒冰袖', 250, 'https://picsum.photos/seed/arm-sleeves/400/400.jpg', 280, 0, NOW(), NOW()),

-- ===== 虚拟商品类 =====
('7天VIP会员', 1000, 'https://picsum.photos/seed/vip-7days/400/400.jpg', 999, 0, NOW(), NOW()),
('30天VIP会员', 3500, 'https://picsum.photos/seed/vip-30days/400/400.jpg', 999, 0, NOW(), NOW()),
('专属头像框-金牌', 500, 'https://picsum.photos/seed/avatar-gold/400/400.jpg', 999, 0, NOW(), NOW()),
('专属头像框-钻石', 1500, 'https://picsum.photos/seed/avatar-diamond/400/400.jpg', 999, 0, NOW(), NOW()),
('步数加倍卡 3天', 800, 'https://picsum.photos/seed/double-steps/400/400.jpg', 999, 0, NOW(), NOW()),
('积分翻倍券', 2000, 'https://picsum.photos/seed/double-points/400/400.jpg', 999, 0, NOW(), NOW());

-- 4. 查询验证
SELECT 
  id,
  goods_name AS '商品名称',
  required_points AS '所需积分',
  display_num AS '库存/销量',
  CASE 
    WHEN required_points <= 500 THEN '低价区'
    WHEN required_points <= 2000 THEN '中价区'
    WHEN required_points <= 10000 THEN '高价区'
    ELSE '奢侈区'
  END AS '价格区间'
FROM `mall_goods`
WHERE `is_deleted` = 0
ORDER BY `required_points` ASC;

-- 5. 统计信息
SELECT 
  COUNT(*) AS '商品总数',
  MIN(required_points) AS '最低积分',
  MAX(required_points) AS '最高积分',
  AVG(required_points) AS '平均积分',
  SUM(display_num) AS '总库存'
FROM `mall_goods`
WHERE `is_deleted` = 0;
