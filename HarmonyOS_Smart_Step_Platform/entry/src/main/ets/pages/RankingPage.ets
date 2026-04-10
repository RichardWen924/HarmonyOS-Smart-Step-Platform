import promptAction from '@ohos.promptAction'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { RankingItem, PageData, UserInfo } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import AppShadows from '../config/AppShadows'

// 排行榜响应数据类型
interface RankingResponseData {
  list?: RankingItem[]
  total?: number
}

enum PeriodType {
  DAY = 'daily',
  WEEK = 'weekly',
  MONTH = 'monthly'
}

@Entry
@Component
export struct RankingPage {
  @State currentPeriod: PeriodType = PeriodType.DAY
  @State rankings: RankingItem[] = []
  @State userRank: number = 0
  @State userSteps: number = 0
  @State currentPage: number = 1
  @State total: number = 0
  @State isLoading: boolean = false

  private apiClient = ApiClient
  private stateStore = StateStore
  private pageSize: number = 100

  async aboutToAppear() {
    console.log('RankingPage: aboutToAppear called')
    // 确保ApiClient有正确的Token
    await this.syncTokenToApiClient()
    
    // 在加载排行榜之前，先上传当前的步数数据到服务器
    await this.uploadCurrentSteps()
    
    // 然后加载排行榜数据
    await this.loadRankings()
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()

      // 周期选择
      this.buildPeriodSelector()

      // 我的排名
      this.buildMyRanking()

      // 排行榜列表
      this.buildRankingList()

      // 加载更多
      if (this.rankings.length < this.total) {
        this.buildLoadMore()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  // 构建头部
  @Builder buildHeader() {
    Row() {
      Text(`${AppIcons.ranking} 排行榜`)
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)

      Blank()
    }
    .width('100%')
    .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
  }

  // 构建周期选择器
  @Builder buildPeriodSelector() {
    Column() {
      Text('选择周期')
        .fontSize(AppFonts.fontSizeBase)
        .fontColor(AppColors.textColor)
        .fontWeight(AppFonts.fontWeightMedium)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppSpacing.spaceLg })

      Row() {
        this.buildPeriodButton('日榜', PeriodType.DAY)
        this.buildPeriodButton('周榜', PeriodType.WEEK)
        this.buildPeriodButton('月榜', PeriodType.MONTH)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建周期按钮
  @Builder buildPeriodButton(label: string, period: PeriodType) {
    Button(label)
      .fontSize(AppFonts.fontSizeBase)
      .backgroundColor(this.currentPeriod === period ? AppColors.primaryColor : AppColors.bgColor)
      .fontColor(this.currentPeriod === period ? Color.White : AppColors.textColor)
      .borderRadius(AppBorderRadius.radius2Xl)
      .padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl })
      .enabled(!this.isLoading)
      .onClick(() => {
        if (this.currentPeriod !== period) {
          this.currentPeriod = period
          this.currentPage = 1
          this.loadRankings()
        }
      })
  }

  // 构建我的排名
  @Builder buildMyRanking() {
    Column() {
      Row() {
        Column() {
          Text('我的排名')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)

          Text(this.userRank > 0 ? `第${this.userRank}名` : '未上榜')
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.primaryColor)
            .margin({ top: AppSpacing.spaceXs })
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)

        Column() {
          Text(`${this.getPeriodName()}步数`)
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)

          Text(this.userSteps.toLocaleString())
            .fontSize(AppFonts.fontSize2Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.successColor)
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
    .shadow(AppShadows.shadowBase)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 构建排行榜列表
  @Builder buildRankingList() {
    Column() {
      if (this.isLoading && this.rankings.length === 0) {
        // 加载中
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
      } else if (this.rankings.length === 0) {
        // 空数据
        Column() {
          Text('📭')
            .fontSize(48)
            .margin({ bottom: AppSpacing.spaceLg })

          Text('暂无排名数据')
            .fontSize(AppFonts.fontSizeLg)
            .fontColor(AppColors.textSecondary)
            .fontWeight(AppFonts.fontWeightMedium)
            .margin({ bottom: AppSpacing.spaceSm })

          Text('快去运动争取上榜吧！')
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textDisabled)
        }
        .width('100%')
        .padding(AppSpacing.space5Xl)
      } else {
        // 排行榜列表
        ForEach(this.rankings, (item: RankingItem, index: number) => {
          this.buildRankingItem(item, index)
        })
      }
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
  }

  // 构建排名项
  @Builder buildRankingItem(item: RankingItem, index: number) {
    Row() {
      // 排名
      Column() {
        if (item.rank <= 3) {
          Text(this.getRankMedal(item.rank))
            .fontSize(28)
        } else {
          Column() {
            Text(item.rank.toString())
              .fontSize(AppFonts.fontSizeLg)
              .fontWeight(AppFonts.fontWeightBold)
              .fontColor(AppColors.textSecondary)
          }
          .width(32)
          .height(32)
          .backgroundColor(AppColors.bgColor)
          .borderRadius(AppBorderRadius.radiusFull)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width(40)
      .alignItems(HorizontalAlign.Center)

      // 头像
      Column() {
        Text(AppIcons.profile)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(AppColors.primaryLight)
      .borderRadius(AppBorderRadius.radiusFull)
      .justifyContent(FlexAlign.Center)
      .margin({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })

      // 用户信息
      Column() {
        Text(item.nickname || item.username)
          .fontSize(AppFonts.fontSizeLg)
          .fontWeight(AppFonts.fontWeightMedium)
          .fontColor(AppColors.titleColor)
          .alignSelf(ItemAlign.Start)

        Text(`${item.totalSteps.toLocaleString()} 步`)
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 勋章（前10名）
      if (item.rank <= 10) {
        Text(this.getRankBadge(item.rank))
          .fontSize(20)
      }
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowSm)
    .margin({ bottom: AppSpacing.spaceSm })
  }

  // 构建加载更多
  @Builder buildLoadMore() {
    Button(this.isLoading ? '加载中...' : '加载更多')
      .width('100%')
      .height(48)
      .fontSize(AppFonts.fontSizeBase)
      .backgroundColor(AppColors.bgColor)
      .fontColor(AppColors.textColor)
      .borderRadius(AppBorderRadius.radiusBase)
      .margin({ top: AppSpacing.spaceSm, bottom: AppSpacing.spaceLg })
      .enabled(!this.isLoading)
      .onClick(() => {
        this.loadMore()
      })
  }

  // 查找当前用户在排行榜中的位置
  private findCurrentUserRank(): void {
    const currentUserId = this.stateStore.getUserId()
    if (!currentUserId) {
      console.warn('无法获取当前用户ID')
      return
    }
    
    // 在排行榜列表中查找当前用户
    const currentUserRanking = this.rankings.find(item => item.userId === currentUserId)
    
    if (currentUserRanking) {
      this.userRank = currentUserRanking.rank
      this.userSteps = currentUserRanking.totalSteps
      console.log('找到当前用户排名:', this.userRank, '步数:', this.userSteps)
    } else {
      // 如果当前用户不在当前页的排行榜中，尝试从服务器获取用户步数统计
      this.loadUserStepStatistics()
    }
  }
  
  // 加载当前用户的步数统计
  private async loadUserStepStatistics(): Promise<void> {
    try {
      const response = await this.apiClient.getStepStatistics()
      if (response.code === 1 && response.data) {
        const stats = response.data
        this.userSteps = stats.todaySteps || 0
        this.userRank = 0 // 未上榜
        console.log('用户步数统计:', this.userSteps)
      }
    } catch (error) {
      console.error('Failed to load user step statistics:', error)
      this.userRank = 0
      this.userSteps = 0
    }
  }

  // 获取周期名称
  private getPeriodName(): string {
    switch (this.currentPeriod) {
      case PeriodType.DAY:
        return '今日'
      case PeriodType.WEEK:
        return '本周'
      case PeriodType.MONTH:
        return '本月'
    }
  }

  // 获取奖牌图标
  private getRankMedal(rank: number): string {
    switch (rank) {
      case 1:
        return '🥇'
      case 2:
        return '🥈'
      case 3:
        return '🥉'
      default:
        return ''
    }
  }

  // 获取排名徽章
  private getRankBadge(rank: number): string {
    if (rank <= 3) return '🏆'
    if (rank <= 10) return '🎖️'
    return ''
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('RankingPage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('RankingPage: StateStore中没有找到Token')
    }
  }

  // 上传当前步数到服务器（确保Redis中有最新数据）
  private async uploadCurrentSteps(): Promise<void> {
    try {
      const currentSteps = this.stateStore.todaySteps
      console.log('RankingPage: 准备上传步数:', currentSteps)
      
      if (currentSteps > 0) {
        const response = await this.apiClient.uploadSteps(
          currentSteps,
          new Date().toISOString().split('T')[0]
        )
        
        if (response.code === 1) {
          console.log('RankingPage: 步数上传成功，已更新Redis')
        } else {
          console.warn('RankingPage: 步数上传失败:', response.message)
        }
      } else {
        console.log('RankingPage: 今日步数为0，跳过上传')
      }
    } catch (error) {
      console.error('RankingPage: 上传步数异常:', error)
      // 不阻断排行榜加载，仅记录错误
    }
  }

  // 加载排行榜数据
  private async loadRankings(): Promise<void> {
    this.isLoading = true

    try {
      const response = await this.apiClient.getRankingList(
        this.currentPeriod
      )

      if (response.code === 1 && response.data) {
        // 后端返回的是 PageResult<RankVO>
        const responseData = response.data

        // 检查是否是 PageData 结构（有 list 字段）
        if (responseData && typeof responseData === 'object') {
          const pageData = responseData as RankingResponseData
          if (pageData.list && Array.isArray(pageData.list)) {
            const rankingList = pageData.list

            this.rankings = rankingList.map((item: RankingItem) => ({
              rank: item.rank || 0,
              userId: item.userId || 0,
              username: '', // 后端 RankVO 没有 username 字段
              nickname: item.nickname || '未知用户',
              totalSteps: Math.floor(item.totalSteps || 0),
              avatar: item.avatar || ''
            }) as RankingItem)

            this.total = pageData.total || rankingList.length

            console.log('Rankings loaded:', this.rankings.length, 'items, total:', this.total)
                    
            // 从排行榜列表中查找当前用户的排名
            this.findCurrentUserRank()
          } else if (Array.isArray(responseData)) {
            // 兼容直接返回数组的情况
            const rankingList = responseData as RankingItem[]

            this.rankings = rankingList.map((item: RankingItem) => ({
              rank: item.rank || 0,
              userId: item.userId || 0,
              username: '',
              nickname: item.nickname || '未知用户',
              totalSteps: Math.floor(item.totalSteps || 0),
              avatar: item.avatar || ''
            }) as RankingItem)

            this.total = rankingList.length

            console.log('Rankings loaded (array):', this.rankings.length, 'items')
            
            // 从排行榜列表中查找当前用户的排名
            this.findCurrentUserRank()
          } else {
            console.warn('Invalid ranking data format:', responseData)
            this.rankings = []
            this.total = 0
            this.userRank = 0
            this.userSteps = 0
          }
        }
      }
    } catch (error) {
      console.error('Failed to load rankings:', error)
      promptAction.showToast({
        message: '❌ 加载失败',
        duration: 2000
      })
    } finally {
      this.isLoading = false
    }
  }

  // 加载更多
  private loadMore(): void {
    if (this.isLoading) return

    const nextPage = this.currentPage + 1
    const maxPage = Math.ceil(this.total / this.pageSize)

    if (nextPage > maxPage) {
      promptAction.showToast({
        message: '没有更多数据了',
        duration: 2000
      })
      return
    }

    this.currentPage = nextPage
    this.loadMoreData()
  }

  // 加载更多数据
  private async loadMoreData(): Promise<void> {
    this.isLoading = true

    try {
      const response = await this.apiClient.getRankingList(
        this.currentPeriod
      )

      if (response.code === 1 && response.data) {
        // 后端返回的是 PageResult<RankVO>
        const responseData = response.data

        // 检查是否是 PageData 结构（有 list 字段）
        if (responseData && typeof responseData === 'object') {
          const pageData = responseData as RankingResponseData
          if (pageData.list && Array.isArray(pageData.list)) {
            const rankingList = pageData.list

            const newRankings = rankingList.map((item: RankingItem, index: number) => ({
              rank: (this.currentPage - 1) * this.pageSize + index + 1,
              userId: item.userId || 0,
              username: '',
              nickname: item.nickname || '未知用户',
              totalSteps: Math.floor(item.totalSteps || 0),
              avatar: item.avatar || ''
            }) as RankingItem)

            this.rankings = this.rankings.concat(newRankings)
            this.total = pageData.total || rankingList.length

            console.log('Loaded more rankings:', newRankings.length, 'items')
          }
        }
      }
    } catch (error) {
      console.error('Failed to load more rankings:', error)
    } finally {
      this.isLoading = false
    }
  }
}