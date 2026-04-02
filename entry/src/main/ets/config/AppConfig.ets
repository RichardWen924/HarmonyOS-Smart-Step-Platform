/**
 * 应用配置文件
 * 
 * 使用说明：
 * 1. 修改 baseUrl 为你的后端 API 地址
 * 2. 根据需要调整超时时间、重试次数等参数
 * 3. 开发环境和生产环境可以使用不同的配置
 */

export const AppConfig = {
  // API 基础地址
  baseUrl: 'http://localhost:3000/api',
  
  // 请求超时时间（毫秒）
  timeout: 10000,
  
  // 最大重试次数
  maxRetries: 3,
  
  // 重试延迟（毫秒）
  retryDelay: 1000,
  
  // Token 存储键名
  tokenKey: 'smart_step_token',
  
  // 用户信息存储键名
  userKey: 'smart_step_user',
  
  // 步数存储键名
  stepKey: 'smart_step_data',
  
  // 自动同步步数的时间（小时，24 小时制）
  autoSyncHour: 22,
  
  // 每日步数目标
  dailyStepGoal: 10000,
  
  // 积分兑换比例（步数：积分）
  exchangeRate: 100, // 100 步 = 1 积分
  
  // 每日最大兑换步数
  maxDailyExchange: 10000,
  
  // 是否启用日志
  enableLog: true,
  
  // 是否启用 Mock 数据（开发阶段）
  enableMock: true,
  
  // 版本号
  version: '1.0.0',
  
  // 应用名称
  appName: '智能计步器',
  
  // 最小支持的版本号
  minVersion: '1.0.0'
}

// 导出默认配置
export default AppConfig
