import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { StepRecord, UserInfo, RankingItem } from '../types/common'
import { LineChart } from '../components/LineChart'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import { AppShadows } from '../config/DesignSystem'

@Entry
@Component
export struct AnalysisPage {
  @State stepRecords: StepRecord[] = []
  @State totalSteps: number = 0
  @State avgSteps: number = 0
  @State maxSteps: number = 0
  @State selectedPeriod: number = 7 // 7天、30天
  @State isLoading: boolean = true
  @State chartData: number[] = []
  @State chartLabels: string[] = []
  @State chartKey: number = 0 // 用于强制刷新图表
  @State currentTab: string = 'trend' // trend, statistics, comparison

  // 对比分析数据
  @State weeklyComparison: number = 0 // 本周vs上周增长率（%）
  @State monthlyRanking: number = 0 // 本月排名
  @State progressSpeed: string = '' // 进步速度描述
  @State achievementRate: number = 0 // 达标率（%）
  @State consecutiveDays: number = 0 // 连续打卡天数

  private apiClient = ApiClient
  private stateStore = StateStore

  aboutToAppear() {
    // 确保ApiClient有正确的Token
    this.syncTokenToApiClient()
    // 点击数据分析时，先上传当前的步数数据到服务器（触发同步）
    this.uploadCurrentSteps().then(() => {
      this.loadStepStatistics()
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // Tab切换
      this.buildTabSelector()

      Scroll() {
        Column() {
          // 根据当前Tab显示不同内容
          if (this.currentTab === 'trend') {
            this.buildTrendAnalysis()
          } else if (this.currentTab === 'statistics') {
            this.buildStatisticsAnalysis()
          } else if (this.currentTab === 'comparison') {
            this.buildComparisonAnalysis()
          }
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
  }

  @Builder buildHeader() {
    Row() {
      Row() {
        Text('←')
          .fontSize(AppFonts.fontSize2Xl)
          .onClick(() => {
            router.back()
          })
          .margin({ right: AppSpacing.spaceLg })

        Text('数据分析')
          .fontSize(AppFonts.fontSize2Xl)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightBold)
      }

      Blank()

      // 周期选择
      Row() {
        Button('近7天')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedPeriod === 7 ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedPeriod === 7 ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
          .onClick(() => {
            if (this.selectedPeriod !== 7) {
              // 先清空图表
              this.chartData = []
              this.chartLabels = []
              this.selectedPeriod = 7
              // 延迟加载，让UI先更新
              setTimeout(() => {
                this.loadStepStatistics()
              }, 100)
            }
          })

        Button('近30天')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedPeriod === 30 ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedPeriod === 30 ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
          .onClick(() => {
            if (this.selectedPeriod !== 30) {
              // 先清空图表
              this.chartData = []
              this.chartLabels = []
              this.selectedPeriod = 30
              // 延迟加载，让UI先更新
              setTimeout(() => {
                this.loadStepStatistics()
              }, 100)
            }
          })
      }
    }
    .width('100%')
    .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
  }

  @Builder buildTabSelector() {
    Row() {
      this.buildTabButton('趋势分析', 'trend')
      this.buildTabButton('数据统计', 'statistics')
      this.buildTabButton('对比分析', 'comparison')
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder buildTabButton(label: string, tab: string) {
    Button(label)
      .fontSize(AppFonts.fontSizeBase)
      .backgroundColor(this.currentTab === tab ? AppColors.primaryColor : Color.Transparent)
      .fontColor(this.currentTab === tab ? Color.White : AppColors.textColor)
      .borderRadius(AppBorderRadius.radius2Xl)
      .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
      .onClick(() => {
        this.currentTab = tab
      })
  }

  @Builder buildTrendAnalysis() {
    Column() {
      // 统计概览
      this.buildStatisticsOverview()

      // 步数趋势图
      this.buildStepChart()

      // 详细数据列表
      this.buildDataList()
    }
    .width('100%')
  }

  @Builder buildStatisticsAnalysis() {
    Column() {
      // 统计概览
      this.buildStatisticsOverview()

      // 统计分析卡片
      this.buildStatisticsCards()
    }
    .width('100%')
  }

  @Builder buildComparisonAnalysis() {
    Column() {
      // 统计概览
      this.buildStatisticsOverview()

      // 对比分析
      this.buildComparisonCards()
    }
    .width('100%')
  }

  @Builder buildStatisticsOverview() {
    Row() {
      Column() {
        Text(this.totalSteps.toLocaleString())
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
        Text(this.avgSteps.toLocaleString())
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.successColor)

        Text('平均步数')
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
        Text(this.maxSteps.toLocaleString())
          .fontSize(AppFonts.fontSize3Xl)
          .fontWeight(AppFonts.fontWeightBold)
          .fontColor(AppColors.warningColor)

        Text('最高步数')
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

  @Builder buildStepChart() {
    Column() {
      Row() {
        Text('📈 步数趋势曲线图')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightBold)

        Blank()

        Text(`${this.selectedPeriod}天趋势图`)
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 使用曲线图组件 - 通过条件渲染强制重建
      if (this.chartData.length > 0 && this.chartKey >= 0) {
        LineChart({
          data: this.chartData,
          labels: this.chartLabels,
          chartHeight: 250,
          lineColor: AppColors.primaryColor,
          pointColor: AppColors.warningColor,
          gridColor: AppColors.borderColor
        })
      } else if (this.chartData.length === 0) {
        Column() {
          Text('📊')
            .fontSize(48)
            .margin({ bottom: AppSpacing.spaceLg })

          Text('暂无数据')
            .fontSize(AppFonts.fontSizeLg)
            .fontColor(AppColors.textSecondary)
            .fontWeight(AppFonts.fontWeightMedium)

          Text('开始运动记录数据吧！')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textDisabled)
            .margin({ top: AppSpacing.spaceSm })
        }
        .width('100%')
        .height(250)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(AppColors.bgCard)
        .borderRadius(AppBorderRadius.radiusLg)
      }
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  @Builder buildDataList() {
    Column() {
      Row() {
        Text('📋 详细数据列表')
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.titleColor)
          .fontWeight(AppFonts.fontWeightBold)

        Blank()

        Text(`${this.stepRecords.length}条记录`)
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(AppColors.primaryColor)

          Text('加载中...')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)
            .margin({ top: AppSpacing.spaceLg })
        }
        .width('100%')
        .padding(AppSpacing.space5Xl)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.stepRecords.length === 0) {
        Column() {
          Text('🏃')
            .fontSize(48)
            .margin({ bottom: AppSpacing.spaceLg })

          Text('暂无步数记录')
            .fontSize(AppFonts.fontSizeLg)
            .fontColor(AppColors.textSecondary)
            .fontWeight(AppFonts.fontWeightMedium)

          Text('快去运动生成数据吧！')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textDisabled)
        }
        .width('100%')
        .padding(AppSpacing.space5Xl)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          ForEach(this.stepRecords, (record: StepRecord, index: number) => {
            this.buildStepRecordItem(record, index)
          })
        }
        .width('100%')
        .backgroundColor(AppColors.bgCard)
        .borderRadius(AppBorderRadius.radiusLg)
      }
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
  }

  @Builder buildStatisticsCards() {
    Column() {
      // 完成度分析
      Row() {
        Column() {
          Text('🎯')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('目标完成度')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(this.getCompletionRateText())
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.sportGreen)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)

        Column() {
          Text('🌟')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('活跃天数')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(`${this.getActiveDays()}天`)
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
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

      // 趋势分析
      Row() {
        Column() {
          Text('📈')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('趋势分析')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(this.getTrendAnalysis())
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(this.getTrendColor())
            .fontWeight(AppFonts.fontWeightMedium)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.sportBlue)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)

        Column() {
          Text('🏆')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('最佳表现')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(this.maxSteps.toLocaleString())
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(AppColors.primaryColor)
            .fontWeight(AppFonts.fontWeightBold)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.bgCard)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)
        .margin({ left: AppSpacing.spaceLg })
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

  @Builder buildComparisonCards() {
    Column() {
      // 对比分析 - 只保留本月排名和达标率
      Row() {
        Column() {
          Text('🏅')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('本月排名')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(this.getMonthlyRankingText())
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.sportOrange)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)

        Column() {
          Text('🎯')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('达标率')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(`${this.getAchievementRate()}%`)
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(Color.White)
            .fontWeight(AppFonts.fontWeightBold)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.sportBlue)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)
        .margin({ left: AppSpacing.spaceLg })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.spaceLg })

      // 进步分析
      Row() {
        Column() {
          Text('🚀')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('进步速度')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(this.getProgressSpeedText())
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(this.getProgressSpeedColor())
            .fontWeight(AppFonts.fontWeightMedium)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.bgCard)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)

        Column() {
          Text('🔥')
            .fontSize(32)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('连续打卡')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textColor)
            .fontWeight(AppFonts.fontWeightBold)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(`${this.getConsecutiveDays()}天`)
            .fontSize(AppFonts.fontSizeXl)
            .fontColor(AppColors.sportOrange)
            .fontWeight(AppFonts.fontWeightBold)
        }
        .layoutWeight(1)
        .padding(AppSpacing.spaceLg)
        .backgroundColor(AppColors.bgCard)
        .borderRadius(AppBorderRadius.radiusLg)
        .shadow(AppShadows.shadowBase)
        .margin({ left: AppSpacing.spaceLg })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
  }

  @Builder buildStepRecordItem(record: StepRecord, index: number) {
    Row() {
      // 日期
      Column() {
        Text(this.formatDate(record.date))
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)

        Text(this.getWeekDay(record.date))
          .fontSize(AppFonts.fontSizeXs)
          .fontColor(AppColors.textSecondary)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)

      // 步数
      Column() {
        Text(record.steps.toLocaleString())
          .fontSize(AppFonts.fontSizeLg)
          .fontColor(AppColors.primaryColor)
          .fontWeight(AppFonts.fontWeightBold)

        Text('步')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(index % 2 === 0 ? AppColors.bgColor : Color.Transparent)
    .borderRadius(AppBorderRadius.radiusBase)
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('AnalysisPage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('AnalysisPage: StateStore中没有找到Token')
    }
  }

  // 上传当前步数到服务器（确保Redis中有最新数据）
  private async uploadCurrentSteps(): Promise<void> {
    try {
      const currentSteps = this.stateStore.todaySteps
      console.log('AnalysisPage: 准备上传步数:', currentSteps)

      // 即使步数为0也要上传，以同步最新的步数状态
      const response = await this.apiClient.uploadSteps(
        currentSteps,
        new Date().toISOString().split('T')[0]
      )

      if (response.code === 1) {
        console.log('AnalysisPage: 步数上传成功，已更新Redis，步数:', currentSteps)
      } else {
        console.warn('AnalysisPage: 步数上传失败:', response.message)
        
        // 检查是否是认证失败
        if (response.code === 401 || response.message?.includes('Authentication')) {
          console.warn('AnalysisPage: 步数上传时认证失败')
          // 不在这里跳转，由loadStepStatistics统一处理
        }
      }
    } catch (error) {
      console.error('AnalysisPage: 上传步数异常:', error)
      
      // 检查是否是认证错误
      const errorMessage = error instanceof Error ? error.message : String(error)
      if (errorMessage.includes('401') || errorMessage.includes('Authentication')) {
        console.warn('AnalysisPage: 步数上传时认证异常')
        // 不在这里跳转，由loadStepStatistics统一处理
      }
      // 不阻塞后续操作，仅记录错误
    }
  }

  private async loadStepStatistics(): Promise<void> {
    console.log('[AnalysisPage] 开始加载步数统计，周期:', this.selectedPeriod, '天')
    this.isLoading = true

    try {
      // 获取步数趋势数据
      const trendResponse = await this.apiClient.getStepTrend(this.selectedPeriod)

      if (trendResponse.code === 1 && trendResponse.data) {
        const trendData = trendResponse.data as StepRecord[]
        console.log('[AnalysisPage] 获取到', trendData.length, '条记录')

        // 设置步数记录
        this.stepRecords = trendData

        // 计算统计数据
        if (trendData.length > 0) {
          const total = trendData.reduce((sum, record) => sum + record.steps, 0)
          const max = Math.max(...trendData.map(record => record.steps))
          const avg = Math.round(total / trendData.length)

          this.totalSteps = total
          this.maxSteps = max
          this.avgSteps = avg
        } else {
          this.totalSteps = 0
          this.maxSteps = 0
          this.avgSteps = 0
        }

        // 准备图表数据
        this.prepareChartData()
        console.log('[AnalysisPage] 图表数据已准备，长度:', this.chartData.length)
        
        // 强制刷新图表（通过改变key）
        this.chartKey++
        console.log('[AnalysisPage] 图表key已更新为:', this.chartKey)

        // 计算对比分析指标
        await this.calculateComparisonMetrics()

        console.log('步数趋势数据加载成功:', trendData.length, '条记录')
      } else {
        console.warn('步数趋势数据为空，显示无数据状态')
        
        // 检查是否是认证失败
        if (trendResponse.code === 401 || trendResponse.message?.includes('Authentication')) {
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
        
        this.stepRecords = []
        this.totalSteps = 0
        this.maxSteps = 0
        this.avgSteps = 0
        this.chartData = []
        this.chartLabels = []
      }
    } catch (error) {
      console.error('加载步数统计失败:', error)
      
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
      
      this.stepRecords = []
      this.totalSteps = 0
      this.maxSteps = 0
      this.avgSteps = 0
      this.chartData = []
      this.chartLabels = []
    } finally {
      this.isLoading = false
    }
  }

  // 准备图表数据
  private prepareChartData(): void {
    if (this.stepRecords.length === 0) {
      this.chartData = []
      this.chartLabels = []
      return
    }

    // 按日期排序
    const sortedRecords = [...this.stepRecords].sort((a, b) =>
    new Date(a.date).getTime() - new Date(b.date).getTime()
    )

    this.chartData = sortedRecords.map(record => record.steps)
    this.chartLabels = sortedRecords.map(record => {
      const date = new Date(record.date)
      return `${date.getMonth() + 1}/${date.getDate()}`
    })
  }

  // 获取活跃天数
  private getActiveDays(): number {
    const activeDays = this.stepRecords.filter(record => record.steps > 0).length
    console.log('[UI渲染] getActiveDays 返回:', activeDays, '(总记录数:', this.stepRecords.length, ')')
    return activeDays
  }

  // 获取目标完成度文本
  private getCompletionRateText(): string {
    if (this.stepRecords.length === 0) {
      console.log('[UI渲染] getCompletionRateText: 没有数据记录')
      return '0%'
    }
    const rate = Math.round((this.avgSteps / 10000) * 100)
    console.log('[UI渲染] getCompletionRateText 返回:', rate + '%', '(avgSteps:', this.avgSteps, ', 记录数:', this.stepRecords.length, ')')
    return `${rate}%`
  }

  // 获取趋势分析结果
  private getTrendAnalysis(): string {
    if (this.stepRecords.length < 2) {
      return '数据不足'}

    const sortedRecords = [...this.stepRecords].sort((a, b) =>
    new Date(a.date).getTime() - new Date(b.date).getTime()
    )

    const recentSteps = sortedRecords.slice(-7).map(r => r.steps)
    const avgRecent = recentSteps.reduce((sum, steps) => sum + steps, 0) / recentSteps.length
    const avgAll = this.avgSteps

    if (avgRecent > avgAll * 1.1) {
      return '上升趋势'
    } else if (avgRecent < avgAll * 0.9) {
      return '下降趋势'
    } else {
      return '平稳状态'
    }
  }

  // 获取趋势颜色
  private getTrendColor(): Color {
    const trend = this.getTrendAnalysis()
    if (trend === '上升趋势') {
      return AppColors.successColor
    } else if (trend === '下降趋势') {
      return AppColors.errorColor
    } else {
      return AppColors.warningColor
    }
  }

  // 格式化日期
  private formatDate(dateString: string): string {
    const date = new Date(dateString)
    return `${date.getMonth() + 1}月${date.getDate()}日`
  }

  // 获取星期
  private getWeekDay(dateString: string): string {
    const date = new Date(dateString)
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return weekDays[date.getDay()]
  }

  // 计算对比分析指标
  private async calculateComparisonMetrics(): Promise<void> {
    console.log('=== 开始计算对比分析指标 ===')
    console.log('当前 stepRecords 数量:', this.stepRecords.length)

    // 计算本周vs上周增长率
    this.calculateWeeklyComparison()
    console.log('本周vs上周增长率:', this.weeklyComparison, '%')

    // 获取本月排名（异步）
    await this.loadMonthlyRanking()
    console.log('本月排名:', this.monthlyRanking)

    // 计算进步速度
    this.calculateProgressSpeed()
    console.log('进步速度:', this.progressSpeed)

    // 计算达标率
    this.calculateAchievementRate()
    console.log('达标率:', this.achievementRate, '%')

    // 计算连续打卡天数
    this.calculateConsecutiveDays()
    console.log('连续打卡天数:', this.consecutiveDays)

    console.log('=== 对比分析指标计算完成 ===')
  }

  // 计算本周vs上周增长率
  private async calculateWeeklyComparison(): Promise<void> {
    console.log('[对比分析] 计算本周vs上周，数据量:', this.stepRecords.length)
    
    // 如果当前数据不足14天，尝试从更长的周期获取数据
    if (this.stepRecords.length < 14) {
      console.log('[对比分析] 当前数据不足14天（仅有', this.stepRecords.length, '天），尝试加载30天数据')
      
      try {
        // 临时保存当前选择的周期
        const originalPeriod = this.selectedPeriod
        
        // 请求30天的数据以获取足够的历史记录
        const response = await this.apiClient.getStepTrend(30)
        
        if (response.code === 1 && response.data) {
          const allRecords = response.data as StepRecord[]
          console.log('[对比分析] 成功获取30天数据，共', allRecords.length, '条记录')
          
          if (allRecords.length >= 14) {
            // 使用30天数据进行计算，但不更新UI显示的stepRecords
            const sortedRecords = [...allRecords].sort((a, b) =>
              new Date(a.date).getTime() - new Date(b.date).getTime()
            )
            
            // 最近7天（本周）
            const thisWeekSteps = sortedRecords.slice(-7).reduce((sum, r) => sum + r.steps, 0)
            // 前7天（上周）
            const lastWeekSteps = sortedRecords.slice(-14, -7).reduce((sum, r) => sum + r.steps, 0)
            
            console.log('[对比分析] 本周步数:', thisWeekSteps, '上周步数:', lastWeekSteps)
            
            if (lastWeekSteps === 0) {
              console.log('[对比分析] 上周步数为0，无法计算增长率')
              this.weeklyComparison = 0
              return
            }
            
            this.weeklyComparison = ((thisWeekSteps - lastWeekSteps) / lastWeekSteps) * 100
            console.log('[对比分析] 增长率:', this.weeklyComparison, '%')
            return
          } else {
            console.log('[对比分析] 即使加载30天数据也不足14天（仅有', allRecords.length, '天）')
          }
        }
      } catch (error) {
        console.error('[对比分析] 加载30天数据失败:', error)
      }
      
      // 如果获取失败或数据仍不足，显示数据不足
      console.log('[对比分析] 显示数据不足')
      this.weeklyComparison = 0
      return
    }

    const sortedRecords = [...this.stepRecords].sort((a, b) =>
    new Date(a.date).getTime() - new Date(b.date).getTime()
    )

    // 最近7天（本周）
    const thisWeekSteps = sortedRecords.slice(-7).reduce((sum, r) => sum + r.steps, 0)
    // 前7天（上周）
    const lastWeekSteps = sortedRecords.slice(-14, -7).reduce((sum, r) => sum + r.steps, 0)

    console.log('[对比分析] 本周步数:', thisWeekSteps, '上周步数:', lastWeekSteps)

    if (lastWeekSteps === 0) {
      console.log('[对比分析] 上周步数为0，无法计算增长率')
      this.weeklyComparison = 0
      return
    }

    this.weeklyComparison = ((thisWeekSteps - lastWeekSteps) / lastWeekSteps) * 100
    console.log('[对比分析] 增长率:', this.weeklyComparison, '%')
  }

  // 获取本周vs上周增长率文本
  private getWeeklyComparisonText(): string {
    const result = this.stepRecords.length < 14 ? '数据不足' : (() => {
      const sign = this.weeklyComparison >= 0 ? '+' : ''
      return `${sign}${Math.round(this.weeklyComparison)}%`
    })()
    console.log('[UI渲染] getWeeklyComparisonText 返回:', result)
    return result
  }

  // 获取本周vs上周增长率颜色
  private getWeeklyComparisonColor(): Color {
    if (this.stepRecords.length < 14) {
      return AppColors.textSecondary
    }

    if (this.weeklyComparison > 0) {
      return AppColors.successColor // 绿色
    } else if (this.weeklyComparison < 0) {
      return AppColors.errorColor // 红色
    } else {
      return AppColors.warningColor // 黄色
    }
  }

  // 加载本月排名
  private async loadMonthlyRanking(): Promise<void> {
    try {
      // 调用后端API获取真实排名
      const response = await this.apiClient.getUserRanking('monthly')

      if (response.code === 1 && response.data) {
        const rankingData = response.data as RankingItem
        this.monthlyRanking = rankingData.rank || 0
        console.log('本月排名:', this.monthlyRanking)
      } else {
        // 检查是否是认证失败
        if (response.code === 401 || response.message?.includes('Authentication')) {
          console.warn('获取排名时认证失败')
          // 不在这里跳转，由loadStepStatistics统一处理
        }
        
        // 未上榜或请求失败
        this.monthlyRanking = 0
        console.log('本月未上榜')
      }
    } catch (error) {
      console.error('获取月度排名失败:', error)
      
      // 检查是否是认证错误
      const errorMessage = error instanceof Error ? error.message : String(error)
      if (errorMessage.includes('401') || errorMessage.includes('Authentication')) {
        console.warn('获取排名时认证异常')
        // 不在这里跳转，由loadStepStatistics统一处理
      }
      
      this.monthlyRanking = 0
    }
  }

  // 获取本月排名文本
  private getMonthlyRankingText(): string {
    const result = this.monthlyRanking > 0 ? `第${this.monthlyRanking}名` : '未上榜'
    console.log('[UI渲染] getMonthlyRankingText 返回:', result, '(monthlyRanking=', this.monthlyRanking, ')')
    return result
  }

  // 计算进步速度
  private calculateProgressSpeed(): void {
    console.log('[对比分析] 计算进步速度，数据量:', this.stepRecords.length)
    if (this.stepRecords.length < 7) {
      console.log('[对比分析] 数据不足7天，无法计算进步速度')
      this.progressSpeed = '数据不足'
      return
    }

    const sortedRecords = [...this.stepRecords].sort((a, b) =>
    new Date(a.date).getTime() - new Date(b.date).getTime()
    )

    // 计算近7天的趋势
    const recentSteps = sortedRecords.slice(-7).map(r => r.steps)
    const firstHalf = recentSteps.slice(0, 3).reduce((sum, s) => sum + s, 0) / 3
    const secondHalf = recentSteps.slice(-4).reduce((sum, s) => sum + s, 0) / 4

    console.log('[对比分析] 前3天平均:', firstHalf, '后4天平均:', secondHalf)

    if (secondHalf > firstHalf * 1.2) {
      this.progressSpeed = '快速提升'
    } else if (secondHalf > firstHalf * 1.05) {
      this.progressSpeed = '稳定提升'
    } else if (secondHalf < firstHalf * 0.8) {
      this.progressSpeed = '有所下降'
    } else {
      this.progressSpeed = '保持平稳'
    }

    console.log('[对比分析] 进步速度:', this.progressSpeed)
  }

  // 获取进步速度文本
  private getProgressSpeedText(): string {
    const result = this.progressSpeed || '数据不足'
    console.log('[UI渲染] getProgressSpeedText 返回:', result)
    return result
  }

  // 获取进步速度颜色
  private getProgressSpeedColor(): Color {
    const speed = this.getProgressSpeedText()
    if (speed === '快速提升' || speed === '稳定提升') {
      return AppColors.successColor
    } else if (speed === '有所下降') {
      return AppColors.errorColor
    } else {
      return AppColors.warningColor
    }
  }

  // 计算达标率
  private calculateAchievementRate(): void {
    console.log('[对比分析] 计算达标率，数据量:', this.stepRecords.length)
    if (this.stepRecords.length === 0) {
      console.log('[对比分析] 没有数据，达标率为0')
      this.achievementRate = 0
      return
    }

    // 目标：每天10000步
    const targetSteps = 10000
    const achievedDays = this.stepRecords.filter(record => record.steps >= targetSteps).length
    this.achievementRate = Math.round((achievedDays / this.stepRecords.length) * 100)

    console.log('[对比分析] 达标天数:', achievedDays, '总天数:', this.stepRecords.length, '达标率:', this.achievementRate, '%')
  }

  // 获取达标率
  private getAchievementRate(): number {
    console.log('[UI渲染] getAchievementRate 返回:', this.achievementRate)
    return this.achievementRate
  }

  // 计算连续打卡天数
  private calculateConsecutiveDays(): void {
    console.log('[对比分析] 计算连续打卡天数，数据量:', this.stepRecords.length)
    if (this.stepRecords.length === 0) {
      this.consecutiveDays = 0
      return
    }

    // 按日期降序排序
    const sortedRecords = [...this.stepRecords]
      .filter(r => r.steps > 0) // 只统计有步数的记录
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())

    if (sortedRecords.length === 0) {
      this.consecutiveDays = 0
      return
    }

    // 检查今天是否有记录
    const today = new Date().toISOString().split('T')[0]
    const hasToday = sortedRecords.some(r => r.date === today)
    
    if (!hasToday) {
      // 如果今天没有记录，从昨天开始计算
      const yesterday = new Date()
      yesterday.setDate(yesterday.getDate() - 1)
      const yesterdayStr = yesterday.toISOString().split('T')[0]
      
      if (sortedRecords[0].date !== yesterdayStr) {
        this.consecutiveDays = 0
        return
      }
    }

    // 计算连续天数
    let consecutive = 1
    for (let i = 0; i < sortedRecords.length - 1; i++) {
      const currentDate = new Date(sortedRecords[i].date)
      const nextDate = new Date(sortedRecords[i + 1].date)
      
      const diffDays = Math.floor((currentDate.getTime() - nextDate.getTime()) / (1000 * 60 * 60 * 24))
      
      if (diffDays === 1) {
        consecutive++
      } else {
        break
      }
    }

    this.consecutiveDays = consecutive
    console.log('[对比分析] 连续打卡天数:', this.consecutiveDays)
  }

  // 获取连续打卡天数
  private getConsecutiveDays(): number {
    return this.consecutiveDays
  }
}