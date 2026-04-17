import ApiClient from '../services/ApiClient'
import promptAction from '@ohos.promptAction'

/**
 * API测试工具
 */
export class APITest {
  
  /**
   * 测试登录API
   */
  static async testLoginAPI(): Promise<void> {
    console.log('=== 开始测试登录API ===')
    
    try {
      // 测试密码登录
      console.log('测试密码登录...')
      const response = await ApiClient.loginByPassword('testuser', 'password123')
      
      if (response.code === 1) {
        console.log('✅ 密码登录API测试成功')
        console.log('响应数据:', response.data)
      } else {
        console.log(`⚠️ 密码登录API返回错误: ${response.message}`)
      }
      
    } catch (error) {
      console.error('❌ 密码登录API测试失败:', error)
      
      if (error.message.includes('NetworkError')) {
        console.log('网络错误，请检查后端服务是否启动')
      } else if (error.message.includes('timeout')) {
        console.log('请求超时，后端服务可能未启动')
      } else {
        console.log('其他错误:', error.message)
      }
    }
  }
  
  /**
   * 测试注册API
   */
  static async testRegisterAPI(): Promise<void> {
    console.log('=== 开始测试注册API ===')
    
    try {
      const response = await ApiClient.register('test@example.com', '123456')
      
      if (response.code === 1) {
        console.log('✅ 注册API测试成功')
        console.log('响应数据:', response.data)
      } else {
        console.log(`⚠️ 注册API返回错误: ${response.message}`)
      }
      
    } catch (error) {
      console.error('❌ 注册API测试失败:', error)
    }
  }
  
  /**
   * 测试发送验证码API
   */
  static async testSendCodeAPI(): Promise<void> {
    console.log('=== 开始测试发送验证码API ===')
    
    try {
      const response = await ApiClient.sendVerificationCode('test@example.com')
      
      if (response.code === 1) {
        console.log('✅ 发送验证码API测试成功')
      } else {
        console.log(`⚠️ 发送验证码API返回错误: ${response.message}`)
      }
      
    } catch (error) {
      console.error('❌ 发送验证码API测试失败:', error)
    }
  }
  
  /**
   * 运行完整的API测试套件
   */
  static async runFullAPITest(): Promise<{
    loginTest: boolean;
    registerTest: boolean;
    sendCodeTest: boolean;
    errorMessages: string[];
  }> {
    const results = {
      loginTest: false,
      registerTest: false,
      sendCodeTest: false,
      errorMessages: [] as string[]
    }
    
    try {
      // 测试登录
      const loginResponse = await ApiClient.loginByPassword('testuser', 'password123')
      results.loginTest = loginResponse.code === 1
      if (!results.loginTest) {
        results.errorMessages.push(`登录失败: ${loginResponse.message}`)
      }
      
    } catch (error) {
      results.errorMessages.push(`登录异常: ${error.message}`)
    }
    
    try {
      // 测试发送验证码
      const codeResponse = await ApiClient.sendVerificationCode('test@example.com')
      results.sendCodeTest = codeResponse.code === 1
      if (!results.sendCodeTest) {
        results.errorMessages.push(`发送验证码失败: ${codeResponse.message}`)
      }
      
    } catch (error) {
      results.errorMessages.push(`发送验证码异常: ${error.message}`)
    }
    
    return results
  }
  
  /**
   * 获取API测试摘要
   */
  static async getAPITestSummary(): Promise<string> {
    const results = await this.runFullAPITest()
    
    let summary = 'API测试结果:\n'
    summary += `登录测试: ${results.loginTest ? '✅ 通过' : '❌ 失败'}\n`
    summary += `发送验证码测试: ${results.sendCodeTest ? '✅ 通过' : '❌ 失败'}\n`
    
    if (results.errorMessages.length > 0) {
      summary += '\n错误信息:\n'
      results.errorMessages.forEach(msg => {
        summary += `• ${msg}\n`
      })
    }
    
    return summary
  }
}