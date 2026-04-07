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
  
  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    this.loadUserInfo()
  }

  build() {
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
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
          Text(this.userInfo?.email || '')
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
          Text(this.userInfo?.sex === 1 ? '男' : this.userInfo?.sex === 2 ? '女' : '')
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

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      const userInfo = await this.stateStore.getUserInfo()
      this.userInfo = userInfo
      this.editNickname = userInfo.nickname
      this.editEmail = userInfo.email
      this.editSex = userInfo.sex || 0
    } catch (error) {
      console.error('Failed to load user info:', error)
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
      const response = await this.apiClient.updateUserInfo({
        email: this.editEmail,
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
        };
        await this.stateStore.saveUserInfo(newUserInfo);
        this.userInfo = newUserInfo;
        this.isEditing = false;
        
        promptAction.showToast({
          message: '✅ 保存成功',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: response.message,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to save user info:', error);
      promptAction.showToast({
        message: '❌ 保存失败，请重试',
        duration: 2000
      });
    }
  }

  // 修改密码
  private async changePassword(): Promise<void> {
    if (!this.oldPassword || !this.newPassword || !this.confirmPassword) {
      promptAction.showToast({
        message: '请填写完整信息',
        duration: 2000
      })
      return
    }

    if (this.newPassword.length < 6) {
      promptAction.showToast({
        message: '密码长度不能少于 6 位',
        duration: 2000
      })
      return
    }

    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({
        message: '两次输入的密码不一致',
        duration: 2000
      })
      return
    }

    try {
      const response = await this.apiClient.updatePassword(this.oldPassword, this.newPassword)
      
      if (response.code === 1) {
        promptAction.showToast({
          message: '✅ 密码修改成功',
          duration: 2000
        })
        
        this.showPasswordDialog = false
        this.oldPassword = ''
        this.newPassword = ''
        this.confirmPassword = ''
      } else {
        promptAction.showToast({
          message: response.message,
          duration: 2000
        })
      }
    } catch (error) {
      console.error('Failed to change password:', error)
      promptAction.showToast({
        message: '❌ 修改失败，请重试',
        duration: 2000
      })
    }
  }

  // 处理退出登录
  private async handleLogout(): Promise<void> {
    try {
      await this.stateStore.logout()
      
      promptAction.showToast({
        message: '👋 已退出登录',
        duration: 2000
      })
      
      router.clear()
      router.pushUrl({
        url: 'pages/LoginPage'
      })
    } catch (error) {
      console.error('Failed to logout:', error)
      promptAction.showToast({
        message: '❌ 退出失败，请重试',
        duration: 2000
      })
    }
  }
}