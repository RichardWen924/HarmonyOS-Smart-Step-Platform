import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import StateStore, { UserInfoImpl } from '../services/StateStore'
import ApiClient from '../services/ApiClient'
import { UserInfo } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import AppShadows from '../config/AppShadows'

@Entry
@Component
struct ProfilePage {
  @State userInfo: UserInfo | null = null
  @State isEditing: boolean = false
  @State editNickname: string = ''
  @State editEmail: string = ''
  @State editSex: number = 0
  @State showPasswordDialog: boolean = false
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State isLoading: boolean = false
  
  private stateStore = StateStore
  private apiClient = ApiClient

  async aboutToAppear() {
    // 确保ApiClient有正确的Token
    const hasToken = await this.syncTokenToApiClient()
    if (hasToken) {
      this.loadUserInfo()
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        this.buildHeader()
        
        Scroll() {
          Column() {
            // 用户信息卡片
            this.buildUserCard()
            
            // 统计数据
            this.buildStatistics()
            
            // 功能菜单
            this.buildFunctionMenu()
            
            // 退出登录
            this.buildLogoutButton()
          }
          .width('100%')
          .padding(AppSpacing.spaceLg)
        }
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.bgColor)
      
      // 密码修改对话框
      if (this.showPasswordDialog) {
        this.buildPasswordDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 构建头部
  @Builder buildHeader() {
    Row() {
      Text('个人中心')
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)
      
      Blank()
      
      if (this.isEditing) {
        Row() {
          Text('取消')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .fontWeight(AppFonts.fontWeightMedium)
            .onClick(() => {
              this.isEditing = false
              this.loadUserInfo()
            })
          
          Button('保存')
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radius2Xl)
            .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
            .margin({ left: AppSpacing.spaceSm })
            .onClick(() => {
              this.saveUserInfo()
            })
        }
      } else {
        Button('编辑')
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.bgColor)
          .fontColor(AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
          .onClick(() => {
            this.startEditing()
          })
      }
    }
    .width('100%')
    .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
  }

  // 构建用户信息卡片
  @Builder buildUserCard() {
    Column() {
      // 头像
      Column() {
        Text(AppIcons.profile)
          .fontSize(48)
        
        if (this.isEditing) {
          Text('点击修改头像')
            .fontSize(AppFonts.fontSizeXs)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)
            .margin({ top: AppSpacing.spaceXs })
        }
      }
      .width(100)
      .height(100)
      .backgroundColor(AppColors.primaryLight)
      .borderRadius(AppBorderRadius.radiusFull)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.isEditing) {
          promptAction.showToast({
            message: '头像修改功能开发中',
            duration: 2000
          })
        }
      })
      
      // 昵称和邮箱
      Column() {
        if (this.isEditing) {
          TextInput({ placeholder: '请输入昵称' })
            .width('100%')
            .height(44)
            .borderRadius(AppBorderRadius.radiusBase)
            .backgroundColor(AppColors.bgColor)
            .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
            .textAlign(TextAlign.Center)
            .fontSize(AppFonts.fontSizeLg)
            .fontColor(AppColors.titleColor)
            .fontWeight(AppFonts.fontWeightMedium)
            .onChange((value: string) => {
              this.editNickname = value.trim()
            })
        } else {
          Text(this.userInfo?.nickname || '未设置昵称')
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .margin({ top: AppSpacing.spaceLg })
        }
        
        if (this.isEditing) {
          TextInput({ placeholder: '请输入邮箱' })
            .width('100%')
            .height(44)
            .borderRadius(AppBorderRadius.radiusBase)
            .backgroundColor(AppColors.bgColor)
            .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
            .textAlign(TextAlign.Center)
            .margin({ top: AppSpacing.spaceSm })
            .type(InputType.Email)
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .onChange((value: string) => {
              this.editEmail = value.trim()
            })
        } else {
          Text(this.userInfo?.email ? this.userInfo.email : '未设置邮箱')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        
        // 性别选择（编辑模式）
        if (this.isEditing) {
          Row() {
            Text('性别')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
            
            Blank()
            
            Row() {
              Text('男')
                .fontSize(AppFonts.fontSizeSm)
                .fontColor(this.editSex === 1 ? Color.White : AppColors.textColor)
                .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
                .backgroundColor(this.editSex === 1 ? AppColors.primaryColor : AppColors.bgColor)
                .borderRadius(AppBorderRadius.radiusFull)
                .onClick(() => {
                  this.editSex = 1
                })
              
              Text('女')
                .fontSize(AppFonts.fontSizeSm)
                .fontColor(this.editSex === 2 ? Color.White : AppColors.textColor)
                .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
                .backgroundColor(this.editSex === 2 ? AppColors.warningColor : AppColors.bgColor)
                .borderRadius(AppBorderRadius.radiusFull)
                .margin({ left: AppSpacing.spaceSm })
                .onClick(() => {
                  this.editSex = 2
                })
              
              Text('保密')
                .fontSize(AppFonts.fontSizeSm)
                .fontColor(this.editSex === 0 ? Color.White : AppColors.textColor)
                .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
                .backgroundColor(this.editSex === 0 ? AppColors.textSecondary : AppColors.bgColor)
                .borderRadius(AppBorderRadius.radiusFull)
                .margin({ left: AppSpacing.spaceSm })
                .onClick(() => {
                  this.editSex = 0
                })
            }
          }
          .width('100%')
          .margin({ top: AppSpacing.spaceLg })
        } else {
          Text(this.userInfo?.sex === 1 ? '男' : this.userInfo?.sex === 2 ? '女' : '未设置性别')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ top: AppSpacing.spaceLg })
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建统计数据
  @Builder buildStatistics() {
    Row() {
      Column() {
        Text(this.userInfo?.totalSteps.toLocaleString() || '0')
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.primaryColor)
        
        Text('总步数')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      
      Divider()
        .vertical(true)
        .height(40)
      
      Column() {
        Text(this.userInfo?.totalPoints.toLocaleString() || '0')
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.warningColor)
        
        Text('总积分')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      
      Divider()
        .vertical(true)
        .height(40)
      
      Column() {
        Text(this.userInfo?.remainingSteps.toLocaleString() || '0')
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.successColor)
        
        Text('剩余步数')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建功能菜单
  @Builder buildFunctionMenu() {
    Column() {
      // 账户安全
      Text('账户安全')
        .fontSize(AppFonts.fontSizeSm)
        .fontColor(AppColors.textSecondary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg })
      
      this.buildMenuItem(AppIcons.security, '修改密码', () => {
        this.showPasswordDialog = true
      })
      
      this.buildMenuItem(AppIcons.notification, '账号绑定', () => {
        promptAction.showToast({
          message: '账号绑定功能开发中',
          duration: 2000
        })
      })
      
      // 通用设置
      Text('通用设置')
        .fontSize(AppFonts.fontSizeSm)
        .fontColor(AppColors.textSecondary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg, top: AppSpacing.space2Xl })
      
      this.buildMenuItem(AppIcons.settings, '步数设置', () => {
        promptAction.showToast({
          message: '步数设置功能开发中',
          duration: 2000
        })
      })
      
      this.buildMenuItem(AppIcons.clock, '消息通知', () => {
        promptAction.showToast({
          message: '消息通知功能开发中',
          duration: 2000
        })
      })
      
      // 关于
      Text('关于')
        .fontSize(AppFonts.fontSizeSm)
        .fontColor(AppColors.textSecondary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg, top: AppSpacing.space2Xl })
      
      this.buildMenuItem(AppIcons.info, '关于我们', () => {
        promptAction.showToast({
          message: '版本：v1.0.0\n运动让生活更美好',
          duration: 3000
        })
      })
      
      this.buildMenuItem(AppIcons.document, '用户协议', () => {
        promptAction.showToast({
          message: '用户协议内容开发中',
          duration: 2000
        })
      })
      
      this.buildMenuItem(AppIcons.privacy, '隐私政策', () => {
        promptAction.showToast({
          message: '隐私政策内容开发中',
          duration: 2000
        })
      })
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建菜单项
  @Builder buildMenuItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(AppFonts.fontSize2Xl)
        .margin({ right: AppSpacing.spaceLg })
      
      Text(title)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .layoutWeight(1)
      
      Text('›')
        .fontSize(AppFonts.fontSizeLg)
        .fontColor(AppColors.borderColor)
    }
    .width('100%')
    .padding({ top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .onClick(onClick)
  }

  // 构建退出登录按钮
  @Builder buildLogoutButton() {
    Column() {
      Button('退出登录')
        .width('100%')
        .height(52)
        .fontSize(AppFonts.fontSizeLg)
        .fontWeight(AppFonts.fontWeightMedium)
        .backgroundColor(AppColors.errorColor)
        .fontColor(Color.White)
        .borderRadius(AppBorderRadius.radius2Xl)
        .onClick(() => {
          this.handleLogout()
        })
    }
    .width('100%')
    .padding({ bottom: AppSpacing.space3Xl, top: AppSpacing.spaceLg })
  }

  // 构建密码修改对话框
  @Builder buildPasswordDialog() {
    // 遮罩层
    Column() {
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000040')
    .onClick(() => {
      this.showPasswordDialog = false
      this.oldPassword = ''
      this.newPassword = ''
      this.confirmPassword = ''
    })
    
    // 对话框内容
    Column() {
      // 标题栏
      Row() {
        Text('修改密码')
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .layoutWeight(1)
        
        Text('✕')
          .fontSize(AppFonts.fontSize2Xl)
          .fontColor(AppColors.textSecondary)
          .onClick(() => {
            this.showPasswordDialog = false
            this.oldPassword = ''
            this.newPassword = ''
            this.confirmPassword = ''
          })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })
      
      // 旧密码
      Column() {
        Text('旧密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: AppSpacing.spaceSm })
        
        TextInput({ placeholder: '请输入旧密码' })
          .width('100%')
          .height(44)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .type(InputType.Password)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .onChange((value: string) => {
            this.oldPassword = value
          })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })
      
      // 新密码
      Column() {
        Text('新密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: AppSpacing.spaceSm })
        
        TextInput({ placeholder: '请输入新密码（至少6位）' })
          .width('100%')
          .height(44)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .type(InputType.Password)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .onChange((value: string) => {
            this.newPassword = value
          })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })
      
      // 确认密码
      Column() {
        Text('确认密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: AppSpacing.spaceSm })
        
        TextInput({ placeholder: '请再次输入新密码' })
          .width('100%')
          .height(44)
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
      
      // 操作按钮
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.bgColor)
          .fontColor(AppColors.textColor)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            this.showPasswordDialog = false
            this.oldPassword = ''
            this.newPassword = ''
            this.confirmPassword = ''
          })
          .margin({ right: AppSpacing.spaceLg })
        
        Button('确认修改')
          .layoutWeight(1)
          .height(44)
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            this.changePassword()
          })
      }
      .width('100%')
    }
    .width('80%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(Color.White)
    .borderRadius(AppBorderRadius.radius2Xl)
    .shadow(AppShadows.shadowLg)
    .alignSelf(ItemAlign.Center)
    .margin({ left: '10%', right: '10%' })
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<boolean> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('Token已同步到ApiClient，长度:', token.length)
      return true
    } else {
      console.warn('StateStore中没有找到Token')
      promptAction.showToast({
        message: '登录已过期，请重新登录',
        duration: 2000
      })
      // 跳转到登录页面
      setTimeout(() => {
        router.replaceUrl({
          url: 'pages/LoginPage'
        })
      }, 2000)
      return false
    }
  }

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    this.isLoading = true
    
    try {
      // 确保ApiClient有正确的Token
      await this.syncTokenToApiClient()
      
      console.log('=== 开始获取用户信息 ===')
      // 先从API获取最新用户信息
      const apiResponse = await this.apiClient.getUserInfo()
      console.log('API响应:', JSON.stringify(apiResponse))
      
      if (apiResponse.code === 1 && apiResponse.data) {
        console.log('✅ 从API获取用户信息成功')
        console.log('用户ID:', apiResponse.data.id)
        console.log('用户名:', apiResponse.data.username)
        console.log('昵称:', apiResponse.data.nickname)
        
        // 更新本地存储
        await this.stateStore.saveUserInfo(apiResponse.data)
        this.userInfo = apiResponse.data
        this.editNickname = apiResponse.data.nickname || ''
        this.editEmail = apiResponse.data.email || ''
        this.editSex = apiResponse.data.sex || 0
      } else {
        console.warn('⚠️ API返回失败, code:', apiResponse.code, 'message:', apiResponse.message)
        // API失败时从本地存储加载
        const userInfo = await this.stateStore.getUserInfo()
        if (userInfo) {
          console.log('✅ 从本地存储加载用户信息')
          this.userInfo = userInfo
          this.editNickname = userInfo.nickname || ''
          this.editEmail = userInfo.email || ''
          this.editSex = userInfo.sex || 0
        } else {
          console.error('❌ 本地也没有用户信息')
        }
      }
    } catch (error) {
      console.error('❌ Failed to load user info from API:', error)
      console.error('错误详情:', JSON.stringify(error))
      // 出错时从本地存储加载
      try {
        const userInfo = await this.stateStore.getUserInfo()
        if (userInfo) {
          console.log('✅ 从本地存储加载用户信息(API失败)')
          this.userInfo = userInfo
          this.editNickname = userInfo.nickname || ''
          this.editEmail = userInfo.email || ''
          this.editSex = userInfo.sex || 0
        } else {
          console.error('❌ 本地也没有用户信息，需要重新登录')
          // 如果本地也没有用户信息，可能是token过期，需要重新登录
          promptAction.showToast({
            message: '用户信息获取失败，请重新登录',
            duration: 2000
          })
          setTimeout(() => {
            router.replaceUrl({
              url: 'pages/LoginPage'
            })
          }, 2000)
        }
      } catch (localError) {
        console.error('❌ Failed to load local user info:', localError)
        promptAction.showToast({
          message: '加载用户信息失败',
          duration: 2000
        })
      }
    } finally {
      this.isLoading = false
      console.log('=== 用户信息加载完成 ===')
    }
  }

  // 开始编辑
  private startEditing(): void {
    this.isEditing = true
    this.loadUserInfo()
  }

  // 保存用户信息
  private async saveUserInfo(): Promise<void> {
    if (!this.editNickname.trim()) {
      promptAction.showToast({
        message: '请输入昵称',
        duration: 2000
      });
      return;
    }

    if (this.editEmail && !this.editEmail.includes('@')) {
      promptAction.showToast({
        message: '请输入有效的邮箱地址',
        duration: 2000
      });
      return;
    }

    try {
      // 确保ApiClient有正确的Token
      await this.syncTokenToApiClient()
      
      const response = await this.apiClient.updateUserInfo({
        nickname: this.editNickname,
        sex: this.editSex
      });
      
      if (response.code === 1) {
        // 更新本地用户信息
        const newUserInfo: UserInfo = {
          id: this.userInfo!.id,
          username: this.userInfo!.username,
          email: this.editEmail,
          nickname: this.editNickname,
          sex: this.editSex,
          totalSteps: this.userInfo!.totalSteps,
          totalPoints: this.userInfo!.totalPoints,
          remainingSteps: this.userInfo!.remainingSteps
        }
        
        await this.stateStore.saveUserInfo(newUserInfo)
        this.userInfo = newUserInfo
        this.isEditing = false
        
        promptAction.showToast({
          message: '用户信息更新成功',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: response.message || '更新失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to update user info:', error)
      promptAction.showToast({
        message: '更新失败，请检查网络',
        duration: 2000
      });
    }
  }

  // 修改密码
  private async changePassword(): Promise<void> {
    if (!this.oldPassword.trim()) {
      promptAction.showToast({
        message: '请输入旧密码',
        duration: 2000
      });
      return;
    }

    if (!this.newPassword.trim()) {
      promptAction.showToast({
        message: '请输入新密码',
        duration: 2000
      });
      return;
    }

    if (this.newPassword.length < 6) {
      promptAction.showToast({
        message: '新密码至少6位',
        duration: 2000
      });
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({
        message: '两次输入的密码不一致',
        duration: 2000
      });
      return;
    }

    try {
      // 确保ApiClient有正确的Token
      await this.syncTokenToApiClient()
      
      const response = await this.apiClient.updatePassword(
        this.oldPassword,
        this.newPassword
      );
      
      if (response.code === 1) {
        promptAction.showToast({
          message: '密码修改成功',
          duration: 2000
        });
        
        this.showPasswordDialog = false
        this.oldPassword = ''
        this.newPassword = ''
        this.confirmPassword = ''
      } else {
        promptAction.showToast({
          message: response.message || '密码修改失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to change password:', error)
      promptAction.showToast({
        message: '密码修改失败，请检查网络',
        duration: 2000
      });
    }
  }

  // 处理退出登录
  private async handleLogout(): Promise<void> {
    try {
      await this.stateStore.logout()
      this.apiClient.clearToken()
      
      promptAction.showToast({
        message: '已退出登录',
        duration: 2000
      });
      
      // 跳转到登录页面
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    } catch (error) {
      console.error('Failed to logout:', error)
      promptAction.showToast({
        message: '退出登录失败',
        duration: 2000
      });
    }
  }
}
