import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import StateStore from '../services/StateStore'
import ApiClient from '../services/ApiClient'
import { UserInfo } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppShadows
} from '../config/DesignSystem'

@Entry
@Component
export struct ProfilePage {
  @State userInfo: UserInfo | null = null
  @State todaySteps: number = 0
  @State totalPoints: number = 0
  
  // 编辑个人信息相关状态
  @State showEditDialog: boolean = false
  @State editNickname: string = ''
  @State editEmail: string = ''
  @State editSex: number = 0
  
  // 修改密码相关状态
  @State showPasswordDialog: boolean = false
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''

  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    this.loadUserData()
  }

  // 页面显示时重新加载数据，但保留本地最新的步数
  onPageShow() {
    console.log('ProfilePage: 页面显示，刷新用户数据')
    // 直接调用loadUserData，它内部已经处理了保留本地步数的逻辑
    this.loadUserData()
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 个人信息卡片
          this.buildProfileCard()

          // 功能列表
          this.buildFunctionList()
        }
        .width('100%')
        .padding(AppSpacing.spaceLg)
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      
      // 编辑个人信息对话框
      if (this.showEditDialog) {
        this.buildEditProfileDialog()
      }
      
      // 修改密码对话框
      if (this.showPasswordDialog) {
        this.buildPasswordDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  @Builder buildProfileCard() {
    Column() {
      // 头像和基本信息
      Row() {
        Column() {
          Text(AppIcons.profile)
            .fontSize(48)
        }
        .width(80)
        .height(80)
        .backgroundColor(AppColors.primaryLight)
        .borderRadius(AppBorderRadius.radiusFull)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: AppSpacing.spaceLg })

        Column() {
          Text(this.userInfo?.nickname || '用户')
            .fontSize(AppFonts.fontSizeXl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .alignSelf(ItemAlign.Start)

          Text(`ID: ${this.userInfo?.id || '未知'}`)
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .alignSelf(ItemAlign.Start)
            .margin({ top: AppSpacing.spaceXs })
            
          if (this.userInfo?.email) {
            Text(this.userInfo.email)
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textSecondary)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
          
          if (this.userInfo?.sex !== undefined && this.userInfo?.sex !== null) {
            Text(`性别: ${this.userInfo.sex === 1 ? '男' : this.userInfo.sex === 0 ? '女' : '未设置'}`)
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textSecondary)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 数据统计
      Row() {
        Column() {
          Text(this.todaySteps.toLocaleString())
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.primaryColor)

          Text('今日步数')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)

        Column() {
          Text(this.totalPoints.toLocaleString())
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.warningColor)

          Text('总积分')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)

        Column() {
          Text((this.userInfo?.totalSteps || 0).toLocaleString())
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.successColor)

          Text('总步数')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildFunctionList() {
    Column() {
      // 个人信息管理功能
      this.buildFunctionItem('👤', '修改个人信息', () => {
        this.editProfile()
      })
      
      this.buildFunctionItem('🔐', '修改密码', () => {
        this.changePassword()
      })
      
      Divider()
        .strokeWidth(1)
        .color(AppColors.dividerColor)
        .margin({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })

      // 设置相关功能
      this.buildFunctionItem('⚙️', '应用设置', () => {
        console.log('打开应用设置')
      })
      
      this.buildFunctionItem('🔔', '消息通知', () => {
        console.log('打开消息通知设置')
      })
      
      this.buildFunctionItem('🔒', '隐私设置', () => {
        console.log('打开隐私设置')
      })
      
      this.buildFunctionItem('ℹ️', '关于我们', () => {
        console.log('打开关于页面')
      })
      
      this.buildFunctionItem('📄', '用户协议', () => {
        console.log('打开用户协议')
      })
      
      this.buildFunctionItem('🚪', '退出登录', () => {
        this.logout()
      })
    }
    .width('100%')
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
  }

  @Builder buildFunctionItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: AppSpacing.spaceLg })

      Text(title)
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .layoutWeight(1)

      Text('➡️')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textSecondary)
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor('#00000000')
    .onClick(onClick)
  }

  private async loadUserData(): Promise<void> {
    try {
      // 先从后端获取最新的用户信息
      console.log('ProfilePage: 开始从后端加载用户数据')
      const userInfoResponse = await this.apiClient.getUserInfo()
      
      if (userInfoResponse.code === 1 && userInfoResponse.data) {
        // 重要：先保存当前本地最新的今日步数（可能包含未上传的模拟步数）
        const localTodaySteps = this.stateStore.todaySteps
        console.log('ProfilePage: 本地最新步数:', localTodaySteps)
        
        // 更新本地存储的用户信息（但不包括今日步数）
        await this.stateStore.saveUserInfo(userInfoResponse.data)
        
        this.userInfo = userInfoResponse.data
        
        // 重要：始终使用本地最新的今日步数，不从后端覆盖
        this.todaySteps = localTodaySteps
        
        this.totalPoints = userInfoResponse.data.totalPoints
        
        console.log('ProfilePage: 从后端加载用户数据成功')
        console.log('用户ID:', this.userInfo.id, '昵称:', this.userInfo.nickname)
        console.log('今日步数（本地）:', this.todaySteps, '总积分:', this.totalPoints)
      } else {
        console.warn('ProfilePage: 后端请求失败，使用本地数据')
        
        // 检查是否是认证失败
        if (userInfoResponse.code === 401 || userInfoResponse.message?.includes('Authentication')) {
          promptAction.showToast({
            message: '登录已过期，请重新登录',
            duration: 2000
          })
          setTimeout(async () => {
            await this.stateStore.clearAllData()
            router.replaceUrl({
              url: 'pages/LoginPage'
            })
          }, 2000)
          return
        }
        
        // 降级方案：从本地存储加载
        const userInfo = await this.stateStore.getUserInfo()
        this.userInfo = userInfo
        this.todaySteps = this.stateStore.todaySteps
        this.totalPoints = userInfo.totalPoints
        
        // 如果本地也没有用户信息，才跳转登录
        if (!userInfo || userInfo.id === 0) {
          console.warn('ProfilePage: 本地也无用户信息，跳转到登录页')
          promptAction.showToast({
            message: '请先登录',
            duration: 2000
          })
          setTimeout(() => {
            router.replaceUrl({
              url: 'pages/LoginPage'
            })
          }, 2000)
        }
      }
    } catch (error) {
      console.error('Failed to load user data:', error)
      
      // 检查是否是认证错误
      const errorMessage = error instanceof Error ? error.message : String(error)
      if (errorMessage.includes('401') || errorMessage.includes('Authentication')) {
        promptAction.showToast({
          message: '登录已过期，请重新登录',
          duration: 2000
        })
        setTimeout(async () => {
          await this.stateStore.clearAllData()
          router.replaceUrl({
            url: 'pages/LoginPage'
          })
        }, 2000)
        return
      }
      
      // 降级方案：从本地存储加载
      try {
        const userInfo = await this.stateStore.getUserInfo()
        this.userInfo = userInfo
        this.todaySteps = this.stateStore.todaySteps
        this.totalPoints = userInfo.totalPoints
      } catch (localError) {
        console.error('Failed to load local user data:', localError)
      }
    }
  }

  private async editProfile(): Promise<void> {
    try {
      if (!this.userInfo) {
        promptAction.showToast({
          message: '请先登录',
          duration: 2000
        })
        return
      }

      // 初始化编辑表单
      this.editNickname = this.userInfo.nickname || ''
      this.editSex = this.userInfo.sex || 0
      this.showEditDialog = true
    } catch (error) {
      console.error('Failed to open edit profile dialog:', error)
      promptAction.showToast({
        message: '打开编辑对话框失败',
        duration: 2000
      })
    }
  }

  private async changePassword(): Promise<void> {
    try {
      // 初始化密码表单
      this.oldPassword = ''
      this.newPassword = ''
      this.confirmPassword = ''
      this.showPasswordDialog = true
    } catch (error) {
      console.error('Failed to open password dialog:', error)
      promptAction.showToast({
        message: '打开修改密码对话框失败',
        duration: 2000
      })
    }
  }

  private async updateUserProfile(nickname: string, sex: number): Promise<void> {
    try {
      const response = await this.apiClient.updateUserInfo({
        nickname: nickname,
        sex: sex
      })

      if (response.code === 1) {
        // 更新本地存储
        if (this.userInfo) {
          const updatedUserInfo: UserInfo = {
            id: this.userInfo.id,
            username: this.userInfo.username,
            email: this.userInfo.email,
            nickname: nickname,
            sex: sex,
            avatar: this.userInfo.avatar,
            totalSteps: this.userInfo.totalSteps,
            totalPoints: this.userInfo.totalPoints,
            remainingSteps: this.userInfo.remainingSteps
          }
          await this.stateStore.saveUserInfo(updatedUserInfo)
          this.userInfo = updatedUserInfo
        }

        promptAction.showToast({
          message: '个人信息修改成功',
          duration: 2000
        })
      } else {
        promptAction.showToast({
          message: response.message || '修改失败',
          duration: 2000
        })
      }
    } catch (error) {
      console.error('Failed to update user profile:', error)
      promptAction.showToast({
        message: '修改个人信息失败',
        duration: 2000
      })
    }
  }

  private async updatePassword(oldPassword: string, newPassword: string): Promise<void> {
    try {
      const response = await this.apiClient.updatePassword(oldPassword, newPassword)

      if (response.code === 1) {
        promptAction.showToast({
          message: '密码修改成功',
          duration: 2000
        })
      } else {
        promptAction.showToast({
          message: response.message || '修改失败',
          duration: 3000
        })
      }
    } catch (error) {
      console.error('Failed to update password:', error)
      let errorMessage = '网络请求失败'
      if (error instanceof Error) {
        errorMessage = error.message
      } else {
        errorMessage = String(error)
      }
      promptAction.showToast({
        message: `修改密码失败: ${errorMessage}`,
        duration: 3000
      })
    }
  }

  private async logout(): Promise<void> {
    try {
      // 清除本地存储
      await this.stateStore.clearAllData()
      
      // 跳转到登录页
      router.clear()
      router.pushUrl({
        url: 'pages/LoginPage'
      })
    } catch (error) {
      console.error('Failed to logout:', error)
    }
  }
  
  // 确认更新个人信息
  private async confirmUpdateProfile(): Promise<void> {
    if (!this.editNickname || this.editNickname.trim() === '') {
      promptAction.showToast({
        message: '昵称不能为空',
        duration: 2000
      })
      return
    }
    
    try {
      const response = await this.apiClient.updateUserInfo({
        nickname: this.editNickname,
        sex: this.editSex
      })

      if (response.code === 1) {
        // 更新本地存储
        if (this.userInfo) {
          const updatedUserInfo: UserInfo = {
            id: this.userInfo.id,
            username: this.userInfo.username,
            email: this.userInfo.email,
            nickname: this.editNickname,
            sex: this.editSex,
            avatar: this.userInfo.avatar,
            totalSteps: this.userInfo.totalSteps,
            totalPoints: this.userInfo.totalPoints,
            remainingSteps: this.userInfo.remainingSteps
          }
          await this.stateStore.saveUserInfo(updatedUserInfo)
          this.userInfo = updatedUserInfo
        }

        this.showEditDialog = false
        
        promptAction.showToast({
          message: '个人信息修改成功',
          duration: 2000
        })
      } else {
        promptAction.showToast({
          message: response.message || '修改失败',
          duration: 2000
        })
      }
    } catch (error) {
      console.error('Failed to update user profile:', error)
      promptAction.showToast({
        message: '修改个人信息失败',
        duration: 2000
      })
    }
  }
  
  // 确认修改密码
  private async confirmPasswordChange(): Promise<void> {
    if (!this.oldPassword || !this.newPassword || !this.confirmPassword) {
      promptAction.showToast({
        message: '请填写所有字段',
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
    
    if (this.newPassword.length < 6) {
      promptAction.showToast({
        message: '密码长度至少6位',
        duration: 2000
      })
      return
    }
    
    try {
      const response = await this.apiClient.updatePassword(this.oldPassword, this.newPassword)

      if (response.code === 1) {
        this.showPasswordDialog = false
        this.oldPassword = ''
        this.newPassword = ''
        this.confirmPassword = ''
        
        promptAction.showToast({
          message: '密码修改成功，请重新登录',
          duration: 2000
        })
        
        // 密码修改成功后，清除本地数据并跳转到登录页
        setTimeout(async () => {
          await this.stateStore.clearAllData()
          router.clear()
          router.pushUrl({
            url: 'pages/LoginPage'
          })
        }, 2000)
      } else {
        promptAction.showToast({
          message: response.message || '修改失败',
          duration: 3000
        })
      }
    } catch (error) {
      console.error('Failed to update password:', error)
      let errorMessage = '网络请求失败'
      if (error instanceof Error) {
        errorMessage = error.message
      } else {
        errorMessage = String(error)
      }
      promptAction.showToast({
        message: `修改密码失败: ${errorMessage}`,
        duration: 3000
      })
    }
  }
  
  // 构建编辑个人信息对话框
  @Builder buildEditProfileDialog() {
    Stack() {
      // 遮罩层
      Column() {
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000040')
      .onClick(() => {
        this.showEditDialog = false
      })

      // 对话框内容
      Column() {
        Text('修改个人信息')
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceLg })

        // 昵称输入
        Text('昵称')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入昵称', text: this.editNickname })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({ width: 1, color: AppColors.borderColor })
          .onChange((value: string) => { this.editNickname = value })
          .margin({ bottom: AppSpacing.spaceLg })

        // 性别选择
        Text('性别')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row() {
          Button('女')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(this.editSex === 0 ? AppColors.primaryColor : AppColors.bgColor)
            .fontColor(this.editSex === 0 ? Color.White : AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .border({ width: 1, color: AppColors.borderColor })
            .margin({ right: AppSpacing.spaceLg })
            .onClick(() => { this.editSex = 0 })

          Button('男')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(this.editSex === 1 ? AppColors.primaryColor : AppColors.bgColor)
            .fontColor(this.editSex === 1 ? Color.White : AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .border({ width: 1, color: AppColors.borderColor })
            .onClick(() => { this.editSex = 1 })
        }
        .width('100%')
        .margin({ bottom: AppSpacing.space3Xl })

        // 操作按钮
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.bgColor)
            .fontColor(AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .border({ width: 1, color: AppColors.borderColor })
            .onClick(() => { this.showEditDialog = false })
            .margin({ right: AppSpacing.spaceLg })

          Button('保存')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radiusBase)
            .onClick(() => { this.confirmUpdateProfile() })
        }
        .width('100%')
      }
      .width('85%')
      .padding(AppSpacing.space3Xl)
      .backgroundColor(Color.White)
      .borderRadius(AppBorderRadius.radius2Xl)
      .shadow(AppShadows.shadowLg)
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
  
  // 构建修改密码对话框
  @Builder buildPasswordDialog() {
    Stack() {
      // 遮罩层
      Column() {
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000040')
      .onClick(() => {
        this.showPasswordDialog = false
      })

      // 对话框内容
      Column() {
        Text('修改密码')
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceLg })

        // 旧密码
        Text('当前密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入当前密码', text: this.oldPassword })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({ width: 1, color: AppColors.borderColor })
          .type(InputType.Password)
          .onChange((value: string) => { this.oldPassword = value })
          .margin({ bottom: AppSpacing.spaceLg })

        // 新密码
        Text('新密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入新密码（至少6位）', text: this.newPassword })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({ width: 1, color: AppColors.borderColor })
          .type(InputType.Password)
          .onChange((value: string) => { this.newPassword = value })
          .margin({ bottom: AppSpacing.spaceLg })

        // 确认密码
        Text('确认新密码')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请再次输入新密码', text: this.confirmPassword })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({ width: 1, color: AppColors.borderColor })
          .type(InputType.Password)
          .onChange((value: string) => { this.confirmPassword = value })
          .margin({ bottom: AppSpacing.space3Xl })

        // 操作按钮
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.bgColor)
            .fontColor(AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .border({ width: 1, color: AppColors.borderColor })
            .onClick(() => { this.showPasswordDialog = false })
            .margin({ right: AppSpacing.spaceLg })

          Button('确认修改')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radiusBase)
            .onClick(() => { this.confirmPasswordChange() })
        }
        .width('100%')
      }
      .width('85%')
      .padding(AppSpacing.space3Xl)
      .backgroundColor(Color.White)
      .borderRadius(AppBorderRadius.radius2Xl)
      .shadow(AppShadows.shadowLg)
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}