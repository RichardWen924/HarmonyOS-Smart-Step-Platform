/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// 用户信息接口
export interface UserInfo {
    id: number;
    username: string;
    email: string;
    nickname: string;
    sex?: number; // 1:男，2:女
    avatar?: string;
    totalSteps: number;
    totalPoints: number;
    remainingSteps: number;
}
// 步数记录接口
export interface StepRecord {
    id: number;
    steps: number;
    date: string;
    timestamp: string;
}
// 步数统计数据接口
export interface StepStatistics {
    todaySteps: number;
    weekSteps: number;
    monthSteps: number;
    totalSteps: number;
    avgDailySteps: number;
    maxDailySteps: number;
    minDailySteps: number;
    lastUpdate: string;
}
// 排名项接口
export interface RankingItem {
    rank: number;
    userId: number;
    username: string;
    nickname: string;
    totalSteps: number;
    avatar?: string;
}
// 权限状态接口
export interface PermissionStatus {
    stepCounter: boolean;
    healthKit: boolean;
    location: boolean;
    notification: boolean;
}
// API 响应接口
export interface ApiResponse<T> {
    code: number; // 1: 成功，其他：失败
    message: string;
    data: T;
}
// 登录请求
export interface LoginRequest {
    account: string; // 邮箱/用户名
    password?: string;
    verificationCode?: string;
    loginType: number; // 1: 密码登录，2: 验证码登录
}
// 登录响应类
export class LoginResponse {
    token: string = '';
    userInfo: UserInfo = {} as UserInfo;
    expiresIn: number = 7200;
    constructor(token: string = '', userInfo: UserInfo = {} as UserInfo, expiresIn: number = 7200) {
        this.token = token;
        this.userInfo = userInfo;
        this.expiresIn = expiresIn;
    }
}
// 注册请求
export interface RegisterRequest {
    email: string;
    password: string;
    verificationCode: string;
    nickname?: string;
}
// 验证码请求
export interface VerificationRequest {
    email: string;
    type: number; // 1: 注册，2: 登录，3: 找回密码
}
// 步数上传请求接口
export interface StepUploadRequest {
    steps: number;
    date: string;
    timestamp?: string;
    deviceId?: string;
}
// 步数统计请求
export interface StepStatisticsRequest {
    days: number;
    startDate?: string;
    endDate?: string;
}
// 排行榜请求
export interface RankingRequest {
    periodType: string; // day, week, month
    page?: number;
    pageSize?: number;
}
// 积分兑换请求
export interface ExchangeRequest {
    steps: number;
}
// 积分兑换响应
export interface ExchangeResponse {
    exchangedSteps: number;
    gainedPoints: number;
    remainingSteps: number;
    totalPoints: number;
    timestamp: string;
}
// 商品信息
export interface Product {
    id: number;
    name: string;
    description: string;
    points: number;
    image?: string;
    stock: number;
    category?: string;
}
// 兑换记录
export interface ExchangeRecord {
    id: number;
    productId: number;
    productName: string;
    points: number;
    status: number; // 0:待发货，1:已发货，2:已完成，3:已取消
    exchangeTime: string;
    remark?: string;
    type?: string; // points: 积分兑换, steps: 步数记录
    steps?: number; // 步数记录
    userId?: number;
    description?: string;
    createdAt?: string;
}
// 错误信息接口
export interface AppError {
    code: number;
    message: string;
    details?: string;
}
// 分页数据
export interface PageData<T> {
    list: T[];
    total: number;
    page: number;
    pageSize: number;
}
