import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { UserInfo, StepStatistics } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppShadows
} from '../config/DesignSystem'

/**
 * 首页Tab组件
 */
@Component
export struct HomeTab {
  @State userInfo: UserInfo | null = null
  @State todaySteps: number = 0
  @State totalPoints: number = 0
  @State stepGoal: number = 10000
  @State isLoading: boolean = true
  @State isSimulating: boolean = false
  @State simulatedSteps: number = 0
  @State showUploadDialog: boolean = false
  @State uploadSteps: string = ''

  private apiClient = ApiClient
  private stateStore = StateStore
  private simulateTimer: number = -1
  private simulateInterval: number = 3000 // 每3秒增加一次步数

  async aboutToAppear() {
    await this.loadUserData()
  }

  aboutToDisappear() {
    // 清理定时器
    this.stopSimulation()
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 顶部欢迎区域
          this.buildHeader()

          // 今日步数卡片
          this.buildTodayStepsCard()

          // 数据统计卡片
          this.buildStatisticsCards()

          // 快捷功能
          this.buildQuickActions()
        }
        .width('100%')
        .padding(AppSpacing.spaceLg)
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)

      // 上传步数对话框
      if (this.showUploadDialog) {
        this.buildUploadDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  @Builder buildHeader() {
    Row() {
      Column() {
        Text(`你好，${this.userInfo?.nickname || '用户'}`)
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .alignSelf(ItemAlign.Start)

        Text('今天也要加油运动哦！')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Column() {
        Text(AppIcons.profile)
          .fontSize(32)
      }
      .width(50)
      .height(50)
      .backgroundColor(AppColors.primaryLight)
      .borderRadius(AppBorderRadius.radiusFull)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildTodayStepsCard() {
    Column() {
      Row() {
        Column() {
          Text(this.todaySteps.toLocaleString())
            .fontSize(48)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.primaryColor)

          Text('今日步数')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text(`${Math.round((this.todaySteps / this.stepGoal) * 100)}%`)
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.successColor)

          Text('目标进度')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 进度条
      Progress({ value: this.todaySteps, total: this.stepGoal, type: ProgressType.Linear })
        .width('100%')
        .height(8)
        .borderRadius(AppBorderRadius.radiusFull)
        .color(AppColors.primaryColor)
        .backgroundColor(AppColors.borderColor)
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildStatisticsCards() {
    Row() {
      // 总步数
      Column() {
        Text(AppIcons.steps)
          .fontSize(24)
          .margin({ bottom: AppSpacing.spaceSm })

        Text((this.userInfo?.totalSteps || 0).toLocaleString())
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.textColor)

        Text('总步数')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.sportBlue)
      .borderRadius(AppBorderRadius.radiusLg)
      .shadow(AppShadows.shadowBase)

      // 总积分
      Column() {
        Text(AppIcons.points)
          .fontSize(24)
          .margin({ bottom: AppSpacing.spaceSm })

        Text((this.userInfo?.totalPoints || 0).toLocaleString())
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.textColor)

        Text('总积分')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .padding(AppSpacing.spaceLg)
      .backgroundColor(AppColors.sportOrange)
      .borderRadius(AppBorderRadius.radiusLg)
      .shadow(AppShadows.shadowBase)
      .margin({ left: AppSpacing.spaceLg })
    }
    .width('100%')
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildQuickActions() {
    Column() {
      Text('快捷功能')
        .fontSize(AppFonts.fontSizeLg)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg })

      Row() {
        this.buildQuickActionItem('🏆', '排行榜', () => {
          router.pushUrl({
            url: 'pages/RankingPage'
          }).catch((err: Error) => {
            console.error('跳转到排行榜失败:', err)
            promptAction.showToast({ message: '跳转失败', duration: 2000 })
          })
        })

        this.buildQuickActionItem('⭐', '积分兑换', () => {
          router.pushUrl({
            url: 'pages/PointsExchangePage'
          }).catch((err: Error) => {
            console.error('跳转到积分兑换失败:', err)
            promptAction.showToast({ message: '跳转失败', duration: 2000 })
          })
        })

        this.buildQuickActionItem('📊', '数据分析', () => {
          // 切换到趋势Tab
          // 这里需要通过事件通知MainPage切换Tab
          promptAction.showToast({ message: '请在底部导航栏点击“趋势”', duration: 2000 })
        })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 运动功能区
      this.buildExerciseActions()
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
  }

  @Builder buildExerciseActions() {
    Column() {
      Text('运动工具')
        .fontSize(AppFonts.fontSizeLg)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg })

      Row() {
        // 模拟运动按钮
        Column() {
          Text(this.isSimulating ? '⏸️' : '▶️')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text(this.isSimulating ? '停止模拟' : '模拟运动')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(this.isSimulating ? AppColors.errorColor : AppColors.successColor)
            .fontWeight(AppFonts.fontWeightMedium)

          if (this.isSimulating) {
            Text(`+${this.simulatedSteps}步`)
              .fontSize(AppFonts.fontSizeXs)
              .fontColor(AppColors.textSecondary)
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(this.isSimulating ? AppColors.errorLight : AppColors.successLight)
        .borderRadius(AppBorderRadius.radiusBase)
        .onClick(() => {
          if (this.isSimulating) {
            this.stopSimulation()
          } else {
            this.startSimulation()
          }
        })

        // 手动上传步数按钮
        Column() {
          Text('⬆️')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('手动上传')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightMedium)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.primaryLight)
        .borderRadius(AppBorderRadius.radiusBase)
        .margin({ left: AppSpacing.spaceLg })
        .onClick(() => {
          this.showUploadDialog = true
          this.uploadSteps = ''
        })
      }
      .width('100%')

      // 模拟运动说明
      if (this.isSimulating) {
        Text('模拟运动中，每3秒自动增加50-150步')
          .fontSize(AppFonts.fontSizeXs)
          .fontColor(AppColors.textSecondary)
          .margin({ top: AppSpacing.spaceMd })
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
  }
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
  }

  @Builder buildQuickActionItem(icon: string, title: string, onClick: () => void) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: AppSpacing.spaceSm })

      Text(title)
        .fontSize(AppFonts.fontSizeSm)
        .fontColor(AppColors.textColor)
    }
    .layoutWeight(1)
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgColor)
    .borderRadius(AppBorderRadius.radiusBase)
    .onClick(onClick)
  }

  private async loadUserData(): Promise<void> {
    this.isLoading = true
    try {
      // 获取用户信息
      const response = await this.apiClient.getUserInfo()

      if (response.code === 1 && response.data) {
        this.userInfo = response.data
        this.totalPoints = response.data.totalPoints

        // 从 StateStore获取今日步数
        this.todaySteps = this.stateStore.todaySteps

        console.log('HomeTab: 用户数据加载成功')
      } else {
        console.error('HomeTab: 获取用户信息失败:', response.message)
        
        // 如果是认证失败（401），跳转到登录页
        if (response.code === 401 || response.message.includes('Authentication')) {
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
        } else {
          promptAction.showToast({
            message: '获取用户信息失败',
            duration: 2000
          })
        }
      }
    } catch (error) {
      console.error('HomeTab: 加载用户数据异常:', error)
      
      // 检查是否是认证错误
      if (error.message && (error.message.includes('401') || error.message.includes('Authentication'))) {
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
      } else {
        promptAction.showToast({
          message: '加载数据失败',
          duration: 2000
        })
      }
    } finally {
      this.isLoading = false
    }
  }

  // ==================== 模拟运动功能 ====================

  /**
   * 开始模拟运动
   */
  private startSimulation(): void {
    this.isSimulating = true
    this.simulatedSteps = 0

    // 每3秒增加50-150步
    this.simulateTimer = setInterval(() => {
      // 生成50-150之间的随机步数
      const randomSteps = Math.floor(Math.random() * 101) + 50
      this.simulatedSteps += randomSteps

      // 更新今日步数
      this.todaySteps += randomSteps

      // 更新StateStore中的步数
      this.stateStore.updateTodaySteps(this.todaySteps)

      console.log(`模拟运动: +${randomSteps}步, 总计: ${this.todaySteps}步`)
    }, this.simulateInterval)

    promptAction.showToast({
      message: '模拟运动已开始',
      duration: 2000
    })
  }

  /**
   * 停止模拟运动
   */
  private stopSimulation(): void {
    if (this.simulateTimer !== -1) {
      clearInterval(this.simulateTimer)
      this.simulateTimer = -1
    }

    this.isSimulating = false

    // 同步步数到后端
    if (this.simulatedSteps > 0) {
      this.syncStepsToBackend()
    }

    promptAction.showToast({
      message: `模拟运动已停止，共增加${this.simulatedSteps}步`,
      duration: 2000
    })
  }

  /**
   * 同步步数到后端
   */
  private async syncStepsToBackend(): Promise<void> {
    try {
      const today = new Date()
      const dateStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`

      const response = await this.apiClient.uploadSteps(this.todaySteps, dateStr)

      if (response.code === 1) {
        console.log('步数同步成功')
        // 重新加载用户信息以更新总步数和积分
        await this.loadUserData()
      } else {
        console.error('步数同步失败:', response.message)
        promptAction.showToast({
          message: '步数同步失败',
          duration: 2000
        })
      }
    } catch (error) {
      console.error('步数同步异常:', error)
      promptAction.showToast({
        message: '步数同步异常',
        duration: 2000
      })
    }
  }

  // ==================== 手动上传步数功能 ====================

  /**
   * 关闭上传对话框
   */
  private closeUploadDialog(): void {
    this.showUploadDialog = false
    this.uploadSteps = ''
  }

  /**
   * 确认上传步数
   */
  private async confirmUploadSteps(): Promise<void> {
    if (!this.uploadSteps || this.uploadSteps.trim() === '') {
      promptAction.showToast({
        message: '请输入步数',
        duration: 2000
      })
      return
    }

    const steps = parseInt(this.uploadSteps.trim())

    if (isNaN(steps) || steps <= 0) {
      promptAction.showToast({
        message: '请输入有效的步数',
        duration: 2000
      })
      return
    }

    if (steps > 100000) {
      promptAction.showToast({
        message: '单次上传不能超过100000步',
        duration: 2000
      })
      return
    }

    try {
      // 更新今日步数
      this.todaySteps += steps

      // 更新StateStore
      this.stateStore.updateTodaySteps(this.todaySteps)

      // 同步到后端
      await this.syncStepsToBackend()

      // 关闭对话框
      this.closeUploadDialog()

      promptAction.showToast({
        message: `成功上传${steps}步`,
        duration: 2000
      })
    } catch (error) {
      console.error('上传步数失败:', error)
      promptAction.showToast({
        message: '上传步数失败',
        duration: 2000
      })
    }
  }

  /**
   * 构建上传步数对话框
   */
  @Builder buildUploadDialog() {
    Stack() {
      // 遮罩层
      Column() {
        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000040')
      .onClick(() => {
        this.closeUploadDialog()
      })

      // 对话框内容
      Column() {
        Text('手动上传步数')
          .fontSize(AppFonts.fontSizeXl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.titleColor)
          .margin({ bottom: AppSpacing.spaceLg })

        Text('请输入要增加的步数')
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        TextInput({ placeholder: '例如：5000', text: this.uploadSteps })
          .width('100%')
          .height(52)
          .borderRadius(AppBorderRadius.radiusBase)
          .backgroundColor(AppColors.bgColor)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .border({ width: 1, color: AppColors.borderColor })
          .type(InputType.Number)
          .onChange((value: string) => { this.uploadSteps = value })
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
            .onClick(() => { this.closeUploadDialog() })
            .margin({ right: AppSpacing.spaceLg })

          Button('确认上传')
            .layoutWeight(1)
            .height(48)
            .fontSize(AppFonts.fontSizeBase)
            .backgroundColor(AppColors.primaryColor)
            .fontColor(Color.White)
            .borderRadius(AppBorderRadius.radiusBase)
            .onClick(() => { this.confirmUploadSteps() })
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