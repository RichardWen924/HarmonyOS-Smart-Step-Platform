import { TrendPage } from './TrendPage'

/**
 * 趋势Tab组件
 * 用于在MainPage中嵌入显示
 */
@Component
export struct TrendTab {
  build() {
    TrendPage()
      .width('100%')
      .height('100%')
  }
}
