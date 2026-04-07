import promptAction from '@ohos.promptAction'
import ApiClient from '../services/ApiClient'
import { RankingItem, PageData, UserInfo } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import AppShadows from '../config/AppShadows'

enum PeriodType {
  DAY = 'daily',
  WEEK = 'weekly',
  MONTH = 'monthly'
}

@Entry
@Component
struct RankingPage {
  @State currentPeriod: PeriodType = PeriodType.DAY
  @State rankings: RankingItem[] = []
  @State userRank: number = 0
  @State userSteps: number = 0
  @State currentPage: number = 1
  @State total: number = 0
  @State isLoading: boolean = false
  
  private apiClient = ApiClient
  private pageSize: number = 10

  aboutToAppear() {
    this.loadRankings()
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

  // 加载排行榜数据
  private async loadRankings(): Promise<void> {
    this.isLoading = true
    
    try {
      const response = await this.apiClient.getRankingList(
        this.currentPeriod
      )
      
      if (response.code === 1) {
        // getRankingList返回的是RankingItem[]，不是PageData<UserInfo>
        this.rankings = response.data
        this.total = response.data.length
        
        // 模拟用户排名（实际应从接口返回）
        this.userRank = Math.floor(Math.random() * 100) + 1
        this.userSteps = Math.floor(Math.random() * 20000) + 5000
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
      
      if (response.code === 1) {
        // getRankingList返回的是RankingItem[]，不是PageData<UserInfo>
        const newRankings = response.data.map((item: RankingItem, index: number) => {
          return {
            rank: (this.currentPage - 1) * this.pageSize + index + 1,
            userId: item.userId,
            username: item.username,
            nickname: item.nickname,
            totalSteps: item.totalSteps,
            avatar: item.avatar
          } as RankingItem
        })
        this.rankings = this.rankings.concat(newRankings)
      }
    } catch (error) {
      console.error('Failed to load more rankings:', error)
    } finally {
      this.isLoading = false
    }
  }
}