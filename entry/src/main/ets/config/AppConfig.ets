/**
 * 应用程序配置类
 * 包含应用的基础配置信息
 */

class AppConfig {
  // API 基础URL
  static readonly baseUrl: string = 'http://192.168.59.99:8080'
  
  // 请求超时时间（毫秒）
  static readonly timeout: number = 10000
  
  // 最大重试次数
  static readonly maxRetries: number = 3
  
  // 重试延迟时间（毫秒）
  static readonly retryDelay: number = 2000
  
  // 是否启用模拟数据
  static readonly enableMock: boolean = false
  
  // 是否启用日志
  static readonly enableLog: boolean = true
  
  // 应用版本信息
  static readonly version: string = '1.0.0'
  
  // 应用名称
  static readonly appName: string = '智能步数平台'
  
  // 默认每页显示数量
  static readonly defaultPageSize: number = 20
  
  // 最大每日步数限制
  static readonly maxDailySteps: number = 50000
  
  // 步数兑换比例（步数:积分）
  static readonly exchangeRate: number = 100
  
  // 是否启用手劢输入步数功能
  static readonly enableManualStepInput: boolean = false
}

export default AppConfig