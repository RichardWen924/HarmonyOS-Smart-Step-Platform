import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import http from '@ohos.net.http'
import ApiClient from '../services/ApiClient'

@Entry
@Component
struct DebugLoginPage {
  @State testResult: string = ''
  @State isLoading: boolean = false

  build() {
    Column() {
      Text('登录调试页面')
        .fontSize(24)
        .fontWeight(700)
        .margin({ bottom: 20 })

      Button('测试直接HTTP请求')
        .width('80%')
        .height(50)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testDirectHttpRequest()
        })
        .margin({ bottom: 10 })

      Button('测试ApiClient登录')
        .width('80%')
        .height(50)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testApiClientLogin()
        })
        .margin({ bottom: 10 })

      Button('测试OPTIONS请求')
        .width('80%')
        .height(50)
        .backgroundColor('#FF9500')
        .fontColor(Color.White)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.testOptionsRequest()
        })
        .margin({ bottom: 10 })

      Text('测试结果:')
        .fontSize(16)
        .fontWeight(500)
        .margin({ bottom: 10 })

      Scroll() {
        Text(this.testResult)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
      }
      .height(200)
      .border({ width: 1, color: '#E5E5E5' })
      .padding(10)
      .margin({ bottom: 20 })

      Button('Token调试')
        .width('80%')
        .height(50)
        .backgroundColor('#AF52DE')
        .fontColor(Color.White)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.debugToken()
        })
        .margin({ bottom: 10 })

      Button('返回登录页面')
        .width('80%')
        .height(50)
        .backgroundColor('#34C759')
        .fontColor(Color.White)
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }

  // 测试直接HTTP请求
  private async testDirectHttpRequest(): Promise<void> {
    this.isLoading = true
    this.testResult = '正在测试直接HTTP请求...'

    let httpRequest: http.HttpRequest | null = null
    
    try {
      httpRequest = http.createHttp()
      const url = 'http://192.168.59.116:8082/user/login'
      
      console.log('测试直接HTTP请求，URL:', url)
      
      // 创建请求数据类
      class LoginRequestData {
        username: string = 'testuser'
        password: string = 'testpass'
      }
      
      const requestData = new LoginRequestData()

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      })

      console.log('直接HTTP请求响应:', response)
      
      this.testResult = `直接HTTP请求结果:
状态码: ${response.responseCode}
响应头: ${JSON.stringify(response.header)}
响应体: ${response.result}
完整响应: ${JSON.stringify(response, null, 2)}`

    } catch (error) {
      console.error('直接HTTP请求错误:', error)
      this.testResult = `直接HTTP请求错误:
${error.message || error}
${error.stack || ''}`
    } finally {
      this.isLoading = false
      if (httpRequest) {
        httpRequest.destroy()
      }
    }
  }

  // 测试ApiClient登录
  private async testApiClientLogin(): Promise<void> {
    this.isLoading = true
    this.testResult = '正在测试ApiClient登录...'

    try {
      console.log('开始测试ApiClient登录')
      
      const response = await ApiClient.loginByPassword('testuser', 'testpass')
      
      console.log('ApiClient登录响应:', response)
      
      this.testResult = `ApiClient登录结果:
状态码: ${response.code}
消息: ${response.message}
数据: ${JSON.stringify(response.data, null, 2)}`

    } catch (error) {
      console.error('ApiClient登录错误:', error)
      this.testResult = `ApiClient登录错误:
${error.message || error}
${error.stack || ''}`
    } finally {
      this.isLoading = false
    }
  }

  // 测试OPTIONS请求
  private async testOptionsRequest(): Promise<void> {
    this.isLoading = true
    this.testResult = '正在测试OPTIONS请求...'

    let httpRequest: http.HttpRequest | null = null
    
    try {
      httpRequest = http.createHttp()
      const url = 'http://192.168.59.116:8082/user/login'
      
      console.log('测试OPTIONS请求，URL:', url)
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.OPTIONS,
        header: {
          'Content-Type': 'application/json',
          'Access-Control-Request-Method': 'POST'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      })

      console.log('OPTIONS请求响应:', response)
      
      this.testResult = `OPTIONS请求结果:
状态码: ${response.responseCode}
响应头: ${JSON.stringify(response.header)}
响应体: ${response.result}
完整响应: ${JSON.stringify(response, null, 2)}`

    } catch (error) {
      console.error('OPTIONS请求错误:', error)
      this.testResult = `OPTIONS请求错误:
${error.message || error}
${error.stack || ''}`
    } finally {
      this.isLoading = false
      if (httpRequest) {
        httpRequest.destroy()
      }
    }
  }

  // Token调试
  private debugToken(): void {
    const token = ApiClient.getToken()
    console.log('Current token:', token)
    
    if (token) {
      this.testResult = `Token调试结果:
当前Token: ${token}
Token长度: ${token.length}
Token前20字符: ${token.substring(0, 20)}...`
      
      // 测试带Token的请求
      this.testAuthenticatedRequest()
    } else {
      this.testResult = 'Token调试结果:\n当前没有Token，请先登录'
    }
  }

  // 测试带Token的认证请求
  private async testAuthenticatedRequest(): Promise<void> {
    this.isLoading = true
    this.testResult += '\n\n正在测试带Token的认证请求...'

    let httpRequest: http.HttpRequest | null = null
    
    try {
      httpRequest = http.createHttp()
      const url = 'http://192.168.59.116:8082/user'
      const token = ApiClient.getToken()
      
      console.log('测试认证请求，URL:', url)
      console.log('使用Token:', token)
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      })

      console.log('认证请求响应:', response)
      
      this.testResult += `\n认证请求结果:
状态码: ${response.responseCode}
响应头: ${JSON.stringify(response.header)}
响应体: ${response.result}`

    } catch (error) {
      console.error('认证请求错误:', error)
      this.testResult += `\n认证请求错误:
${error.message || error}`
    } finally {
      this.isLoading = false
      if (httpRequest) {
        httpRequest.destroy()
      }
    }
  }
}