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
  username?: string; // 用户名（可选）
  email?: string;    // 邮箱（可选）
  password?: string;
  verification?: string; // 验证码（可选）
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
  username: string;
  email: string;
  verification: string;
}

// 验证码请求
export interface VerificationRequest {
  email: string;
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

// 扩展商品信息（用于商城页面）
export interface ExtendedProduct extends Product {
  isRecommended?: boolean;
  discount?: number;
  originalPoints?: number;
  tags?: string[];
  rating?: number;
  reviews?: number;
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

// ========== 新增接口定义 ==========

// 3.1 修改个人信息请求
export interface UpdateUserInfoRequest {
  nickname?: string;
  sex?: number; // 1:男，2:女
  avatar?: string;
}

// 3.2 修改密码请求
export interface UpdatePasswordRequest {
  oldPassword: string;
  newPassword: string;
}

// 3.3 积分查询响应
export interface PointsResponse {
  totalPoints: number;
}

// 3.4 步数兑换积分请求
export interface ExchangeStepsRequest {
  stepCount: number;
}

// 3.4 步数兑换积分响应
export interface ExchangeStepsResponse {
  earnedPoints: number;
  remainingStep: number;
}

// 积分兑换规则
export interface PointRule {
  id: number;
  ruleName: string;
  stepsRequired: number;
  pointsAwarded: number;
  isActive: number; // 1:启用, 0:禁用
}

// 兑换预览结果
export interface ExchangePreview {
  inputSteps: number;
  totalEarnedPoints: number;
  remainingSteps: number;
  ruleDetails: RuleDetail[];
}

// 规则详情
export interface RuleDetail {
  ruleName: string;
  stepsRequired: number;
  pointsAwarded: number;
  exchangeCount: number;
  earnedPoints: number;
}

// 3.5 手动上传步数请求
export interface UploadStepsRequest {
  stepCount: number;
  recordDate?: string;
}

// 3.6 排行榜响应
export interface RankingsResponse {
  total: number;
  list: RankingItem[];
}

// 每日步数统计项
export interface DailyStepStatistic {
  recordDate: string;
  stepCount: number;
}

// 3.7 步数统计响应
export interface StepsStatisticsResponse {
  statistics: DailyStepStatistic[];
  totalSteps: number;
  averageSteps: number;
  maxSteps: number;
  minSteps: number;
}

// 后端返回的用户信息接口（下划线命名法）
export interface BackendUserInfo {
  id: number;
  username: string;
  password?: string;
  email: string;
  nickname: string;
  sex?: number;
  avatar?: string;
  total_points: number;
  total_step: number;
  remaining_step: number;
  max_daily_steps?: number;
  is_deleted?: number;
  create_time?: string;
  update_time?: string;
}

// 后端返回的登录响应接口
export interface BackendLoginResponse {
  token: string;
  userInfo: BackendUserInfo;
  expiresIn?: number;
}