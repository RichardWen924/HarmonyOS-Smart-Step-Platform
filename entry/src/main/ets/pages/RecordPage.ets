import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import { ExchangeRecord } from '../types/common'
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
export struct RecordPage {
  @State exchangeRecords: ExchangeRecord[] = []
  @State selectedFilter: string = 'all' // all, points, steps
  @State isLoading: boolean = true

  private apiClient = ApiClient
  private stateStore = StateStore

  aboutToAppear() {
    // 确保ApiClient有正确的Token
    this.syncTokenToApiClient()
    this.loadExchangeRecords()
  }

  build() {
    Column() {
      // 筛选器头部
      this.buildFilterHeader()

      Scroll() {
        Column() {
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
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            Column() {
              ForEach(this.getFilteredRecords(), (record: ExchangeRecord, index: number) => {
                this.buildRecordItem(record, index)
              })
            }
            .width('100%')
            .backgroundColor(AppColors.bgCard)
            .borderRadius(AppBorderRadius.radiusLg)
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

  @Builder buildFilterHeader() {
    Row() {
      Blank()

      Row() {
        Button('全部')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedFilter === 'all' ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedFilter === 'all' ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
          .onClick(() => {
            this.selectedFilter = 'all'
          })

        Button('积分')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedFilter === 'points' ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedFilter === 'points' ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
          .onClick(() => {
            this.selectedFilter = 'points'
          })

        Button('步数')
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedFilter === 'steps' ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedFilter === 'steps' ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radius2Xl)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm })
          .onClick(() => {
            this.selectedFilter = 'steps'
          })
      }
    }
    .width('100%')
    .padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg })
    .backgroundColor(AppColors.bgCard)
    .shadow(AppShadows.shadowSm)
  }

  @Builder buildRecordItem(record: ExchangeRecord, index: number) {
    Row() {
      // 图标
      Column() {
        Text(this.getRecordIcon(record))
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor(this.getRecordIconBg(record))
      .borderRadius(AppBorderRadius.radiusFull)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: AppSpacing.spaceLg })

      // 内容
      Column() {
        Text(this.getRecordTitle(record))
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(AppColors.textColor)
          .fontWeight(AppFonts.fontWeightMedium)
          .alignSelf(ItemAlign.Start)

        Text(this.formatDateTime(record.exchangeTime))
          .fontSize(AppFonts.fontSizeXs)
          .fontColor(AppColors.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ top: AppSpacing.spaceXs })
      }
      .layoutWeight(1)

      // 数值
      Column() {
        Text(this.getRecordValue(record))
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(this.getRecordValueColor(record))
          .fontWeight(AppFonts.fontWeightBold)

        Text(this.getRecordUnit(record))
          .fontSize(AppFonts.fontSizeXs)
          .fontColor(AppColors.textSecondary)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(AppSpacing.spaceLg)
    .backgroundColor(index % 2 === 0 ? AppColors.bgColor : AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusBase)
  }

  // 同步Token到ApiClient
  private async syncTokenToApiClient(): Promise<void> {
    const token = this.stateStore.getToken()
    if (token) {
      await this.apiClient.setToken(token)
      console.log('RecordPage: Token已同步到ApiClient，长度:', token.length)
    } else {
      console.warn('RecordPage: StateStore中没有找到Token')
    }
  }

  private async loadExchangeRecords(): Promise<void> {
    this.isLoading = true

    try {
      // 调用真实API获取兑换记录
      const response = await this.apiClient.getExchangeRecords(1, 50)

      if (response.code === 1 && response.data) {
        const records = response.data as ExchangeRecord[]

        // 按时间排序（最新的在前）
        this.exchangeRecords = records.sort((a, b) =>
        new Date(b.exchangeTime || '').getTime() - new Date(a.exchangeTime || '').getTime()
        )

        console.log('成功加载兑换记录:', this.exchangeRecords.length, '条')
      } else {
        console.error('获取兑换记录失败:', response.message)
        this.exchangeRecords = []
      }
    } catch (error) {
      console.error('Failed to load exchange records:', error)
      // 出错时使用空数组
      this.exchangeRecords = []
    }

    this.isLoading = false
  }

  private getFilteredRecords(): ExchangeRecord[] {
    if (this.selectedFilter === 'all') {
      return this.exchangeRecords
    }
    // 根据类型过滤：points对应points_exchange，steps对应step_record
    if (this.selectedFilter === 'points') {
      return this.exchangeRecords.filter(record =>
      record.type === 'points_exchange' || record.type === 'points'
      )
    } else if (this.selectedFilter === 'steps') {
      return this.exchangeRecords.filter(record =>
      record.type === 'step_record' || record.type === 'steps'
      )
    }
    return this.exchangeRecords
  }

  // 获取记录图标
  private getRecordIcon(record: ExchangeRecord): string {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return '🔄'
    } else {
      return '👣'
    }
  }

  // 获取图标背景色
  private getRecordIconBg(record: ExchangeRecord): ResourceColor {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return AppColors.successLight
    } else {
      return AppColors.primaryLight
    }
  }

  // 获取记录标题
  private getRecordTitle(record: ExchangeRecord): string {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return '积分兑换'
    } else {
      return record.description || '步数记录'
    }
  }

  // 获取记录数值
  private getRecordValue(record: ExchangeRecord): string {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return `+${record.points}`
    } else {
      return `${record.steps}`
    }
  }

  // 获取数值颜色
  private getRecordValueColor(record: ExchangeRecord): ResourceColor {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return AppColors.successColor
    } else {
      return AppColors.primaryColor
    }
  }

  // 获取单位
  private getRecordUnit(record: ExchangeRecord): string {
    if (record.type === 'points_exchange' || record.type === 'points') {
      return '积分'
    } else {
      return '步'
    }
  }

  private formatDateTime(dateTimeStr: string | undefined): string {
    if (!dateTimeStr) return ''
    const date = new Date(dateTimeStr)
    return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}