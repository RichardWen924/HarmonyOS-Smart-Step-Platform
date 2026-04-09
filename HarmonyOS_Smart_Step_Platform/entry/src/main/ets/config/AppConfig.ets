/**
 * 应用配置类
 * 包含应用运行所需的所有配置参数
 */

class AppConfig {
  // API配置
  static readonly baseUrl: string = 'http://192.168.59.83:8082'
  static readonly timeout: number = 10000
  static readonly maxRetries: number = 3
  static readonly retryDelay: number = 1000
  
  // 功能开关
  static readonly enableMock: boolean = false
  static readonly enableLog: boolean = true
  
  // 应用设置
  static readonly appName: string = '智能步数平台'
  static readonly version: string = '1.0.0'
  
  // 步数相关配置
  static readonly dailyStepGoal: number = 10000
  static readonly stepExchangeRate: number = 100  // 100步=1积分
  
  // 网络配置
  static readonly networkTimeout: number = 15000
  static readonly uploadBatchSize: number = 100
}

export default AppConfig