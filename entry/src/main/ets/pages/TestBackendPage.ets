import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import http from '@ohos.net.http'
import ApiClient from '../services/ApiClient'
import AppConfig from '../config/AppConfig'
import { ApiResponse, LoginResponse } from '../types/common'

@Entry
@Component
struct TestBackendPage {
  @State testResult: string = '点击按钮开始测试'
  @State isLoading: boolean = false
  
  private apiClient = ApiClient

  build() {
    Column() {
      Text('后端连接测试')
        .fontSize(24)
        .fontWeight(700)
        .margin({ bottom: 20 })
      
      Text('测试后端API连接状态')
        .fontSize(16)
        .fontColor(0x666666)
        .margin({ bottom: 10 })
      
      Text(`当前模式: ${AppConfig.enableMock ? 'Mock数据模式' : '真实API模式'}`)
        .fontSize(14)
        .fontColor(AppConfig.enableMock ? 0xFF9500 : 0x34C759)
        .fontWeight(600)
        .margin({ bottom: 30 })
      
      Button('测试后端连接')
        .width('80%')
        .height(50)
        .backgroundColor(0x007AFF)
        .fontColor(Color.White)
        .borderRadius(10)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testBackendConnection()
        })
        .margin({ bottom: 20 })
      
      Button('测试登录API')
        .width('80%')
        .height(50)
        .backgroundColor(0x34C759)
        .fontColor(Color.White)
        .borderRadius(10)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testLoginAPI()
        })
        .margin({ bottom: 20 })
      
      Button('返回登录页')
        .width('80%')
        .height(50)
        .backgroundColor(0xFF9500)
        .fontColor(Color.White)
        .borderRadius(10)
        .onClick(() => {
          router.back()
        })
        .margin({ bottom: 40 })
      
      Text('测试结果:')
        .fontSize(16)
        .fontWeight(600)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })
      
      Text(this.testResult)
        .fontSize(14)
        .fontColor(0x333333)
        .textAlign(TextAlign.Start)
        .width('80%')
        .padding(10)
        .backgroundColor(0xF2F2F7)
        .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }

  // 测试后端连接
  private async testBackendConnection(): Promise<void> {
    this.isLoading = true
    this.testResult = '正在测试后端连接...'
    
    try {
      // 直接使用HTTP测试基础连接（不依赖认证）
      const httpRequest = http.createHttp()
      const baseUrl = AppConfig.baseUrl.replace('/api', '')
      const response = await httpRequest.request(`${baseUrl}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 8000,
        readTimeout: 8000
      })
      
      if (response.responseCode === 200 || response.responseCode === 404) {
        this.testResult = `✅ 后端连接成功！服务器正在运行（状态码: ${response.responseCode})`
      } else {
        this.testResult = `⚠️ 后端连接成功但返回异常状态码: ${response.responseCode}`
      }
    } catch (error) {
      this.testResult = `❌ 后端连接失败: ${error instanceof Error ? error.message : String(error)}`
      
      // 提供详细的错误诊断
      if (error.message.includes('NetworkError')) {
        this.testResult += '\n💡 可能原因: 后端服务未启动或端口被占用'
      } else if (error.message.includes('timeout')) {
        this.testResult += '\n💡 可能原因: 请求超时，检查网络连接'
      }
    } finally {
      this.isLoading = false
    }
  }

  // 测试登录API
  private async testLoginAPI(): Promise<void> {
    this.isLoading = true
    this.testResult = '正在测试登录API...'
    
    try {
      // 首先测试API端点是否存在
      const httpRequest = http.createHttp()
      const testResponse = await httpRequest.request(`${AppConfig.baseUrl}/user/login`, {
        method: http.RequestMethod.OPTIONS,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      
      this.testResult = `✅ API端点存在（状态码: ${testResponse.responseCode})，正在测试登录...`
      
      // 使用测试账号进行登录测试
      const response: ApiResponse<LoginResponse> = await this.apiClient.loginByPassword('zhangsan', '123456')
      
      if (response.code === 1) {
        this.testResult = `✅ 登录API测试成功！\n消息: ${response.message}`
        if (response.data?.token) {
          this.testResult += `\nToken: ${response.data.token.substring(0, 20)}...`
        }
      } else {
        this.testResult = `⚠️ 登录API返回错误: ${response.message} (错误码: ${response.code})`
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      this.testResult = `❌ 登录API测试失败: ${errorMsg}`
      
      // 提供详细的错误诊断
      if (errorMsg.includes('401')) {
        this.testResult += '\n💡 可能原因: 账号密码错误或账号不存在'
        this.testResult += '\n💡 解决方案: 在后端创建测试账号或检查认证逻辑'
      } else if (errorMsg.includes('404')) {
        this.testResult += '\n💡 可能原因: API端点不存在'
        this.testResult += '\n💡 解决方案: 检查后端是否有 /api/auth/login 端点'
      } else if (errorMsg.includes('500')) {
        this.testResult += '\n💡 可能原因: 服务器内部错误'
        this.testResult += '\n💡 解决方案: 检查Spring Boot应用日志'
      } else if (errorMsg.includes('NetworkError')) {
        this.testResult += '\n💡 可能原因: 网络连接问题'
      }
    } finally {
      this.isLoading = false
    }
  }

  aboutToAppear(): void {
    console.log('TestBackendPage loaded')
  }
}