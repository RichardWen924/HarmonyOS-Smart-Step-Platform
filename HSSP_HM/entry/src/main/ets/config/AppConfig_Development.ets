/**
 * 开发环境配置
 * 用于不同环境的快速切换
 */

class DevelopmentConfig {
  // 开发环境配置
  static readonly DEVELOPMENT = {
    baseUrl: 'http://192.168.59.100:8080',
    enableMock: false,
    enableLog: true
  }

  // 模拟器环境配置
  static readonly EMULATOR = {
    baseUrl: 'http://10.0.2.2:8080',  // Android模拟器专用地址
    enableMock: false,
    enableLog: true
  }

  // 生产环境配置
  static readonly PRODUCTION = {
    baseUrl: 'https://api.yourserver.com',
    enableMock: false,
    enableLog: false
  }

  // Mock模式配置
  static readonly MOCK = {
    baseUrl: 'http://localhost:8080',
    enableMock: true,
    enableLog: true
  }

  // 根据环境获取配置
  static getConfig(env: string = 'development') {
    switch (env) {
      case 'emulator':
        return this.EMULATOR
      case 'production':
        return this.PRODUCTION
      case 'mock':
        return this.MOCK
      default:
        return this.DEVELOPMENT
    }
  }
}

export default DevelopmentConfig