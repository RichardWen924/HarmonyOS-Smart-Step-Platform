import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius
} from '../config/DesignSystem'
import { NetworkTest } from '../utils/NetworkTest'

@Entry
@Component
struct SimpleNetworkTest {
  @State testResult: string = '点击按钮开始测试'
  @State isTesting: boolean = false

  build() {
    Column() {
      // 标题
      Text('网络连接测试')
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)
        .margin({ bottom: AppSpacing.space3Xl })
      
      // 测试按钮
      Button(this.isTesting ? '测试中...' : '测试网络连接')
        .width('80%')
        .height(52)
        .fontSize(AppFonts.fontSizeLg)
        .fontWeight(AppFonts.fontWeightMedium)
        .backgroundColor(AppColors.primaryColor)
        .fontColor(Color.White)
        .borderRadius(AppBorderRadius.radius2Xl)
        .enabled(!this.isTesting)
        .onClick(() => {
          this.runNetworkTest()
        })
        .margin({ bottom: AppSpacing.space3Xl })
      
      // 测试结果
      Text(this.testResult)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .textAlign(TextAlign.Center)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.bgColor)
        .borderRadius(AppBorderRadius.radiusBase)
        .width('90%')
      
      // 返回按钮
      Button('返回')
        .width('60%')
        .height(44)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.primaryColor)
        .backgroundColor(Color.Transparent)
        .border({
          width: 1,
          color: AppColors.primaryColor,
          radius: AppBorderRadius.radius2Xl
        })
        .onClick(() => {
          router.back()
        })
        .margin({ top: AppSpacing.space4Xl })
      
    }
    .width('100%')
    .height('100%')
    .padding(AppSpacing.space3Xl)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.bgCard)
  }

  // 运行网络测试
  private async runNetworkTest(): Promise<void> {
    this.isTesting = true
    this.testResult = '开始测试网络连接...'
    
    try {
      const diagnostics = await NetworkTest.getNetworkDiagnostics()
      
      if (diagnostics.deviceNetwork && diagnostics.backendConnection) {
        this.testResult = '✅ 网络连接正常！\n设备网络和后端服务均可访问'
      } else if (diagnostics.deviceNetwork && !diagnostics.backendConnection) {
        this.testResult = '⚠️ 设备网络正常，但后端服务不可用\n请检查后端服务是否启动'
      } else if (!diagnostics.deviceNetwork) {
        this.testResult = '❌ 设备网络连接异常\n请检查设备网络设置'
      } else {
        this.testResult = '❌ 网络连接异常\n请检查网络配置'
      }
      
      // 添加详细诊断信息
      this.testResult += '\n\n诊断详情:'
      this.testResult += `\n• 设备网络: ${diagnostics.deviceNetwork ? '✅' : '❌'}`
      this.testResult += `\n• 后端连接: ${diagnostics.backendConnection ? '✅' : '❌'}`
      
      if (diagnostics.suggestions.length > 0) {
        this.testResult += '\n\n建议:'
        diagnostics.suggestions.forEach(suggestion => {
          this.testResult += `\n• ${suggestion}`
        })
      }
      
    } catch (error) {
      this.testResult = `❌ 测试失败: ${error.message}`
    } finally {
      this.isTesting = false
    }
  }
}