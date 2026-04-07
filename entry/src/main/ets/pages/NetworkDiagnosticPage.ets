import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import http from '@ohos.net.http'
import ApiClient from '../services/ApiClient'
import { AppConfig } from '../config/AppConfig'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius
} from '../config/DesignSystem'

@Entry
@Component
struct NetworkDiagnosticPage {
  @State diagnosticResults: string[] = []
  @State isLoading: boolean = false
  @State currentTest: string = ''
  
  private apiClient = ApiClient

  build() {
    Column() {
      // 头部
      Row() {
        Text('🌐 网络诊断工具')
          .fontSize(AppFonts.fontSize2Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
        
        Blank()
        
        Button('返回')
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.bgColor)
          .fontColor(AppColors.textColor)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
      .backgroundColor(AppColors.bgCard)
      
      // 当前配置信息
      Column() {
        Text('📋 当前配置信息')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ bottom: AppSpacing.spaceLg })
        
        this.buildConfigItem('API地址', AppConfig.baseUrl)
        this.buildConfigItem('超时时间', AppConfig.timeout + 'ms')
        this.buildConfigItem('Mock模式', AppConfig.enableMock ? '开启' : '关闭')
        this.buildConfigItem('日志开关', AppConfig.enableLog ? '开启' : '关闭')
        
        Button('切换到Mock模式')
          .width('100%')
          .height(44)
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.warningColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            this.switchToMockMode()
          })
          .margin({ top: AppSpacing.spaceLg })
      }
      .width('100%')
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.bgCard)
      .borderRadius(AppBorderRadius.radiusLg)
      .margin({ top: AppSpacing.spaceLg, left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
      
      // 网络诊断功能
      Column() {
        Text('🔧 网络诊断')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ bottom: AppSpacing.spaceLg })
        
        this.buildTestButton('基础网络连接', '测试设备网络连通性', () => this.testBasicConnectivity())
        this.buildTestButton('DNS解析测试', '测试域名解析功能', () => this.testDNSResolution())
        this.buildTestButton('API服务器连接', '测试后端API连接', () => this.testAPIServer())
        this.buildTestButton('HTTPS连接测试', '测试安全连接', () => this.testHTTPS())
        
        // 批量测试
        Button('🔄 运行完整诊断')
          .width('100%')
          .height(52)
          .fontSize(AppFonts.fontSizeLg)
          .fontWeight(AppFonts.fontWeightMedium)
          .backgroundColor(AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .onClick(() => {
            this.runFullDiagnostic()
          })
          .margin({ top: AppSpacing.spaceLg })
      }
      .width('100%')
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.bgCard)
      .borderRadius(AppBorderRadius.radiusLg)
      .margin({ top: AppSpacing.spaceLg, left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
      
      // 诊断结果
      Column() {
        Text('📊 诊断结果')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ bottom: AppSpacing.spaceLg })
        
        if (this.diagnosticResults.length === 0) {
          Text('暂无诊断结果，请点击上方按钮开始诊断')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(AppSpacing.space3Xl)
        } else {
          Scroll() {
            Column() {
              ForEach(this.diagnosticResults, (result: string, index: number) => {
                Row() {
                  Text(result)
                    .fontSize(AppFonts.fontSizeBase)
                    .fontColor(result.includes('✅') ? AppColors.successColor : 
                              result.includes('❌') ? AppColors.errorColor : 
                              result.includes('⚠️') ? AppColors.warningColor : AppColors.textColor)
                    .layoutWeight(1)
                  
                  Text(`${index + 1}`)
                    .fontSize(AppFonts.fontSizeSm)
                    .fontColor(AppColors.textSecondary)
                }
                .width('100%')
                .padding(AppSpacing.spaceLg)
                .backgroundColor(AppColors.bgColor)
                .borderRadius(AppBorderRadius.radiusBase)
                .margin({ bottom: AppSpacing.spaceSm })
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
        }
        
        // 解决方案建议
        if (this.diagnosticResults.length > 0) {
          this.buildSolutionSuggestions()
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.bgCard)
      .borderRadius(AppBorderRadius.radiusLg)
      .margin({ top: AppSpacing.spaceLg, left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  @Builder buildConfigItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .layoutWeight(1)
      
      Text(value)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.primaryColor)
        .fontWeight(AppFonts.fontWeightMedium)
    }
    .width('100%')
    .padding(AppSpacing.spaceSm)
    .margin({ bottom: AppSpacing.spaceXs })
  }

  @Builder buildTestButton(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)
        
        Text(description)
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      
      Button('测试')
        .fontSize(AppFonts.fontSizeSm)
        .backgroundColor(AppColors.primaryColor)
        .fontColor(Color.White)
        .borderRadius(AppBorderRadius.radiusBase)
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
        .onClick(onClick)
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgColor)
    .borderRadius(AppBorderRadius.radiusBase)
    .margin({ bottom: AppSpacing.spaceSm })
  }

  @Builder buildSolutionSuggestions() {
    Column() {
      Text('💡 解决方案建议')
        .fontSize(AppFonts.fontSizeLg)
        .fontColor(AppColors.titleColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .margin({ bottom: AppSpacing.spaceLg })
      
      if (this.diagnosticResults.some(r => r.includes('❌ 基础网络连接'))) {
        this.buildSolutionItem('检查设备网络连接', '确保设备已连接到互联网')
        this.buildSolutionItem('检查WiFi/移动数据', '确认网络信号强度')
        this.buildSolutionItem('重启网络设置', '尝试重启设备的网络功能')
      }
      
      if (this.diagnosticResults.some(r => r.includes('❌ DNS解析'))) {
        this.buildSolutionItem('检查DNS设置', '尝试使用公共DNS如8.8.8.8')
        this.buildSolutionItem('直接使用IP地址', '如果可能，使用服务器IP而非域名')
      }
      
      if (this.diagnosticResults.some(r => r.includes('❌ API服务器'))) {
        this.buildSolutionItem('检查API地址', '确认后端服务正在运行')
        this.buildSolutionItem('检查端口和防火墙', '确保端口8080未被防火墙阻止')
        this.buildSolutionItem('切换到Mock模式', '暂时使用Mock数据进行开发')
      }
      
      if (this.diagnosticResults.some(r => r.includes('❌ HTTPS'))) {
        this.buildSolutionItem('检查证书', '确保SSL证书有效')
        this.buildSolutionItem('使用HTTP', '开发环境可暂时使用HTTP')
      }
      
      // 通用建议
      this.buildSolutionItem('重启应用', '关闭并重新启动应用')
      this.buildSolutionItem('检查权限', '确认应用有网络访问权限')
      this.buildSolutionItem('联系技术支持', '如果问题持续存在')
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.warningLight)
    .borderRadius(AppBorderRadius.radiusLg)
    .margin({ top: AppSpacing.spaceLg })
  }

  @Builder buildSolutionItem(title: string, description: string) {
    Row() {
      Text('💡')
        .fontSize(AppFonts.fontSizeLg)
        .margin({ right: AppSpacing.spaceSm })
      
      Column() {
        Text(title)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)
        
        Text(description)
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgColor)
    .borderRadius(AppBorderRadius.radiusBase)
    .margin({ bottom: AppSpacing.spaceSm })
  }

  // 添加诊断结果
  private addDiagnosticResult(result: string): void {
    this.diagnosticResults = [...this.diagnosticResults, result]
  }

  // 测试基础网络连接
  private async testBasicConnectivity(): Promise<void> {
    this.isLoading = true
    this.currentTest = '基础网络连接测试'
    
    try {
      // 测试是否能访问公共网络
      const httpRequest = http.createHttp()
      const response = await httpRequest.request('https://www.baidu.com/', {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      
      if (response.responseCode === 200) {
        this.addDiagnosticResult('✅ 基础网络连接正常 - 可以访问互联网')
      } else {
        this.addDiagnosticResult(`❌ 基础网络连接异常 - 状态码: ${response.responseCode}`)
      }
    } catch (error) {
      this.addDiagnosticResult(`❌ 基础网络连接失败 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试DNS解析
  private async testDNSResolution(): Promise<void> {
    this.isLoading = true
    this.currentTest = 'DNS解析测试'
    
    try {
      // 测试DNS解析
      const httpRequest = http.createHttp()
      const url = AppConfig.baseUrl.replace(/https?:\/\/([^\/]+).*/, '$1')
      const response = await httpRequest.request(`http://${url}/`, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      
      this.addDiagnosticResult('✅ DNS解析正常 - 域名解析成功')
    } catch (error) {
      if (error.code === 200) {
        this.addDiagnosticResult('✅ DNS解析正常 - 服务器响应正常')
      } else {
        this.addDiagnosticResult(`❌ DNS解析失败 - ${error.message}`)
      }
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试API服务器连接
  private async testAPIServer(): Promise<void> {
    this.isLoading = true
    this.currentTest = 'API服务器连接测试'
    
    try {
      const httpRequest = http.createHttp()
      
      // 首先尝试直接连接服务器（不指定路径）
      const baseUrl = AppConfig.baseUrl.replace('/api', '')
      const response = await httpRequest.request(`${baseUrl}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 8000,
        readTimeout: 8000
      })
      
      if (response.responseCode === 200 || response.responseCode === 404) {
        this.addDiagnosticResult('✅ API服务器连接正常 - 服务正在运行')
      } else {
        this.addDiagnosticResult(`⚠️ API服务器响应异常 - 状态码: ${response.responseCode}`)
      }
    } catch (error) {
      this.addDiagnosticResult(`❌ API服务器连接失败 - ${error.message}`)
      
      // 提供更详细的错误信息
      if (error.message.includes('NetworkError')) {
        this.addDiagnosticResult('💡 建议: 检查后端服务是否启动，端口8080是否可用')
      } else if (error.message.includes('timeout')) {
        this.addDiagnosticResult('💡 建议: 请求超时，可能是网络问题或服务器响应慢')
      }
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试HTTPS连接
  private async testHTTPS(): Promise<void> {
    this.isLoading = true
    this.currentTest = 'HTTPS连接测试'
    
    try {
      // 测试HTTPS网站
      const httpRequest = http.createHttp()
      const response = await httpRequest.request('https://api.github.com/', {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      
      if (response.responseCode === 200) {
        this.addDiagnosticResult('✅ HTTPS连接正常 - 安全连接建立成功')
      } else {
        this.addDiagnosticResult(`⚠️ HTTPS连接异常 - 状态码: ${response.responseCode}`)
      }
    } catch (error) {
      this.addDiagnosticResult(`❌ HTTPS连接失败 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 运行完整诊断
  private async runFullDiagnostic(): Promise<void> {
    this.diagnosticResults = []
    
    await this.testBasicConnectivity()
    await this.testDNSResolution()
    await this.testAPIServer()
    await this.testHTTPS()
    
    // 显示诊断总结
    const successCount = this.diagnosticResults.filter(r => r.includes('✅')).length
    const totalCount = this.diagnosticResults.length
    
    this.addDiagnosticResult(`📈 诊断总结: ${successCount}/${totalCount} 项测试通过`)
  }

  // 切换到Mock模式
  private switchToMockMode(): void {
    // 这里需要修改AppConfig的enableMock属性
    // 由于ArkTS的限制，我们需要创建一个新的配置实例
    this.addDiagnosticResult('🔄 正在切换到Mock模式...')
    
    // 提示用户需要重启应用
    promptAction.showToast({
      message: '请手动修改AppConfig.ets中的enableMock为true并重启应用',
      duration: 4000
    })
    
    this.addDiagnosticResult('💡 修改提示: 请编辑AppConfig.ets文件，将enableMock设置为true')
  }
}