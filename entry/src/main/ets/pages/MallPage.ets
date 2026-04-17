import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import StateStore from '../services/StateStore'
import ApiClient from '../services/ApiClient'
import { Product, UserInfo } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppShadows
} from '../config/DesignSystem'


// 扩展Product接口以包含type字段
interface ExtendedProduct extends Product {
  type: string; // 'virtual' | 'physical'
  pointsRequired: number;
}

/**
 * 积分商城页面
 */
@Entry
@Component
export struct MallPage {
  @State products: ExtendedProduct[] = []
  @State userInfo: UserInfo | null = null
  @State selectedFilter: string = 'all'
  @State isLoading: boolean = true

  private stateStore = StateStore
  private apiClient = ApiClient

  aboutToAppear() {
    this.loadProducts()
    this.loadUserInfo()
  }

  onPageShow() {
    // 每次页面显示时刷新数据
    this.loadUserInfo()
  }

  build() {
    Column() {
      // 顶部标题栏 - 优化设计
      this.buildHeader()

      // 用户积分信息
      this.buildPointsInfo()

      // 商品列表
      this.buildProductList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
  }

  // 构建顶部标题栏 - 优化设计
  @Builder buildHeader() {
    Row() {
      Text(`${AppIcons.mall} 积分商城`)
        .fontSize(AppFonts.fontSize2Xl)
        .fontWeight(AppFonts.fontWeightBold)
        .fontColor(AppColors.titleColor)

      Blank()

      // 筛选按钮 - 优化视觉
      this.buildFilterButton()
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

  // 构建用户积分信息 - 优化视觉
  @Builder buildPointsInfo() {
    Column() {
      Row() {
        Text(AppIcons.points)
          .fontSize(AppFonts.fontSize3Xl)
          .margin({ right: AppSpacing.spaceSm })

        Column() {
          Text('可用积分')
            .fontSize(AppFonts.fontSizeBase)
            .fontColor(AppColors.textSecondary)

          Text(this.userInfo?.totalPoints?.toLocaleString() || '0')
            .fontSize(AppFonts.fontSize4Xl)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.warningColor)
        }
      }

      Row() {
        Text('💡')
          .fontSize(AppFonts.fontSizeLg)
          .margin({ right: AppSpacing.spaceXs })

        Text('每日步数可兑换积分')
          .fontSize(AppFonts.fontSizeSm)
          .fontColor(AppColors.textSecondary)
      }
      .margin({ top: AppSpacing.spaceSm })
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
    .margin({ top: AppSpacing.spaceLg, left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
  }

  // 构建筛选按钮 - 优化视觉
  @Builder buildFilterButton() {
    Row() {
      ForEach(['all', 'virtual', 'physical'], (filter: string) => {
        Button(this.getFilterLabel(filter))
          .fontSize(AppFonts.fontSizeSm)
          .backgroundColor(this.selectedFilter === filter ? AppColors.primaryColor : AppColors.bgColor)
          .fontColor(this.selectedFilter === filter ? Color.White : AppColors.textColor)
          .borderRadius(AppBorderRadius.radiusFull)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .border({
            width: this.selectedFilter === filter ? 0 : 1,
            color: AppColors.borderColor
          })
          .onClick(() => {
            this.selectedFilter = filter
          })
      })
    }
  }

  // 构建商品列表 - 优化视觉层次
  @Builder buildProductList() {
    Scroll() {
      Column() {
        if (this.isLoading) {
          // 加载状态
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(AppColors.primaryColor)

            Text('正在加载商品...')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.textSecondary)
              .margin({ top: AppSpacing.spaceLg })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.products.length === 0) {
          // 空状态
          Column() {
            Text('📦')
              .fontSize(AppFonts.fontSize6Xl)
              .margin({ bottom: AppSpacing.spaceLg })

            Text('暂无商品')
              .fontSize(AppFonts.fontSizeLg)
              .fontColor(AppColors.textSecondary)
              .fontWeight(AppFonts.fontWeightMedium)

            Text('商品正在上架中，敬请期待')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(AppColors.textSecondary)
              .margin({ top: AppSpacing.spaceSm })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 商品列表
          ForEach(this.getFilteredProducts(), (product: ExtendedProduct, index: number) => {
            this.buildProductCard(product, index)
          })
        }
      }
      .width('100%')
      .padding(AppSpacing.spaceLg)
    }
    .layoutWeight(1)
    .margin({ top: AppSpacing.spaceLg })
  }

  // 构建商品卡片 - 优化视觉层次
  @Builder buildProductCard(product: ExtendedProduct, index: number) {
    Column() {
      // 商品图片和基本信息
      Row() {
        // 商品图片区域
        Column() {
          Stack() {
            // 使用背景色代替Rectangle
            Column() {}
              .width(80)
              .height(80)
              .backgroundColor(product.type === 'virtual' ? AppColors.primaryLight : AppColors.successLight)
              .borderRadius(AppBorderRadius.radiusBase)

            Text(product.type === 'virtual' ? '🎁' : '📦')
              .fontSize(AppFonts.fontSize3Xl)
          }
        }

        // 商品信息
        Column() {
          Text(product.name)
            .fontSize(AppFonts.fontSizeLg)
            .fontWeight(AppFonts.fontWeightBold)
            .fontColor(AppColors.titleColor)
            .margin({ bottom: AppSpacing.spaceXs })

          Text(product.description)
            .fontSize(AppFonts.fontSizeSm)
            .fontColor(AppColors.textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: AppSpacing.spaceSm })

          Row() {
            Text('🎯')
              .fontSize(AppFonts.fontSizeSm)
              .margin({ right: AppSpacing.spaceXs })

            Text(product.pointsRequired.toLocaleString() + ' 积分')
              .fontSize(AppFonts.fontSizeBase)
              .fontColor(AppColors.warningColor)
              .fontWeight(AppFonts.fontWeightMedium)

            Blank()

            Text(product.stock > 0 ? `库存: ${product.stock}` : '已售罄')
              .fontSize(AppFonts.fontSizeSm)
              .fontColor(product.stock > 0 ? AppColors.successColor : AppColors.errorColor)
          }
        }
        .layoutWeight(1)
        .margin({ left: AppSpacing.spaceLg })
      }

      // 兑换按钮 - 优化交互
      Button(product.stock > 0 ? '立即兑换' : '已售罄')
        .width('100%')
        .height(48)
        .fontSize(AppFonts.fontSizeBase)
        .fontWeight(AppFonts.fontWeightMedium)
        .fontColor(Color.White)
        .backgroundColor(product.stock > 0 ? AppColors.primaryColor : AppColors.textDisabled)
        .borderRadius(AppBorderRadius.radiusBase)
        .margin({ top: AppSpacing.spaceLg })
        .enabled(product.stock > 0)
        .onClick(() => {
          this.exchangeProduct(product)
        })
    }
    .width('100%')
    .padding(AppSpacing.space3Xl)
    .backgroundColor(AppColors.bgCard)
    .borderRadius(AppBorderRadius.radiusLg)
    .shadow(AppShadows.shadowCard)
    .margin({ bottom: AppSpacing.spaceLg })
  }

  // 获取筛选后的商品列表
  private getFilteredProducts(): ExtendedProduct[] {
    if (this.selectedFilter === 'all') {
      return this.products
    }
    return this.products.filter(product => product.type === this.selectedFilter)
  }

  // 获取筛选标签
  private getFilterLabel(filter: string): string {
    const labels: Record<string, string> = {
      'all': '全部',
      'virtual': '虚拟商品',
      'physical': '实物商品'
    }
    return labels[filter] || filter
  }

  // 加载商品列表
  private async loadProducts(): Promise<void> {
    try {
      this.isLoading = true
      
      // 从后端API获取商品数据
      const response = await this.apiClient.getProducts()
      
      if (response.code === 1 && response.data) {
        this.products = response.data as ExtendedProduct[]
      } else {
        // API调用失败时显示空状态
        this.products = []
        promptAction.showToast({
          message: '获取商品列表失败，请稍后重试',
          duration: 2000
        })
      }
      
      this.isLoading = false
    } catch (error) {
      console.error('Failed to load products:', error)
      this.products = []
      this.isLoading = false
      promptAction.showToast({
        message: '网络连接失败，请检查网络设置',
        duration: 2000
      })
    }
  }

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      const userInfo = await this.stateStore.getUserInfo()
      this.userInfo = userInfo
    } catch (error) {
      console.error('Failed to load user info:', error)
    }
  }

  // 兑换商品
  private async exchangeProduct(product: ExtendedProduct): Promise<void> {
    if (!this.userInfo || this.userInfo.totalPoints < product.pointsRequired) {
      promptAction.showToast({
        message: '积分不足，无法兑换',
        duration: 2000
      })
      return
    }

    // 显示确认对话框
    promptAction.showDialog({
      title: '确认兑换',
      message: `确定要兑换【${product.name}】吗？\n需要消耗 ${product.pointsRequired.toLocaleString()} 积分`,
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '确定兑换',
          color: '#007AFF'
        }
      ]
    }).then(async (result) => {
      if (result.index === 1) {
        try {
          // 调用API进行兑换
          const exchangeResult = await this.apiClient.exchangeProduct(product.id, product.pointsRequired)
          
          if (exchangeResult.code === 1) {
            // 兑换成功
            promptAction.showToast({
              message: `兑换成功！${product.name} 已加入您的账户`,
              duration: 3000
            })
            
            // 更新用户积分和商品库存
            await this.loadUserInfo()
            await this.loadProducts()
          } else {
            promptAction.showToast({
              message: exchangeResult.message || '兑换失败',
              duration: 2000
            })
          }
        } catch (error) {
          console.error('Exchange product error:', error)
          promptAction.showToast({
            message: '兑换失败，请检查网络连接',
            duration: 2000
          })
        }
      }
    })
  }
}