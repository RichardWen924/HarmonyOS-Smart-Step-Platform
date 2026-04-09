import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { UserInfoImpl } from '../services/StateStore'
import { ApiResponse, LoginResponse } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppAnimations
} from '../config/DesignSystem'
import AppConfig from '../config/AppConfig'

enum LoginType {
  PASSWORD = 1,
  VERIFICATION_CODE = 2
}

@Entry
@Component
struct LoginPage {
  // 登录相关
  @State account: string = ''
  @State password: string = ''
  @State loginType: LoginType = LoginType.PASSWORD

  // 注册相关
  @State email: string = ''
  @State verificationCode: string = ''
  @State nickname: string = ''
  @State confirmPassword: string = ''

  // UI 状态
  @State isRegisterMode: boolean = false
  @State isLoading: boolean = false
  @State countdown: number = 0
  @State isSendingCode: boolean = false
  @State showPassword: boolean = false

  private apiClient = ApiClient
  private stateStore = StateStore

  build() {
    Column() {
      // 顶部装饰背景 - 固定高度，不会被Scroll遮挡
      this.buildBackground()

      Scroll() {
        Column() {
          // Logo 和标题
          this.buildHeader()

          // 表单区域
          this.buildForm()

          // 底部链接
          this.buildFooter()
        }
        .width('100%')
        .padding(AppSpacing.space3Xl)
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .margin({ top: -40 }) // 向上偏移，确保背景不会被遮挡
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgCard)
    .clip(true) // 添加裁剪，防止内容溢出
  }

  // 构建背景装饰
  @Builder buildBackground() {
    Column() {
      // 渐变背景装饰
      Row() {
        Column()
          .width(80)
          .height(80)
          .backgroundColor(AppColors.primaryLight)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.3)
          .margin({ right: AppSpacing.space2Xl })

        Column()
          .width(60)
          .height(60)
          .backgroundColor(AppColors.successLight)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.2)
          .margin({ top: AppSpacing.space3Xl })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl })

      // 添加一些间距，确保Logo区域不会被遮挡
      Blank()
        .height(60)
    }
    .width('100%')
    .height(150) // 减少高度，避免过度占用空间
  }

  // 构建头部
  @Builder buildHeader() {
    Column() {
      // Logo 区域
      Column() {
        Text(AppIcons.steps)
          .fontSize(64)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.primaryColor)
          .margin({ bottom: AppSpacing.spaceSm })

        Text('运动健康')
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceXs })

        Text('每一步都算数')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: AppSpacing.space2Xl, bottom: AppSpacing.space4Xl })

      // 标题
      Column() {
        Text(this.isRegisterMode ? '注册账号' : '欢迎回来')
          .fontSize(AppFonts.fontSize4Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceSm })

        Text(this.isRegisterMode ? '开启您的运动之旅' : '记录每一步的精彩')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: AppSpacing.space4Xl })
    }
  }

  // 构建表单
  @Builder buildForm() {
    Column() {
      if (this.isRegisterMode) {
        // 注册表单
        this.buildEmailInput()
        this.buildVerificationCodeInput()
        this.buildNicknameInput()
        this.buildPasswordInput(true)
        this.buildConfirmPasswordInput()

        Button('立即注册')
          .width('100%')
          .height(52)
          .fontSize(AppFonts.fontSizeLg)
          .fontWeight(AppFonts.fontWeightMedium)
          .backgroundColor(AppColors.successColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .enabled(!this.isLoading && this.canRegister())
          .opacity(this.canRegister() ? 1 : 0.6)
          .onClick(() => {
            this.handleRegister()
          })
          .margin({ top: AppSpacing.spaceLg })
      } else {
        // 登录表单
        this.buildAccountInput()

        // 登录方式切换
        Row() {
          Text('登录方式')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)

          Blank()

          Text(this.loginType === LoginType.PASSWORD ? '密码登录' : '验证码登录')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)
            .onClick(() => {
              this.loginType = this.loginType === LoginType.PASSWORD
                ? LoginType.VERIFICATION_CODE
                : LoginType.PASSWORD
            })
        }
        .width('100%')
        .margin({ bottom: AppSpacing.spaceLg })

        if (this.loginType === LoginType.PASSWORD) {
          this.buildPasswordInput(false)
        } else {
          this.buildVerificationCodeInput(false)
        }

        Button('登录')
          .width('100%')
          .height(52)
          .fontSize(AppFonts.fontSizeLg)
          .fontWeight(AppFonts.fontWeightMedium)
          .backgroundColor(AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .enabled(!this.isLoading && this.canLogin())
          .opacity(this.canLogin() ? 1 : 0.6)
          .onClick(() => {
            this.handleLogin()
          })
          .margin({ top: AppSpacing.spaceLg })

        // 忘记密码
        Row() {
          Blank()

          Text('忘记密码？')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)
            .onClick(() => {
              promptAction.showToast({
                message: '请联系客服重置密码',
                duration: 2000
              })
            })
        }
        .width('100%')
        .margin({ top: AppSpacing.spaceLg })
      }
    }
    .width('100%')
  }

  // 构建账号输入
  @Builder buildAccountInput() {
    Column() {
      Text('账号')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      TextInput({ placeholder: '请输入用户名或邮箱' })
        .width('100%')
        .height(52)
        .borderRadius(AppBorderRadius.radiusBase)
        .backgroundColor(AppColors.bgColor)
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .onChange((value: string) => {
          this.account = value.trim()
        })
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建邮箱输入
  @Builder buildEmailInput() {
    Column() {
      Text('邮箱')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      TextInput({ placeholder: '请输入邮箱地址' })
        .width('100%')
        .height(52)
        .borderRadius(AppBorderRadius.radiusBase)
        .backgroundColor(AppColors.bgColor)
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
        .type(InputType.Email)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .onChange((value: string) => {
          this.email = value.trim()
        })
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建验证码输入
  @Builder buildVerificationCodeInput(forRegister: boolean = true) {
    Column() {
      Text('验证码')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      Row() {
        TextInput({ placeholder: '请输入验证码' })
          .layoutWeight(1)
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .onChange((value: string) => {
            this.verificationCode = value.trim()
          })

        Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.countdown > 0 || this.isSendingCode ? AppColors.borderColor : AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radiusBase)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .margin({ left: AppSpacing.spaceSm })
          .enabled(this.countdown === 0 && !this.isSendingCode)
          .onClick(() => {
            this.sendVerificationCode(forRegister)
          })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建昵称输入
  @Builder buildNicknameInput() {
    Column() {
      Text('昵称（可选）')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      TextInput({ placeholder: '请输入昵称' })
        .width('100%')
        .height(52)
        .borderRadius(AppBorderRadius.radiusBase)
        .backgroundColor(AppColors.bgColor)
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .onChange((value: string) => {
          this.nickname = value.trim()
        })
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建密码输入
  @Builder buildPasswordInput(isRegister: boolean) {
    Column() {
      Text('密码')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      Row() {
        TextInput({ placeholder: isRegister ? '请设置密码' : '请输入密码' })
          .layoutWeight(1)
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .onChange((value: string) => {
            this.password = value
          })

        // 显示/隐藏密码按钮
        Text(this.showPassword ? '🙈' : '👁️')
          .fontSize(AppFonts.fontSizeLg)
          .margin({ left: AppSpacing.spaceSm })
          .onClick(() => {
            this.showPassword = !this.showPassword
          })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: isRegister ? AppSpacing.spaceLg : 0 })
  }

  // 构建确认密码输入
  @Builder buildConfirmPasswordInput() {
    Column() {
      Text('确认密码')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceSm })

      TextInput({ placeholder: '请再次输入密码' })
        .width('100%')
        .height(52)
        .borderRadius(AppBorderRadius.radiusBase)
        .backgroundColor(AppColors.bgColor)
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
        .type(InputType.Password)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .onChange((value: string) => {
          this.confirmPassword = value
        })
    }
    .width('100%')
    .margin({ bottom: AppSpacing.space3Xl })
  }

  // 构建底部
  @Builder buildFooter() {
    Column() {
      Row() {
        Text(this.isRegisterMode ? '已有账号？' : '没有账号？')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)

        Text(this.isRegisterMode ? '立即登录' : '立即注册')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.primaryColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .margin({ left: AppSpacing.spaceSm })
          .onClick(() => {
            this.isRegisterMode = !this.isRegisterMode
            this.clearForm()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: AppSpacing.space3Xl })

      // 开发模式下的测试按钮
      if (this.isDevelopmentMode()) {
        this.buildTestButton()
      }
    }
  }

  // 验证是否可以登录
  private canLogin(): boolean {
    if (!this.account) return false
    if (this.loginType === LoginType.PASSWORD && !this.password) return false
    if (this.loginType === LoginType.VERIFICATION_CODE && !this.verificationCode) return false
    return true
  }

  // 验证是否可以注册
  private canRegister(): boolean {
    if (!this.email || !this.password || !this.confirmPassword || !this.verificationCode) return false
    if (this.password !== this.confirmPassword) return false
    if (this.password.length < 6) return false
    return true
  }

  // 发送验证码
  private async sendVerificationCode(forRegister: boolean): Promise<void> {
    const targetEmail = forRegister ? this.email : this.account

    if (!targetEmail || !targetEmail.includes('@')) {
      promptAction.showToast({
        message: '请输入有效的邮箱地址',
        duration: 2000
      })
      return
    }

    this.isSendingCode = true

    try {
      const response = await this.apiClient.sendVerificationCode(targetEmail)

      if (response.code === 1) {
        promptAction.showToast({
          message: '验证码已发送',
          duration: 2000
        })

        // 开始倒计时
        this.countdown = 60
        const timer = setInterval(() => {
          this.countdown--
          if (this.countdown <= 0) {
            clearInterval(timer)
          }
        }, 1000)
      } else {
        promptAction.showToast({
          message: response.message,
          duration: 2000
        })
      }
    } catch (error) {
      promptAction.showToast({
        message: '发送失败',
        duration: 2000
      })
    } finally {
      this.isSendingCode = false
    }
  }

  // 处理登录
  private async handleLogin(): Promise<void> {
    if (!this.canLogin()) {
      promptAction.showToast({
        message: '请填写完整信息',
        duration: 2000
      })
      return
    }

    this.isLoading = true

    try {
      let response: ApiResponse<LoginResponse>

      if (this.loginType === LoginType.PASSWORD) {
        response = await this.apiClient.loginByPassword(this.account, this.password)
      } else {
        response = await this.apiClient.loginByCode(this.account, this.verificationCode)
      }

      if (response.code === 1 && response.data) {
        console.log('Login successful!')
        console.log('Token:', response.data.token ? response.data.token.substring(0, 20) + '...' : 'null')
        console.log('UserInfo:', JSON.stringify(response.data.userInfo))

        // 保存用户信息和Token
        await this.stateStore.login(response.data.userInfo, response.data.token)

        promptAction.showToast({
          message: '登录成功',
          duration: 1500
        })

        // 跳转到主页面
        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/MainPage'
          })
        }, 1500)
      } else {
        console.error('Login failed:', response.message)
        promptAction.showToast({
          message: response.message,
          duration: 2000
        })
      }
    } catch (error) {
      console.error('Login failed:', error)
      promptAction.showToast({
        message: error.message.includes('Mock数据') ? '登录成功（测试模式）' : '登录失败，请检查网络连接',
        duration: 2000
      })
    } finally {
      this.isLoading = false
    }
  }

  // 处理注册
  private async handleRegister(): Promise<void> {
    if (!this.canRegister()) {
      if (this.password !== this.confirmPassword) {
        promptAction.showToast({
          message: '两次输入的密码不一致',
          duration: 2000
        })
        return
      }

      promptAction.showToast({
        message: '请填写完整信息',
        duration: 2000
      })
      return
    }

    this.isLoading = true

    try {
      const response = await this.apiClient.register(
        this.email,
        this.verificationCode
      )

      if (response.code === 1) {
        console.log('Register successful! User should login now.')

        promptAction.showToast({
          message: '注册成功，请登录',
          duration: 1500
        })

        // 注册成功后切换到登录模式，而不是直接跳转
        setTimeout(() => {
          this.isRegisterMode = false
          this.clearForm()
        }, 1500)
      } else {
        console.error('Register failed:', response.message)
        promptAction.showToast({
          message: response.message,
          duration: 2000
        })
      }
    } catch (error) {
      console.error('Register failed:', error)
      promptAction.showToast({
        message: error.message.includes('Mock数据') ? '注册成功（测试模式）' : '注册失败，请检查网络连接',
        duration: 2000
      })
    } finally {
      this.isLoading = false
    }
  }

  // 清空表单
  private clearForm(): void {
    this.account = ''
    this.password = ''
    this.email = ''
    this.verificationCode = ''
    this.nickname = ''
    this.confirmPassword = ''
    this.countdown = 0
    this.showPassword = false
  }

  // 判断是否为开发模式
  private isDevelopmentMode(): boolean {
    return AppConfig.enableLog
  }

  // 构建测试按钮
  @Builder buildTestButton() {
    Row() {
      Text('测试后端连接')
        .fontSize(AppFonts.fontSizeSm)
        .fontColor(AppColors.warningColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .margin({ left: AppSpacing.spaceSm })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/TestBackendPage'
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: AppSpacing.spaceLg })
  }
}