# HSSP 数据库样例数据 (Sample Data)

本文档提供了 HSSP 平台核心业务表的样例数据，可用于本地开发环境的初始化。

## 1. 管理员表 (`admin`)
| id | username | password (123456) | email | nickname | sex | avatar |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | admin | e10adc3949ba59abbe56e057f20f883e | admin@hssp.com | 系统管理员 | 1 | https://api.multiavatar.com/admin.png |
| 2 | editor_wen | e10adc3949ba59abbe56e057f20f883e | wen@hssp.com | 项目总监 | 1 | https://api.multiavatar.com/wen.png |

## 2. 用户表 (`user`)
| id | username | nickname | total_points | total_step | remaining_step |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1001 | user1 | 爱跑步的张三 | 500 | 50000 | 4500 |
| 1002 | user2 | 健步如飞李四 | 1200 | 120000 | 8000 |
| 1003 | user3 | 王五爱运动 | 50 | 5000 | 500 |

## 3. 步数记录表 (`step_record`)
| id | user_id | record_date | step_count | last_upload_time |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 1001 | 2026-04-17 | 8500 | 2026-04-17 18:00:00 |
| 2 | 1001 | 2026-04-18 | 4500 | 2026-04-18 10:00:00 |
| 3 | 1002 | 2026-04-18 | 12000 | 2026-04-18 09:30:00 |

## 4. 积分兑换规则 (`points_rule`)
| id | rule_name | steps_required | points_awarded | is_active |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 每日基础达标 | 1000 | 10 | 1 |
| 2 | 运动达人奖 | 5000 | 60 | 1 |
| 3 | 万步挑战赛 | 10000 | 150 | 1 |

## 5. 商城商品表 (`mall_goods`)
| id | goods_name | required_points | display_num | is_deleted |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 华为 Mate 60 Pro | 50000 | 1 | 0 |
| 2 | 荣耀手环 7 | 2000 | 15 | 0 |
| 3 | 运动蓝牙耳机 | 1500 | 8 | 0 |
| 4 | 下架测试商品 | 999 | 0 | 1 |

## 6. 商城订单记录 (`mall_order`)
| id | user_id | goods_id | points | status | tracking_number | exchange_time |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 20260418001 | 1001 | 2 | 2000 | 1 | SF1423525235 | 2026-04-18 09:00:00 |
| 20260418002 | 1002 | 3 | 1500 | 0 | NULL | 2026-04-18 10:15:00 |
| 20260418003 | 1001 | 3 | 1500 | 2 | JD0088776655 | 2026-04-17 14:00:00 |

---
**状态枚举说明：**
*   **订单状态 (status)**: 0: 待发货, 1: 已发货, 2: 已完成, 3: 已取消
*   **商品状态 (is_deleted)**: 0: 上架中, 1: 已下架/已逻辑删除
