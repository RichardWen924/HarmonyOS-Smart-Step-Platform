import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import { NetworkTest, NetworkDiagnosticResult } from '../utils/NetworkTest'

@Entry
@Component
struct TestBackendPage {
  @State testResults: string[] = []
  @State isTesting: boolean = false
  @State diagnosticInfo: NetworkDiagnosticResult | null = null

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('后端连接测试')
          .fontSize(AppFonts.fontSize2Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
        
        Blank()
        
        Text('返回')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.primaryColor)
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding({ top: AppSpacing.space3Xl, bottom: AppSpacing.space3Xl })
      
      // 测试按钮
      Button(this.isTesting ? '测试中...' : '开始网络诊断')
        .width('90%')
        .height(52)
        .fontSize(AppFonts.fontSizeLg)
        .fontWeight(AppFonts.fontWeightMedium)
        .backgroundColor(AppColors.primaryColor)
        .fontColor(Color.White)
        .borderRadius(AppBorderRadius.radius2Xl)
        .enabled(!this.isTesting)
        .onClick(() => {
          this.runNetworkTests()
        })
        .margin({ bottom: AppSpacing.space3Xl })
      
      // 测试结果
      if (this.testResults.length > 0) {
        Column() {
          Text('测试结果')
            .fontSize(AppFonts.fontSizeLg)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: AppSpacing.spaceLg })
          
          Scroll() {
            Column() {
              ForEach(this.testResults, (result: string, index: number) => {
                Row() {
                  Text(result.includes('✅') ? '✅' : result.includes('❌') ? '❌' : result.includes('⚠️') ? '⚠️' : '•')
                    .fontSize(AppFonts.fontSizeBase)
                    .fontColor(result.includes('✅') ? AppColors.successColor : 
                              result.includes('❌') ? AppColors.errorColor : 
                              result.includes('⚠️') ? AppColors.warningColor : AppColors.textColor)
                    .margin({ right: AppSpacing.spaceSm })
                  
                  Text(result.replace(/[✅❌⚠️]/g, '').trim())
                    .fontSize(AppFonts.fontSizeBase)
                    .fontColor(AppColors.textColor)
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding(AppSpacing.spaceLg)
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        // 空状态
        Column() {
          Text('📡')
            .fontSize(64)
            .fontColor(AppColors.textSecondary)
            .margin({ bottom: AppSpacing.spaceLg })
          
          Text('网络诊断')
            .fontSize(AppFonts.fontSizeXl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .margin({ bottom: AppSpacing.spaceSm })
          
          Text('点击上方按钮开始测试后端连接状态')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      
      // 诊断信息
      if (this.diagnosticInfo) {
        Column() {
          Text('诊断建议')
            .fontSize(AppFonts.fontSizeLg)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: AppSpacing.spaceLg })
          
          ForEach(this.diagnosticInfo.suggestions, (suggestion: string, index: number) => {
            Row() {
              Text('•')
                .fontSize(AppFonts.fontSizeBase)
                .fontColor(AppColors.primaryColor)
                .margin({ right: AppSpacing.spaceSm })
              
              Text(suggestion)
                .fontSize(AppFonts.fontSizeBase)
                .fontColor(AppColors.textColor)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: AppSpacing.spaceXs, bottom: AppSpacing.spaceXs })
          })
        }
        .width('100%')
        .padding({ top: AppSpacing.space3Xl })
      }
    }
    .width('100%')
    .height('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
  }

  // 运行网络测试
  private async runNetworkTests(): Promise<void> {
    this.isTesting = true
    this.testResults = []
    this.diagnosticInfo = null
    
    try {
      // 添加测试开始信息
      this.addTestResult('开始网络连接诊断...')
      
      // 获取详细诊断信息
      const diagnostics = await NetworkTest.getNetworkDiagnostics()
      this.diagnosticInfo = diagnostics
      
      // 记录设备网络状态
      if (diagnostics.deviceNetwork) {
        this.addTestResult('✅ 设备网络连接正常')
      } else {
        this.addTestResult('❌ 设备网络连接异常')
      }
      
      // 记录后端连接状态
      if (diagnostics.backendConnection) {
        this.addTestResult('✅ 后端服务连接成功')
      } else {
        this.addTestResult('❌ 后端服务连接失败')
      }
      
      // 记录API端点状态
      for (const endpoint of diagnostics.apiEndpoints) {
        if (endpoint.available) {
          this.addTestResult(`✅ ${endpoint.endpoint} - 端点可用 (${endpoint.statusCode})`)
        } else {
          this.addTestResult(`❌ ${endpoint.endpoint} - 端点不可用`)
        }
      }
      
      // 显示总体状态
      if (diagnostics.backendConnection && diagnostics.apiEndpoints.some(ep => ep.available)) {
        this.addTestResult('✅ 后端服务状态正常')
      } else {
        this.addTestResult('❌ 后端服务存在连接问题')
      }
      
    } catch (error) {
      this.addTestResult(`❌ 测试过程中发生错误: ${error.message}`)
    } finally {
      this.isTesting = false
    }
  }

  // 添加测试结果
  private addTestResult(result: string): void {
    this.testResults = [...this.testResults, result]
  }
}