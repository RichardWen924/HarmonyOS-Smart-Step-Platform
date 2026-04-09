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
  AppIcons
} from '../config/DesignSystem'
import AppShadows from '../config/AppShadows'
import { TrendPage } from './TrendPage'
import { RecordPage } from './RecordPage'

enum TabIndex {
  HOME = 0,
  TREND = 1,
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
  
  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    // 确保ApiClient有正确的Token
    this.syncTokenToApiClient()
    this.loadUserData()
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()
      
      // 内容区域
      Stack() {
        // 首页
        if (this.currentTabIndex === TabIndex.HOME) {
          HomePage()
            .width('100%')
            .height('100%')
        }
        
        // 趋势页 - 使用独立的TrendPage组件
        if (this.currentTabIndex === TabIndex.TREND) {
          TrendPage()
            .width('100%')
            .height('100%')
        }
        
        // 商城页
        if (this.currentTabIndex === TabIndex.MALL) {
          // MallPage组件暂时使用空页面
          Column() {
            Text('🛒 积分商城')
              .fontSize(AppFonts.fontSize2Xl)
              .fontColor(AppColors.titleColor)
              .fontWeight(AppFonts.fontWeightBold)
              .margin({ bottom: AppSpacing.spaceLg })
            
            Text('商品兑换功能开发中')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.textSecondary)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        
        // 记录页
        if (this.currentTabIndex === TabIndex.RECORD) {
          RecordPage()
            .width('100%')
            .height('100%')
        }
        
        // 个人中心页 - 使用路由跳转
        if (this.currentTabIndex === TabIndex.PROFILE) {
          Column() {
            Text('👤 个人中心')
              .fontSize(AppFonts.fontSize2Xl)
              .fontColor(AppColors.titleColor)
              .fontWeight(AppFonts.fontWeightBold)
              .margin({ bottom: AppSpacing.spaceLg })
            
            Text('点击下方Tab栏的"我的"查看个人中心')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.textSecondary)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .layoutWeight(1)
      
      // 底部 Tab 导航
      this.buildTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  // 构建顶部标题栏
  @Builder buildHeader() {
    Row() {
      Text(this.getTabTitle())
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)
      
      Blank()
      
      // 显示用户积分
      if (this.totalPoints > 0) {
        Row() {
          Text(AppIcons.points)
            .fontSize(AppFonts.fontSizeLg)
            .margin({ right: AppSpacing.spaceXs })
          
          Text(this.totalPoints.toLocaleString())
            .fontSize(AppFonts.fontSizeBase)
            .fontWeight(AppFonts.fontWeightMedium)
            .fontColor(AppColors.warningColor)
        }
        .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
        .backgroundColor(AppColors.warningLight)
        .borderRadius(AppBorderRadius.radiusFull)
      }
    }
    .width('100%')
    .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
  }

  // 构建底部 Tab 栏
  @Builder buildTabBar() {
    Row() {
      // Tab 1: 首页
      this.buildTabItem(AppIcons.home, '首页', TabIndex.HOME)
      
      // Tab 2: 趋势
      this.buildTabItem(AppIcons.trend, '趋势', TabIndex.TREND)
      
      // Tab 3: 商城
      this.buildTabItem(AppIcons.mall, '商城', TabIndex.MALL)
      
      // Tab 4: 记录
      this.buildTabItem(AppIcons.record, '记录', TabIndex.RECORD)
      
      // Tab 5: 我的 - 跳转到个人中心页面
      this.buildTabItem(AppIcons.profile, '我的', TabIndex.PROFILE, true)
    }
    .width('100%')
    .height(68)
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
  }

  // 构建 Tab 项
  @Builder buildTabItem(icon: string, label: string, index: TabIndex, isProfile: boolean = false) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: AppSpacing.spaceXs })
        .fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary)
      
      Text(label)
        .fontSize(AppFonts.fontSizeXs)
        .fontColor(this.currentTabIndex === index ? AppColors.primaryColor : AppColors.textSecondary)
        .fontWeight(this.currentTabIndex === index ? AppFonts.fontWeightMedium : AppFonts.fontWeightRegular)
    }
    .width(60)
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (isProfile) {
        // 跳转到个人中心页面
        router.pushUrl({
          url: 'pages/ProfilePage'
        })
      } else {
        this.currentTabIndex = index
      }
    })
  }

  // 获取当前 Tab 标题
  private getTabTitle(): string {
    const titles = ['运动健康', '步数趋势', '积分商城', '兑换记录', '个人中心']
    return titles[this.currentTabIndex]
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('MainPage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('MainPage: StateStore中没有找到Token')
    }
  }

  // 加载用户数据
  private async loadUserData(): Promise<void> {
    try {
      const userInfo = await this.stateStore.getUserInfo()
      this.userInfo = userInfo
      this.todaySteps = this.stateStore.todaySteps
      this.totalPoints = userInfo.totalPoints
      
      // 从服务器获取最新积分
      const userInfoResponse = await this.apiClient.getUserInfo()
      if (userInfoResponse.code === 1) {
        this.totalPoints = userInfoResponse.data.totalPoints
        await this.stateStore.updatePoints(
          userInfoResponse.data.totalPoints,
          userInfoResponse.data.remainingSteps
        )
      }
    } catch (error) {
      console.error('Failed to load user data:', error)
    }
  }
}

// ==================== 首页组件 ====================
@Component
struct HomePage {
  @State todaySteps: number = 0
  @State isSimulating: boolean = false
  @State showManualInputDialog: boolean = false
  @State manualInputValue: string = ''
  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    // 确保ApiClient有正确的Token
    this.syncTokenToApiClient()
    this.loadStepData()
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
      
      // 手动输入弹窗
      if (this.showManualInputDialog) {
        this.buildManualInputDialog()
      }
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
        
        Text(AppIcons.steps)
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.primaryColor)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      Row() {
        Column() {
          Text(this.todaySteps.toLocaleString())
            .fontSize(AppFonts.fontSize7Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.primaryColor)
          
          Text('步')
            .fontSize(AppFonts.fontSizeLg)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)
        
        // 目标完成度环
        Column() {
          Stack() {
            // 背景环
            Circle()
              .width(80)
              .height(80)
              .fill(Color.Transparent)
              .stroke(AppColors.borderColor)
              .strokeWidth(4)
            
            // 进度环
            Circle()
              .width(80)
              .height(80)
              .fill(Color.Transparent)
              .stroke(AppColors.primaryColor)
              .strokeWidth(4)
              .strokeDashArray([Math.PI * 80 * (Math.min(this.todaySteps, 10000) / 10000), Math.PI * 80])
              .strokeDashOffset(0)
            
            Column() {
              Text(`${Math.min(Math.round(this.todaySteps / 100), 100)}`)
                .fontSize(AppFonts.fontSizeLg)
                .fontWeight(AppFonts.fontWeightBold)
                .fontColor(AppColors.primaryColor)
              
              Text('%')
                .fontSize(AppFonts.fontSizeSm)
                .fontColor(AppColors.textSecondary)
            }
            .alignItems(HorizontalAlign.Center)
          }
          
          Text('目标进度')
            .fontSize(AppFonts.fontSizeXs)
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
          .enabled(!this.isSimulating)
          .onClick(() => {
            this.simulateWalking()
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
    .shadow(AppShadows.shadowBase)
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
          .onClick(() => {
            this.exchangePoints()
          })
        }

        GridItem() {
          Column() {
            Text('📅')
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })
            
            Text('手动输入')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.primaryLight)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            this.manualInput()
          })
        }

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
          .onClick(() => {
            promptAction.showToast({
              message: '请点击下方Tab栏的"趋势"查看数据分析',
              duration: 2000
            })
          })
        }

        GridItem() {
          Column() {
            Text('⚙️')
              .fontSize(32)
              .margin({ bottom: AppSpacing.spaceSm })
            
            Text('运动设置')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textColor)
              .fontWeight(AppFonts.fontWeightMedium)
          }
          .width('100%')
          .height(100)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.bgColor)
          .borderRadius(AppBorderRadius.radiusBase)
          .onClick(() => {
            promptAction.showToast({
              message: '运动设置功能开发中',
              duration: 2000
            })
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
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildRankingEntry() {
    Column() {
      Row() {
        Row() {
          Text('🏆')
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
        .borderRadius(AppBorderRadius.radiusFull)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 增强排行榜前三名显示
      Row() {
        ForEach([1, 2, 3], (rank: number) => {
          Column() {
            // 奖牌背景
            Stack() {
              Circle()
                .width(60)
                .height(60)
                .fill(rank === 1 ? AppColors.warningLight : 
                      rank === 2 ? AppColors.borderColor : 
                      AppColors.successLight)
              
              Text(rank === 1 ? '🥇' : rank === 2 ? '🥈' : '🥉')
                .fontSize(28)
            }
            .margin({ bottom: AppSpacing.spaceSm })
            
            Column() {
              Text(`用户${rank}`)
                .fontSize(AppFonts.fontSizeBase)
                .fontColor(AppColors.textColor)
                .fontWeight(AppFonts.fontWeightBold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
              Text(`${(30000 - rank * 5000).toLocaleString()}步`)
                .fontSize(AppFonts.fontSizeSm)
                .fontColor(rank === 1 ? AppColors.warningColor : AppColors.textSecondary)
                .fontWeight(AppFonts.fontWeightMedium)
            }
            .alignItems(HorizontalAlign.Center)
          }
          .layoutWeight(1)
          .padding(AppSpacing.spaceLg)
          .backgroundColor(AppColors.bgCard)
          .borderRadius(AppBorderRadius.radiusLg)
          .shadow(AppShadows.shadowBase)
        })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 添加激励文案
      Row() {
        Text('💪 今日你上榜了吗？快来挑战吧！')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .fontWeight(AppFonts.fontWeightMedium)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .border({
      width: 2,
      color: AppColors.primaryLight
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/RankingPage'
      })
    })
  }

  @Builder buildManualInputDialog() {
    // 遮罩层
    Stack() {
      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.5)
        .onClick(() => {
          this.showManualInputDialog = false
        })
      
      // 弹窗内容
      Column() {
        Text('手动输入步数')
          .fontSize(AppFonts.fontSizeXl)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightBold)
          .margin({ bottom: AppSpacing.spaceLg })
        
        Text('请输入今日步数（0-50000）')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
          .margin({ bottom: AppSpacing.spaceLg })
        
        // 输入框
        TextInput({
          placeholder: '例如：5000',
          text: this.manualInputValue
        })
          .width('100%')
          .height(50)
          .backgroundColor(AppColors.bgColor)
          .border({
            width: 1,
            color: AppColors.borderColor,
            radius: AppBorderRadius.radiusBase
          })
          .padding(AppSpacing.spaceLg)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .onChange((value: string) => {
            this.manualInputValue = value
          })
          .margin({ bottom: AppSpacing.spaceLg })
        
        // 按钮组
        Row() {
          Button('取消')
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.bgColor)
            .fontColor(AppColors.textColor)
            .borderRadius(AppBorderRadius.radiusBase)
            .layoutWeight(1)
            .onClick(() => {
              this.showManualInputDialog = false
              this.manualInputValue = ''
            })
          
          Button('确定')
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radiusBase)
            .layoutWeight(1)
            .margin({ left: AppSpacing.spaceLg })
            .onClick(() => {
              this.handleManualInput()
            })
        }
        .width('100%')
        .height(50)
      }
      .width('80%')
      .padding(AppSpacing.space3Xl)
      .backgroundColor(AppColors.bgCard)
      .borderRadius(AppBorderRadius.radiusLg)
      .shadow(AppShadows.shadowLg)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('HomePage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('HomePage: StateStore中没有找到Token')
    }
  }

  private async loadStepData(): Promise<void> {
    this.todaySteps = this.stateStore.todaySteps
  }

  private simulateWalking() {
    this.isSimulating = true
    
    // 模拟每 2 秒增加 100-500 步
    const interval = setInterval(() => {
      const addSteps = Math.floor(Math.random() * 400) + 100
      this.todaySteps += addSteps
      this.stateStore.addSteps(addSteps)
      
      if (this.todaySteps >= 10000) {
        clearInterval(interval)
        this.isSimulating = false
        promptAction.showToast({
          message: '🎉 恭喜您完成今日目标！',
          duration: 3000
        })
      }
    }, 2000)
    
    promptAction.showToast({
      message: '🚶 开始模拟走路...',
      duration: 1500
    })
  }

  private async uploadSteps(): Promise<void> {
    try {
      const response = await this.apiClient.uploadSteps(
        this.todaySteps,
        new Date().toISOString().split('T')[0]
      )
      
      if (response.code === 1) {
        promptAction.showToast({
          message: '✅ 数据上传成功',
          duration: 2000
        })
      } else {
        promptAction.showToast({
          message: response.message,
          duration: 2000
        })
      }
    } catch (error) {
      promptAction.showToast({
        message: '❌ 上传失败，请重试',
        duration: 2000
      })
    }
  }

  private async exchangePoints(): Promise<void> {
    if (this.todaySteps < 1000) {
      promptAction.showToast({
        message: '满 1000 步可兑换积分',
        duration: 2000
      })
      return
    }
    
    try {
      const steps = Math.floor(this.todaySteps / 1000) * 1000
      const response = await this.apiClient.exchangePoints(steps)
      
      if (response.code === 1) {
        this.todaySteps = response.data.remainingSteps
        await this.stateStore.updateTodaySteps(this.todaySteps)
        
        promptAction.showToast({
          message: `🎉 成功兑换${response.data.gainedPoints}积分`,
          duration: 2000
        })
      }
    } catch (error) {
      promptAction.showToast({
        message: '❌ 兑换失败',
        duration: 2000
      })
    }
  }

  private manualInput(): void {
    this.showManualInputDialog = true
  }

  private handleManualInput(): void {
    const inputValue = parseInt(this.manualInputValue)
    
    if (isNaN(inputValue) || inputValue < 0 || inputValue > 50000) {
      promptAction.showToast({
        message: '请输入有效的步数（0-50000）',
        duration: 2000
      })
      return
    }
    
    this.todaySteps += inputValue
    this.stateStore.addSteps(inputValue)
    
    this.showManualInputDialog = false
    this.manualInputValue = ''
    
    promptAction.showToast({
      message: `✅ 成功添加 ${inputValue.toLocaleString()} 步`,
      duration: 2000
    })
  }
}
