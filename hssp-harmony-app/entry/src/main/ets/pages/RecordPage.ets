import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import ApiClient from '../services/ApiClient'
import { ExchangeRecord } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons
} from '../config/DesignSystem'
import AppShadows from '../config/AppShadows'

@Component
export struct RecordPage {
  @State exchangeRecords: ExchangeRecord[] = []
  @State selectedFilter: string = 'all' // all, points, steps
  @State isLoading: boolean = true
  
  private apiClient = ApiClient.getInstance()

  aboutToAppear() {
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
      Text('兑换记录')
        .fontSize(AppFonts.fontSize2Xl)
        .fontColor(AppColors.titleColor)
        .fontWeight(AppFonts.fontWeightBold)
      
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
        Text(record.type === 'points' ? '🔄' : '👣')
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor(record.type === 'points' ? AppColors.successLight : AppColors.primaryLight)
      .borderRadius(AppBorderRadius.radiusFull)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: AppSpacing.spaceLg })

      // 内容
      Column() {
        Text(record.type === 'points' ? '积分兑换' : '步数记录')
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
        Text(record.type === 'points' ? `+${record.points}` : `${record.steps}`)
          .fontSize(AppFonts.fontSizeBase)
          .fontColor(record.type === 'points' ? AppColors.successColor : AppColors.primaryColor)
          .fontWeight(AppFonts.fontWeightBold)

        Text(record.type === 'points' ? '积分' : '步')
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

  private async loadExchangeRecords(): Promise<void> {
    this.isLoading = true

    try {
      const response = await this.apiClient.getAllExchangeRecords()
      if (response.code === 1) {
        this.exchangeRecords = response.data
      }
    } catch (error) {
      // 模拟数据
      await this.delay(500)
      const mockRecords: ExchangeRecord[] = [
        {
          id: 1,
          productId: 1,
          productName: '运动手环',
          points: 5000,
          status: 1,
          exchangeTime: new Date(Date.now() - 86400000 * 5).toISOString(),
          type: 'points',
          steps: 0,
          description: '已发货'
        } as ExchangeRecord,
        {
          id: 2,
          productId: 3,
          productName: '运动毛巾',
          points: 800,
          status: 2,
          exchangeTime: new Date(Date.now() - 86400000 * 10).toISOString(),
          type: 'points',
          steps: 0,
          description: '已完成'
        } as ExchangeRecord,
        {
          id: 3,
          productId: 0,
          productName: '',
          points: 0,
          status: 1,
          exchangeTime: new Date(Date.now() - 86400000 * 2).toISOString(),
          type: 'steps',
          steps: 5000,
          description: '步数记录'
        } as ExchangeRecord
      ]

      // 按时间排序
      this.exchangeRecords = mockRecords.sort((a, b) =>
        new Date(b.exchangeTime || '').getTime() - new Date(a.exchangeTime || '').getTime()
      )
    }

    this.isLoading = false
  }

  private getFilteredRecords(): ExchangeRecord[] {
    if (this.selectedFilter === 'all') {
      return this.exchangeRecords
    }
    return this.exchangeRecords.filter(record => record.type === this.selectedFilter)
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