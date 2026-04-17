import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import StateStore from '../services/StateStore'
import ApiClient from '../services/ApiClient'
import { StepRecord, UserInfo, Product, ExchangeRecord, PageData } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppShadows
} from '../config/DesignSystem'
import { RankingPage } from './RankingPage'
import { MallPage } from './MallPage'
import { RecordPage } from './RecordPage'
import { ProfilePage } from './ProfilePage'

enum TabIndex {
  HOME = 0,
  RANKING = 1,
  MALL = 2,
  RECORD = 3,
  PROFILE = 4
}

@Entry
@Component
struct MainPage {
  @State currentTabIndex: number = 0
  @State todaySteps: number = 0
  @State totalPoints: number = 0
  @State userInfo: UserInfo | null = null
  @State showStepInput: boolean = false
  @State manualStepInput: string = ''

  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    this.syncTokenToApiClient()
    this.loadUserData()
  }

  build() {
    Column() {
      // 顶部标题栏 - 简洁设计
      this.buildHeader()

      // 内容区域
      Stack() {
        // 首页
        if (this.currentTabIndex === TabIndex.HOME) {
          HomePage({
            showStepInput: this.showStepInput,
            manualStepInput: this.manualStepInput,
            onShowStepInput: (show: boolean) => {
              this.showStepInput = show
            },
            onManualStepInputChange: (value: string) => {
              this.manualStepInput = value
            },
            onConfirmManualStepInput: () => {
              this.confirmManualStepInput()
            }
          })
            .width('100%')
            .height('100%')
        }

        // 排行榜页
        if (this.currentTabIndex === TabIndex.RANKING) {
          RankingPage()
            .width('100%')
            .height('100%')
        }

        // 商城页
        if (this.currentTabIndex === TabIndex.MALL) {
          MallPage()
            .width('100%')
            .height('100%')
        }

        // 记录页
        if (this.currentTabIndex === TabIndex.RECORD) {
          RecordPage()
            .width('100%')
            .height('100%')
        }

        // 个人中心页
        if (this.currentTabIndex === TabIndex.PROFILE) {
          ProfilePage()
            .width('100%')
            .height('100%')
        }

        // 手动输入步数对话框
        if (this.showStepInput) {
          this.buildStepInputDialog()
        }
      }
      .layoutWeight(1)

      // 底部 Tab 导航 - 优化设计
      this.buildTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  // 构建头部 - 简洁设计
  @Builder buildHeader() {
    Row() {
      Text(this.getTabTitle())
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)

      Blank()
      
      // 积分显示
      if (this.currentTabIndex === TabIndex.HOME) {
        Row() {
          Text(AppIcons.points)
            .fontSize(18)
            .margin({ right: AppSpacing.spaceXs })
            .fontColor(AppColors.warningColor)

          Text(this.totalPoints.toLocaleString())
            .fontSize(AppFonts.fontSizeBase)
            .fontWeight(AppFonts.fontWeightMedium)
            .fontColor(AppColors.warningColor)
        }
        .padding({ 
          left: AppSpacing.spaceLg, 
          right: AppSpacing.spaceLg, 
          top: AppSpacing.spaceSm, 
          bottom: AppSpacing.spaceSm 
        })
        .backgroundColor(AppColors.warningLight)
        .borderRadius(AppBorderRadius.radiusFull)
      }
    }
    .width('100%')
    .padding({ 
      left: AppSpacing.space3Xl, 
      right: AppSpacing.space3Xl, 
      top: AppSpacing.spaceXl, 
      bottom: AppSpacing.spaceXl 
    })
    .backgroundColor(AppColors.bgCard)
  }

  // 构建底部 Tab 栏 - 优化设计
  @Builder buildTabBar() {
    Row() {
      this.buildTabItem(AppIcons.home, '首页', TabIndex.HOME)
      this.buildTabItem(AppIcons.ranking, '排行榜', TabIndex.RANKING)
      this.buildTabItem(AppIcons.mall, '商城', TabIndex.MALL)
      this.buildTabItem(AppIcons.record, '记录', TabIndex.RECORD)
      this.buildTabItem(AppIcons.profile, '我的', TabIndex.PROFILE)
    }
    .width('100%')
    .height(72)
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
  }

  // 构建 Tab 项 - 优化交互效果
  @Builder buildTabItem(icon: string, label: string, index: TabIndex) {
    Column() {
      Text(icon)
        .fontSize(this.currentTabIndex === index ? 24 : 20)
        .margin({ bottom: AppSpacing.spaceXs })
        .fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary)

      Text(label)
        .fontSize(AppFonts.fontSizeXs)
        .fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary)
        .fontWeight(this.currentTabIndex === index ? AppFonts.fontWeightMedium : AppFonts.fontWeightRegular)
    }
    .width(64)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index
    })
  }

  // 构建手动输入步数对话框 - 优化视觉
  @Builder buildStepInputDialog() {
    Stack() {
      // 遮罩层
      Column() {
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000040')
      .onClick(() => {
        this.closeStepInputDialog()
      })

      // 对话框内容
      Column() {
        // 标题栏
        Row() {
          Text('手动输入步数')
            .fontSize(AppFonts.fontSizeXl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .layoutWeight(1)

          Text('✕')
            .fontSize(AppFonts.fontSize2Xl)
            .fontColor(AppColors.textSecondary)
            .onClick(() => {
              this.closeStepInputDialog()
            })
        }
        .width('100%')
        .margin({ bottom: AppSpacing.spaceLg })

        // 当前步数提示
        Text(`当前步数：${this.stateStore.todaySteps.toLocaleString()} 步`)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: AppSpacing.spaceLg })

        // 输入框
        TextInput({ placeholder: '请输入步数（必须大于当前步数）', text: this.manualStepInput })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .type(InputType.Number)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({
            width: 1,
            color: AppColors.borderColor
          })
          .onChange((value: string) => {
            this.manualStepInput = value
          })
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
            .border({
              width: 1,
              color: AppColors.borderColor
            })
            .onClick(() => {
              this.closeStepInputDialog()
            })
            .margin({ right: AppSpacing.spaceLg })

          Button('确认')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radiusBase)
            .onClick(() => {
              this.confirmManualStepInput()
            })
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

  private getTabTitle(): string {
    const titles = ['运动健康', '排行榜', '积分商城', '兑换记录', '个人中心']
    return titles[this.currentTabIndex]
  }

  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('MainPage: Token已同步到ApiClient')
    }
  }

  private async loadUserData(): Promise<void> {
    try {
      // 从本地存储加载数据
      const userInfo = await this.stateStore.getUserInfo()
      this.userInfo = userInfo
      this.todaySteps = this.stateStore.todaySteps
      this.totalPoints = userInfo.totalPoints

      console.log('MainPage: 加载本地用户数据完成')
      console.log('今日步数:', this.todaySteps)
      console.log('总积分:', this.totalPoints)
    } catch (error) {
      console.error('Failed to load user data:', error)
    }
  }

  private closeStepInputDialog(): void {
    this.showStepInput = false
    this.manualStepInput = ''
  }

  private async confirmManualStepInput(): Promise<void> {
    const inputSteps = parseInt(this.manualStepInput)
    if (isNaN(inputSteps) || inputSteps <= this.stateStore.todaySteps) {
      promptAction.showToast({
        message: '请输入有效的步数（必须大于当前步数）',
        duration: 2000
      })
      return
    }

    try {
      // 只更新本地状态，不上传到后端
      await this.stateStore.updateTodaySteps(inputSteps)

      // 同步更新 MainPage 的 todaySteps
      this.todaySteps = inputSteps

      console.log('MainPage: 手动输入步数成功，本地步数已更新为:', inputSteps)

      promptAction.showToast({
        message: '步数已更新！',
        duration: 2000
      })

      this.closeStepInputDialog()
    } catch (error) {
      console.error('Failed to update manual steps:', error)
      promptAction.showToast({
        message: '更新失败，请重试',
        duration: 2000
      })
    }
  }
}

// ==================== 首页组件 ====================
@Component
struct HomePage {
  @State todaySteps: number = 0
  @State isSimulating: boolean = false
  @State totalPoints: number = 0
  @State userInfo: UserInfo | null = null
  private simulationInterval: number | null = null
  private showStepInput: boolean = false
  private manualStepInput: string = ''
  private onShowStepInput?: (show: boolean) => void
  private onManualStepInputChange?: (value: string) => void
  private onConfirmManualStepInput?: () => void
  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    this.loadStepData()
    this.loadUserInfo()
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.simulationInterval) {
      clearInterval(this.simulationInterval)
      this.simulationInterval = null
    }
  }

  // 当组件显示时，重新加载数据（用于从其他页面返回或手动输入后刷新）
  onPageShow() {
    console.log('HomePage: 页面显示，重新加载步数数据')
    // 注意：不从后端重新加载，保留本地最新的步数（包括未上传的模拟步数）
    this.todaySteps = this.stateStore.todaySteps
    console.log('HomePage: 使用本地步数:', this.todaySteps)
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 今日步数卡片
          this.buildStepCard()

          // 快捷功能
          this.buildQuickActions()

          // 排行榜入口
          this.buildRankingEntry()
        }
        .width('100%')
        .padding(AppSpacing.spaceLg)
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder buildStepCard() {
    Column() {
      Row() {
        Text('今日步数')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)

        Blank()
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      Row() {
        Column() {
          Text(this.todaySteps.toLocaleString())
            .fontSize(AppFonts.fontSize5Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.primaryColor)

          Text('今日步数')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)

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
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 进度条和目标
      Column() {
        Row() {
          Text('目标：10,000 步')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)

          Blank()

          Text(`${Math.min(this.todaySteps, 10000).toLocaleString()}/10,000`)
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)
        }
        .width('100%')
        .margin({ bottom: AppSpacing.spaceSm })

        Progress({ value: Math.min(this.todaySteps, 10000), total: 10000 })
          .width('100%')
          .height(8)
          .color(AppColors.primaryColor)
          .backgroundColor(AppColors.borderColor)
          .borderRadius(AppBorderRadius.radiusFull)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.space2Xl })

      // 按钮组
      Row() {
        Button(this.isSimulating ? '停止模拟' : '开始运动')
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(this.isSimulating ? AppColors.warningColor : AppColors.successColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
          .onClick(() => {
            if (this.isSimulating) {
              this.stopSimulation()
            } else {
              this.simulateWalking()
            }
          })

        Blank()

        Button('上传数据')
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
          .onClick(() => {
            this.uploadSteps()
          })
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

  @Builder buildQuickActions() {
    Column() {
      Text('快捷功能')
        .fontSize(AppFonts.fontSizeLg)
        .fontColor(AppColors.titleColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .margin({ bottom: AppSpacing.spaceLg })
        .alignSelf(ItemAlign.Start)

      Grid() {
        // 功能1: 兑换积分
        GridItem() {
          Column() {
            Text('🔄')
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })

            Text('兑换积分')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.successLight)
          .borderRadius(AppBorderRadius.radiusBase)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            console.log('HomePage: 点击兑换积分按钮')
            this.exchangePoints()
          })
        }

        // 功能2: 数据分析
        GridItem() {
          Column() {
            Text('📊')
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })

            Text('数据分析')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.warningLight)
          .borderRadius(AppBorderRadius.radiusBase)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            console.log('HomePage: 点击数据分析按钮')
            router.pushUrl({
              url: 'pages/AnalysisPage'
            })
          })
        }

        // 功能3: 商城购物
        GridItem() {
          Column() {
            Text(AppIcons.mall)
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })

            Text('积分商城')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.primaryLight)
          .borderRadius(AppBorderRadius.radiusBase)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            console.log('HomePage: 点击积分商城按钮')
            router.pushUrl({
              url: 'pages/MallPage'
            })
          })
        }

        // 功能4: 手动输入步数
        GridItem() {
          Column() {
            Text(AppIcons.steps)
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })

            Text('手动输入步数')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.successLight)
          .borderRadius(AppBorderRadius.radiusBase)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            console.log('HomePage: 点击手动输入步数按钮')
            this.showStepInputDialog()
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(AppSpacing.spaceLg)
      .columnsGap(AppSpacing.spaceLg)
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildRankingEntry() {
    Column() {
      Row() {
        Row() {
          Text(AppIcons.ranking)
            .fontSize(AppFonts.fontSize2Xl)
            .margin({ right: AppSpacing.spaceSm })

          Text('步数排行榜')
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(AppColors.titleColor)
            .fontWeight(AppFonts.fontWeightBold)
        }

        Blank()

        Row() {
          Text('查看完整榜单')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)

          Text('➡️')
            .fontSize(AppFonts.fontSizeBase)
            .margin({ left: AppSpacing.spaceXs })
        }
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
        .backgroundColor(AppColors.primaryLight)
        .borderRadius(AppBorderRadius.radiusBase)
        .onClick(() => {
          console.log('HomePage: 点击查看完整榜单')
          router.pushUrl({
            url: 'pages/RankingPage'
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: AppSpacing.spaceLg })

      // 简单的排行榜预览
      Column() {
        // 这里可以添加简单的排行榜预览内容
        Text('暂无排行榜数据')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(AppSpacing.space2Xl)
      }
      .width('100%')
      .backgroundColor(AppColors.bgColor)
      .borderRadius(AppBorderRadius.radiusBase)
      .border({
        width: 1,
        color: AppColors.borderColor
      })
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
  }

  // 修复缺失的方法
  private async loadStepData(): Promise<void> {
    try {
      console.log('HomePage: 开始从后端加载步数数据')
        
      // 重要：先保存当前本地最新的今日步数（可能包含未上传的模拟步数）
      const localTodaySteps = this.stateStore.todaySteps
      console.log('HomePage: 本地最新步数:', localTodaySteps)
      
      // 从后端获取步数统计
      const statsResponse = await this.apiClient.getStepStatistics()
        
      if (statsResponse.code === 1 && statsResponse.data) {
        // 重要：只更新其他统计数据，不覆盖今日步数
        // 今日步数以本地为准，除非本地为0（首次加载）
        if (localTodaySteps === 0) {
          // 首次加载，使用后端数据
          const todaySteps = statsResponse.data.todaySteps || 0
          await this.stateStore.updateTodaySteps(todaySteps)
          this.todaySteps = todaySteps
          console.log('HomePage: 首次加载，使用后端步数:', todaySteps)
        } else {
          // 已有本地数据，保持本地步数不变
          this.todaySteps = localTodaySteps
          console.log('HomePage: 保留本地步数:', this.todaySteps)
        }
      } else {
        console.warn('HomePage: 后端请求失败，使用本地数据')
        this.todaySteps = localTodaySteps
      }
    } catch (error) {
      console.error('Failed to load step data from backend:', error)
      // 降级方案：使用本地数据
      this.todaySteps = this.stateStore.todaySteps
    }
  }
  
  private async loadUserInfo(): Promise<void> {
    try {
      console.log('HomePage: 开始从后端加载用户信息')
        
      // 从后端获取最新用户信息
      const userInfoResponse = await this.apiClient.getUserInfo()
        
      if (userInfoResponse.code === 1 && userInfoResponse.data) {
        // 更新本地存储
        await this.stateStore.saveUserInfo(userInfoResponse.data)
          
        this.userInfo = userInfoResponse.data
        this.totalPoints = userInfoResponse.data.totalPoints
          
        console.log('HomePage: 从后端加载用户信息成功')
        console.log('用户ID:', this.userInfo.id, '昵称:', this.userInfo.nickname)
        console.log('总积分:', this.totalPoints, '总步数:', this.userInfo.totalSteps)
      } else {
        console.warn('HomePage: 后端请求失败，使用本地数据')
          
        // 降级方案：从本地加载
        const userInfo = await this.stateStore.getUserInfo()
        this.userInfo = userInfo
        this.totalPoints = userInfo.totalPoints
      }
    } catch (error) {
      console.error('Failed to load user info from backend:', error)
        
      // 降级方案：从本地加载
      try {
        const userInfo = await this.stateStore.getUserInfo()
        this.userInfo = userInfo
        this.totalPoints = userInfo.totalPoints
      } catch (localError) {
        console.error('Failed to load local user info:', localError)
      }
    }
  }

  private stopSimulation(): void {
    if (this.simulationInterval) {
      clearInterval(this.simulationInterval)
      this.simulationInterval = null
    }
    this.isSimulating = false
  }

  private simulateWalking(): void {
    this.isSimulating = true
    this.simulationInterval = setInterval(() => {
      const newSteps = this.todaySteps + Math.floor(Math.random() * 10) + 1
      this.todaySteps = newSteps
      this.stateStore.updateTodaySteps(newSteps)
    }, 1000)
  }

  private getCurrentDate(): string {
    const today = new Date()
    return `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
  }

  private async uploadSteps(): Promise<void> {
    try {
      await this.apiClient.uploadSteps(this.todaySteps, this.getCurrentDate())
      promptAction.showToast({
        message: '步数上传成功！',
        duration: 2000
      })
      
      // 上传成功后，重新加载用户信息以更新总步数
      console.log('🔄 上传步数成功，重新加载用户信息...')
      await this.loadUserInfo()
      console.log('✅ 用户信息已更新，总步数:', this.userInfo?.totalSteps)
    } catch (error) {
      console.error('Failed to upload steps:', error)
      promptAction.showToast({
        message: '上传失败，请重试',
        duration: 2000
      })
    }
  }

  private exchangePoints(): void {
    console.log('HomePage: 兑换积分功能')
    router.pushUrl({
      url: 'pages/PointsExchangePage'
    })
  }

  private showStepInputDialog(): void {
    if (this.onShowStepInput) {
      this.onShowStepInput(true)
    }
  }
}