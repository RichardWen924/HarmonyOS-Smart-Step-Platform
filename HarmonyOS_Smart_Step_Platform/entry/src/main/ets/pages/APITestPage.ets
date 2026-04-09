import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { LoginResponse, UserInfo, ApiResponse } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius
} from '../config/DesignSystem'

@Entry
@Component
struct APITestPage {
  @State testResults: string[] = []
  @State isLoading: boolean = false
  @State currentTest: string = ''
  
  private apiClient = ApiClient
  private stateStore = StateStore

  build() {
    Column() {
      // 头部
      Row() {
        Text('🔧 API功能测试')
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
      
      // 测试按钮
      Column() {
        Text('选择要测试的API功能：')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ bottom: AppSpacing.spaceLg })
        
        this.buildTestButton('登录API', '测试用户登录功能', () => this.testLogin())
        this.buildTestButton('注册API', '测试用户注册功能', () => this.testRegister())
        this.buildTestButton('用户信息API', '测试获取用户信息', () => this.testUserInfo())
        this.buildTestButton('验证码API', '测试验证码发送', () => this.testVerificationCode())
        this.buildTestButton('修改信息API', '测试用户信息修改', () => this.testUpdateUserInfo())
        this.buildTestButton('修改密码API', '测试密码修改', () => this.testChangePassword())
        
        // 批量测试
        Button('🧪 批量测试所有API')
          .width('100%')
          .height(52)
          .fontSize(AppFonts.fontSizeLg)
          .fontWeight(AppFonts.fontWeightMedium)
          .backgroundColor(AppColors.successColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .onClick(() => {
            this.runAllTests()
          })
          .margin({ top: AppSpacing.spaceLg })
      }
      .width('100%')
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.bgCard)
      .borderRadius(AppBorderRadius.radiusLg)
      .margin({ top: AppSpacing.spaceLg, left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
      
      // 测试结果
      Column() {
        Text('📊 测试结果')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ bottom: AppSpacing.spaceLg })
        
        if (this.testResults.length === 0) {
          Text('暂无测试结果，请点击上方按钮开始测试')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(AppSpacing.space3Xl)
        } else {
          Scroll() {
            Column() {
              ForEach(this.testResults, (result: string, index: number) => {
                Row() {
                  Text(result)
                    .fontSize(AppFonts.fontSizeBase)
                    .fontColor(result.includes('✅') ? AppColors.successColor : 
                              result.includes('❌') ? AppColors.errorColor : AppColors.textColor)
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
        
        // 清空结果
        if (this.testResults.length > 0) {
          Button('清空结果')
            .width('100%')
            .height(44)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.bgColor)
            .fontColor(AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .onClick(() => {
              this.testResults = []
            })
            .margin({ top: AppSpacing.spaceLg })
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

  // 添加测试结果
  private addTestResult(result: string): void {
    this.testResults = [...this.testResults, result]
  }

  // 测试登录功能
  private async testLogin(): Promise<void> {
    this.isLoading = true
    this.currentTest = '登录测试'
    
    try {
      const response = await this.apiClient.loginByPassword('zhangsan', '123456')
      
      if (response.code === 1 && response.data) {
        this.addTestResult(`✅ 登录测试成功 - Token: ${response.data.token.substring(0, 20)}...`)
        
        // 保存用户信息用于后续测试
        await this.stateStore.login(response.data.userInfo, response.data.token)
      } else {
        this.addTestResult(`❌ 登录测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 登录测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试注册功能
  private async testRegister(): Promise<void> {
    this.isLoading = true
    this.currentTest = '注册测试'
    
    try {
      const response = await this.apiClient.register(
        'newuser@example.com',
        '123456'
      )
      
      if (response.code === 1) {
        this.addTestResult(`✅ 注册测试成功`)
      } else {
        this.addTestResult(`❌ 注册测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 注册测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试获取用户信息
  private async testUserInfo(): Promise<void> {
    this.isLoading = true
    this.currentTest = '用户信息测试'
    
    try {
      // 确保ApiClient有正确的Token
      this.syncTokenToApiClient()
      
      const response = await this.apiClient.getUserInfo()
      
      if (response.code === 1 && response.data) {
        this.addTestResult(`✅ 用户信息测试成功 - 用户名: ${response.data.username}, 积分: ${response.data.totalPoints}`)
      } else {
        this.addTestResult(`❌ 用户信息测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 用户信息测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试验证码发送
  private async testVerificationCode(): Promise<void> {
    this.isLoading = true
    this.currentTest = '验证码测试'
    
    try {
      const response = await this.apiClient.sendVerificationCode('test@example.com')
      
      if (response.code === 1) {
        this.addTestResult('✅ 验证码发送测试成功')
      } else {
        this.addTestResult(`❌ 验证码发送测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 验证码发送测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试修改用户信息
  private async testUpdateUserInfo(): Promise<void> {
    this.isLoading = true
    this.currentTest = '修改信息测试'
    
    try {
      // 确保ApiClient有正确的Token
      this.syncTokenToApiClient()
      
      const response = await this.apiClient.updateUserInfo({
        nickname: '测试昵称' + Date.now().toString().slice(-4),
        sex: 1
      })
      
      if (response.code === 1) {
        this.addTestResult('✅ 修改用户信息测试成功')
      } else {
        this.addTestResult(`❌ 修改用户信息测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 修改用户信息测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 测试修改密码
  private async testChangePassword(): Promise<void> {
    this.isLoading = true
    this.currentTest = '修改密码测试'
    
    try {
      // 确保ApiClient有正确的Token
      this.syncTokenToApiClient()
      
      const response = await this.apiClient.updatePassword('oldpassword', 'newpassword')
      
      if (response.code === 1) {
        this.addTestResult('✅ 修改密码测试成功')
      } else {
        this.addTestResult(`❌ 修改密码测试失败 - ${response.message}`)
      }
    } catch (error) {
      this.addTestResult(`❌ 修改密码测试异常 - ${error.message}`)
    } finally {
      this.isLoading = false
      this.currentTest = ''
    }
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('APITestPage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('APITestPage: StateStore中没有找到Token')
    }
  }

  // 批量运行所有测试
  private async runAllTests(): Promise<void> {
    this.testResults = []
    
    // 先测试登录
    await this.testLogin()
    
    // 如果登录成功，测试其他需要登录的功能
    if (this.testResults[0]?.includes('✅')) {
      await this.testUserInfo()
      await this.testUpdateUserInfo()
      await this.testChangePassword()
    }
    
    // 测试不需要登录的功能
    await this.testRegister()
    await this.testVerificationCode()
    
    // 显示测试总结
    const successCount = this.testResults.filter(r => r.includes('✅')).length
    const totalCount = this.testResults.length
    
    this.addTestResult(`📈 测试总结: ${successCount}/${totalCount} 项测试通过`)
  }
}
