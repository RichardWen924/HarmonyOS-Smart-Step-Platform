import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import StateStore from '../services/StateStore'
import ApiClient from '../services/ApiClient'
import { Product, UserInfo, ExtendedProduct } from '../types/common'
import {
  AppColors,
  AppFonts,
  AppSpacing,
  AppBorderRadius,
  AppIcons,
  AppShadows
} from '../config/DesignSystem'

/**
 * 积分商城页面
 */
@Entry
@Component
export struct MallPage {
  @State products: ExtendedProduct[] = []
  @State userInfo: UserInfo | null = null
  @State isLoading: boolean = true
  @State isRefreshing: boolean = false

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
      // 用户积分信息
      this.buildPointsInfo()

      // 商品列表
      this.buildProductList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgColor)
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

        Blank()

        // 刷新按钮
        Button(this.isRefreshing ? '刷新中...' : `${AppIcons.refresh} 刷新`)
          .fontSize(AppFonts.fontSizeBase)
          .backgroundColor(AppColors.primaryColor)
          .fontColor(Color.White)
          .borderRadius(AppBorderRadius.radiusFull)
          .padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg })
          .enabled(!this.isRefreshing)
          .onClick(() => {
            this.refreshProducts()
          })
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
          ForEach(this.products, (product: ExtendedProduct, index: number) => {
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
              .id(`stock-${product.id}`)
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

  // 刷新商品列表
  private async refreshProducts(): Promise<void> {
    console.log('=== MallPage: 开始刷新商品列表 ===')
    this.isRefreshing = true
    await Promise.all([this.loadProducts(), this.loadUserInfo()])
    this.isRefreshing = false
    promptAction.showToast({
      message: '刷新成功',
      duration: 1500
    })
    console.log('=== MallPage: 商品刷新完成 ===')
  }

  // 加载商品列表
  private async loadProducts(): Promise<void> {
    try {
      console.log('=== MallPage: 开始加载商品列表 ===')
      this.isLoading = true
      
      // 从后端API获取商品数据
      const response = await this.apiClient.getProducts()
      
      console.log('MallPage: API响应 - code:', response.code)
      console.log('MallPage: API响应 - message:', response.message)
      console.log('MallPage: API响应 - data:', response.data ? response.data.length : 'null', '个商品')
      
      if (response.code === 1 && response.data) {
        this.products = response.data as ExtendedProduct[]
        console.log('MallPage: 成功加载', this.products.length, '个商品')
        if (this.products.length > 0) {
          console.log('MallPage: 第一个商品:', JSON.stringify(this.products[0]))
        }
      } else {
        // API调用失败时显示空状态
        console.warn('MallPage: API返回失败 - code:', response.code, 'message:', response.message)
        this.products = []
        promptAction.showToast({
          message: response.message || '获取商品列表失败，请稍后重试',
          duration: 2000
        })
      }
      
      this.isLoading = false
      console.log('=== MallPage: 商品加载完成 ===')
    } catch (error) {
      console.error('MallPage: 加载商品失败:', error)
      this.products = []
      this.isLoading = false
      const errorMessage = error instanceof Error ? error.message : String(error)
      promptAction.showToast({
        message: `网络连接失败: ${errorMessage.includes('Authentication') ? '请重新登录' : '请检查网络设置'}`,
        duration: 2500
      })
    }
  }

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      // 从后端获取最新的用户信息
      const response = await this.apiClient.getUserInfo()
      if (response.code === 1 && response.data) {
        this.userInfo = response.data
        // 同步到本地存储
        await this.stateStore.saveUserInfo(response.data)
      }
    } catch (error) {
      console.error('Failed to load user info:', error)
      // 如果API调用失败，尝试从本地存储获取
      try {
        this.userInfo = await this.stateStore.getUserInfo()
      } catch (localError) {
        console.error('Failed to get local user info:', localError)
      }
    }
  }

  // 兑换商品
  private async exchangeProduct(product: ExtendedProduct): Promise<void> {
    console.log('=== MallPage: 开始兑换商品 ===')
    console.log('商品信息:', product.name, 'ID:', product.id, '所需积分:', product.pointsRequired)
    
    if (!this.userInfo) {
      console.warn('MallPage: 用户未登录')
      promptAction.showToast({
        message: '请先登录',
        duration: 2000
      })
      return
    }

    console.log('MallPage: 当前用户积分:', this.userInfo.totalPoints)
    console.log('MallPage: 用户ID:', this.userInfo.id)

    if (this.userInfo.totalPoints < product.pointsRequired) {
      console.warn('MallPage: 积分不足')
      promptAction.showToast({
        message: `积分不足，当前积分: ${this.userInfo.totalPoints}，需要: ${product.pointsRequired}`,
        duration: 2500
      })
      return
    }

    if (product.stock <= 0) {
      console.warn('MallPage: 商品库存为0')
      promptAction.showToast({
        message: '商品已售罄',
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
        console.log('MallPage: 用户确认兑换，调用API...')
        try {
          // 调用API进行兑换
          console.log('MallPage: 请求参数 - goodsId:', product.id)
          const exchangeResult = await this.apiClient.exchangeProduct(product.id, product.pointsRequired)
          
          console.log('MallPage: API响应 - code:', exchangeResult.code)
          console.log('MallPage: API响应 - message:', exchangeResult.message)
          
          if (exchangeResult.code === 1) {
            // 兑换成功
            console.log('MallPage: 兑换成功！')
            promptAction.showToast({
              message: `✅ 兑换成功！${product.name} 已加入您的账户`,
              duration: 3000
            })
            
            // 更新用户积分和商品库存
            console.log('MallPage: 刷新用户信息和商品列表...')
            await this.loadUserInfo()
            await this.loadProducts()
          } else {
            console.error('MallPage: 兑换失败 -', exchangeResult.message)
            promptAction.showToast({
              message: exchangeResult.message || '兑换失败',
              duration: 2000
            })
          }
        } catch (error) {
          console.error('MallPage: 兑换异常:', error)
          const errorMessage = error instanceof Error ? error.message : String(error)
          promptAction.showToast({
            message: `兑换失败: ${errorMessage.includes('Authentication') ? '请重新登录' : errorMessage}`,
            duration: 2500
          })
        }
      } else {
        console.log('MallPage: 用户取消兑换')
      }
    })
  }
}