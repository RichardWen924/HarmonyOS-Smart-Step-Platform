import router from '@ohos.router'
import StateStore from '../services/StateStore'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppAnimations
} from '../config/DesignSystem'

@Entry
@Component
struct Index {
  private stateStore = StateStore
  @State isLoading: boolean = true
  @State scaleValue: number = 0.8
  @State opacityValue: number = 0

  aboutToAppear() {
    // 启动动画
    this.startAnimation()
    // 检查登录状态并跳转
    this.checkLoginStatus()
  }

  build() {
    Column() {
      // 背景装饰
      this.buildBackground()
      
      // 主要内容
      Column() {
        // Logo 动画
        Text(AppIcons.steps)
          .fontSize(96)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.primaryColor)
          .margin({ bottom: AppSpacing.spaceLg })
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .opacity(this.opacityValue)
        
        // 应用名称
        Text('运动健康')
          .fontSize(AppFonts.fontSize4Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceSm })
          .opacity(this.opacityValue)
        
        // Slogan
        Text('每一步都算数')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.textSecondary)
          .margin({ bottom: AppSpacing.space4Xl })
          .opacity(this.opacityValue)
        
        // 加载指示器
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(60)
              .height(60)
              .color(AppColors.primaryColor)
            
            Text('加载中...')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.textSecondary)
              .margin({ top: AppSpacing.spaceLg })
          }
          .opacity(this.opacityValue)
        }
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppColors.bgCard)
  }

  // 构建背景装饰
  @Builder buildBackground() {
    Column() {
      // 渐变背景装饰
      Row() {
        Column()
          .width(120)
          .height(120)
          .backgroundColor(AppColors.gradientStart)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.6)
          .margin({ right: AppSpacing.space4Xl })
        
        Column()
          .width(80)
          .height(80)
          .backgroundColor(AppColors.sportOrange)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.5)
          .margin({ top: AppSpacing.space4Xl })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: AppSpacing.space4Xl, right: AppSpacing.space4Xl })
      
      // 底部装饰
      Row() {
        Column()
          .width(60)
          .height(60)
          .backgroundColor(AppColors.sportGreen)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.4)
          .margin({ left: AppSpacing.space4Xl })
        
        Column()
          .width(100)
          .height(100)
          .backgroundColor(AppColors.gradientEnd)
          .borderRadius(AppBorderRadius.radiusFull)
          .opacity(0.5)
          .margin({ top: AppSpacing.space4Xl, right: AppSpacing.space4Xl })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: AppSpacing.space6Xl })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 启动动画
  private startAnimation(): void {
    // 缩放动画
    const scaleAnimation = setInterval(() => {
      if (this.scaleValue < 1) {
        this.scaleValue += 0.05
      } else {
        clearInterval(scaleAnimation)
      }
    }, 30)

    // 淡入动画
    const opacityAnimation = setInterval(() => {
      if (this.opacityValue < 1) {
        this.opacityValue += 0.1
      } else {
        clearInterval(opacityAnimation)
      }
    }, 50)
  }

  private async checkLoginStatus(): Promise<void> {
    try {
      // 等待 preferences 初始化完成
      await new Promise<void>((resolve) => setTimeout(() => resolve(), 1500));
      
      // 获取用户信息
      const userInfo = await this.stateStore.getUserInfo();
      
      console.log('Index page - User info loaded:', userInfo);
      console.log('Index page - isLoggedIn:', this.stateStore.isLoggedIn);
      
      // 延迟一小段时间，让用户看到启动页动画
      await new Promise<void>((resolve) => setTimeout(() => resolve(), 1000));
      
      this.isLoading = false
      
      // 根据登录状态跳转
      if (this.stateStore.isLoggedIn && userInfo.id > 0) {
        console.log('Index page - Navigating to MainPage (logged in)');
        router.replaceUrl({
          url: 'pages/MainPage'
        });
      } else {
        console.log('Index page - Navigating to LoginPage (not logged in)');
        router.replaceUrl({
          url: 'pages/LoginPage'
        });
      }
    } catch (error) {
      console.error('Index page - Error checking login status:', error);
      this.isLoading = false
      // 出错时跳转到登录页
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    }
  }
}