# HSSP 用户服务接口文档

## 概述

本文档描述了 HarmonyOS Smart Step Platform (HSSP) 用户服务模块的所有 API 接口。

**基础信息**
- 服务名称：hssp-user
- 基础路径：`/user`
- 数据格式：`application/json`
- 认证方式：JWT Token（通过 Header 中的 `Authorization` 字段传递）

---

## 通用响应格式

所有接口均返回统一的响应格式：

```json
{
  "code": 1,        // 响应码：1-成功，0-失败
  "message": "操作成功",  // 响应消息
  "data": {}        // 响应数据（可选）
}
```

---

## 1. 用户认证接口

### 1.1 用户注册

**接口说明**：使用邮箱和验证码注册新用户

**请求信息**
- 路径：`POST /user/register`
- Content-Type：`application/json`

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| email | string | 是 | 邮箱地址 | "user@example.com" |
| verification | string | 是 | 验证码 | "123456" |

**请求示例**
```json
{
  "email": "user@example.com",
  "verification": "123456"
}
```

**响应示例**
```json
{
  "code": 1,
  "message": "注册成功",
  "data": null
}
```

**错误码**
- `0` - 邮箱已存在
- `0` - 验证码错误

---

### 1.2 发送验证码

**接口说明**：向指定邮箱发送验证码

**请求信息**
- 路径：`POST /user/send-verification`
- Content-Type：`application/json`

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| email | string | 是 | 邮箱地址 | "user@example.com" |

**请求示例**
```json
{
  "email": "user@example.com"
}
```

**响应示例**
```json
{
  "code": 1,
  "message": "验证码发送成功",
  "data": null
}
```

---

### 1.3 用户登录

**接口说明**：支持多种登录方式（用户名+密码、邮箱+密码、邮箱+验证码）

**请求信息**
- 路径：`POST /user/login`
- Content-Type：`application/json`

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| username | string | 否 | 用户名（与 password 配合使用） | "testuser" |
| email | string | 否 | 邮箱（与 password 或 verification 配合使用） | "user@example.com" |
| password | string | 否 | 密码 | "123456" |
| verification | string | 否 | 验证码（与 email 配合使用） | "123456" |

**登录方式说明**
1. **用户名 + 密码**：提供 `username` 和 `password`
2. **邮箱 + 密码**：提供 `email` 和 `password`
3. **邮箱 + 验证码**：提供 `email` 和 `verification`

**请求示例（用户名+密码）**
```json
{
  "username": "testuser",
  "password": "123456"
}
```

**请求示例（邮箱+验证码）**
```json
{
  "email": "user@example.com",
  "verification": "123456"
}
```

**响应示例**
```json
{
  "code": 1,
  "message": "登录成功",
  "data": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**响应说明**
- `data` 字段为 JWT Token，后续请求需在 Header 中携带：`Authorization: Bearer {token}`

**错误码**
- `0` - 用户名或密码错误
- `0` - 验证码错误
- `0` - 邮箱不存在
- `0` - 用户名/邮箱不能为空

---

## 2. 用户信息管理接口

> **注意**：以下接口需要在 Header 中携带 JWT Token
> ```
> Authorization: Bearer {token}
> ```

### 2.1 更新用户信息

**接口说明**：更新当前登录用户的个人信息（昵称、性别、头像）

**请求信息**
- 路径：`PUT /user`
- Content-Type：`application/json`
- 认证：需要 JWT Token

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| nickname | string | 否 | 昵称 | "张三" |
| sex | number | 否 | 性别：0-保密，1-男，2-女 | 1 |
| avatar | string | 否 | 头像URL | "https://example.com/avatar.jpg" |

**请求示例**
```json
{
  "nickname": "张三",
  "sex": 1,
  "avatar": "https://example.com/avatar.jpg"
}
```

**响应示例**
```json
{
  "code": 1,
  "message": "更新用户信息成功",
  "data": null
}
```

**错误码**
- `401` - 未登录或 Token 无效
- `0` - 用户不存在

---

### 2.2 修改密码

**接口说明**：修改当前登录用户的密码

**请求信息**
- 路径：`PUT /user/password`
- Content-Type：`application/json`
- 认证：需要 JWT Token

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| oldPassword | string | 是 | 原密码 | "123456" |
| newPassword | string | 是 | 新密码 | "newpass123" |

**请求示例**
```json
{
  "oldPassword": "123456",
  "newPassword": "newpass123"
}
```

**响应示例**
```json
{
  "code": 1,
  "message": "密码更新成功",
  "data": null
}
```

**错误码**
- `401` - 未登录或 Token 无效
- `0` - 旧密码错误

---

### 2.3 查询积分

**接口说明**：查询当前登录用户的总积分

**请求信息**
- 路径：`GET /user/points`
- 认证：需要 JWT Token

**请求参数**：无

**响应示例**
```json
{
  "code": 1,
  "message": "操作成功",
  "data": 1500
}
```

**响应说明**
- `data` 字段为用户当前的总积分数

**错误码**
- `401` - 未登录或 Token 无效

---

## 3. 排行榜接口

### 3.1 获取步数排行榜

**接口说明**：获取日/周/月步数排行榜（支持分页）

**请求信息**
- 路径：`GET /user/rankings`
- 认证：需要 JWT Token

**请求参数（Query String）**

| 参数名 | 类型 | 必填 | 默认值 | 说明 | 示例 |
|--------|------|------|--------|------|------|
| periodType | string | 否 | "day" | 周期类型：day-日排行，week-周排行，month-月排行 | "week" |
| pageNum | number | 否 | 1 | 页码 | 1 |
| pageSize | number | 否 | 10 | 每页条数 | 20 |

**请求示例**
```
GET /user/rankings?periodType=week&pageNum=1&pageSize=10
```

**响应示例**
```json
{
  "code": 1,
  "message": "操作成功",
  "data": {
    "total": 100,
    "pages": 10,
    "pageNum": 1,
    "list": [
      {
        "rank": 1,
        "userId": 1001,
        "nickname": "运动达人",
        "avatar": "https://example.com/avatar1.jpg",
        "totalSteps": 50000.0
      },
      {
        "rank": 2,
        "userId": 1002,
        "nickname": "健康先锋",
        "avatar": "https://example.com/avatar2.jpg",
        "totalSteps": 48000.0
      }
    ]
  }
}
```

**响应字段说明**

| 字段名 | 类型 | 说明 |
|--------|------|------|
| total | number | 总记录数 |
| pages | number | 总页数 |
| pageNum | number | 当前页码 |
| list | array | 排行榜列表 |
| list[].rank | number | 排名 |
| list[].userId | number | 用户ID |
| list[].nickname | string | 用户昵称 |
| list[].avatar | string | 头像URL |
| list[].totalSteps | number | 周期内总步数 |

**错误码**
- `401` - 未登录或 Token 无效

---

## 4. 数据模型

### 4.1 LoginDto（登录请求）

```typescript
interface LoginDto {
  username?: string;      // 用户名
  email?: string;         // 邮箱
  password?: string;      // 密码
  verification?: string;  // 验证码
}
```

### 4.2 RegisterDto（注册请求）

```typescript
interface RegisterDto {
  email: string;          // 邮箱
  verification: string;   // 验证码
}
```

### 4.3 ChangeInfoDto（更新用户信息请求）

```typescript
interface ChangeInfoDto {
  nickname?: string;      // 昵称
  sex?: number;           // 性别：0-保密，1-男，2-女
  avatar?: string;        // 头像URL
}
```

### 4.4 ChangePasswordDto（修改密码请求）

```typescript
interface ChangePasswordDto {
  oldPassword: string;    // 原密码
  newPassword: string;    // 新密码
}
```

### 4.5 EmailDto（发送邮件验证码请求）

```typescript
interface EmailDto {
  email: string;          // 邮箱地址
}
```

### 4.6 RankVO（排行榜数据）

```typescript
interface RankVO {
  rank: number;           // 排名
  userId: number;         // 用户ID
  nickname: string;       // 用户昵称
  avatar: string;         // 头像URL
  totalSteps: number;     // 周期内总步数
}
```

### 4.7 PageResult（分页结果）

```typescript
interface PageResult<T> {
  total: number;          // 总记录数
  pages: number;          // 总页数
  pageNum: number;        // 当前页码
  list: T[];              // 数据列表
}
```

---

## 5. 认证说明

### 5.1 JWT Token 使用

1. **获取 Token**：通过登录接口获取 JWT Token
2. **携带 Token**：在需要认证的接口请求 Header 中添加：
   ```
   Authorization: Bearer {token}
   ```
3. **Token 有效期**：24小时
4. **Token 过期处理**：收到 401 状态码时，需要重新登录获取新 Token

### 5.2 无需认证的接口

以下接口不需要 JWT Token：
- `POST /user/register` - 用户注册
- `POST /user/send-verification` - 发送验证码
- `POST /user/login` - 用户登录

### 5.3 需要认证的接口

以下接口需要在 Header 中携带 JWT Token：
- `PUT /user` - 更新用户信息
- `PUT /user/password` - 修改密码
- `GET /user/points` - 查询积分
- `GET /user/rankings` - 获取排行榜

---

## 6. 错误码说明

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 0 | 业务逻辑错误 | 查看 message 字段获取具体错误信息 |
| 1 | 操作成功 | - |
| 401 | 未授权 | Token 无效或过期，需要重新登录 |
| 500 | 服务器内部错误 | 联系技术支持 |

---

## 7. 注意事项

1. **密码安全**：密码在后端使用 BCrypt 加密存储，前端传输时使用明文（建议生产环境使用 HTTPS）
2. **验证码有效期**：验证码存储在 Redis 中，有效期为 5 分钟
3. **注册默认密码**：注册成功后，系统会设置默认密码为 `123456`，用户首次登录后应及时修改
4. **步数排行榜**：排行榜数据基于 Redis ZSet 实现，按周期（日/周/月）自动更新
5. **分页参数**：pageNum 从 1 开始，pageSize 建议不超过 100

---

## 8. 示例代码

### 8.1 登录示例（JavaScript/TypeScript）

```javascript
// 登录
const loginResponse = await fetch('http://localhost:8082/user/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: '123456'
  })
});

const result = await loginResponse.json();
if (result.code === 1) {
  const token = result.data;
  // 保存 token
  localStorage.setItem('token', token);
}
```

### 8.2 调用需要认证的接口

```javascript
// 获取用户积分
const token = localStorage.getItem('token');
const pointsResponse = await fetch('http://localhost:8082/user/points', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

const result = await pointsResponse.json();
console.log('用户积分:', result.data);
```

### 8.3 获取排行榜

```javascript
// 获取周排行榜
const token = localStorage.getItem('token');
const rankingResponse = await fetch(
  'http://localhost:8082/user/rankings?periodType=week&pageNum=1&pageSize=10',
  {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);

const result = await rankingResponse.json();
console.log('排行榜:', result.data.list);
```

---

## 9. 更新日志

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-07 | 初始版本，包含用户认证、信息管理、排行榜功能 |

---

## 10. 联系方式

如有问题，请联系开发团队。
