import { RankingPage } from './RankingPage'

/**
 * 排行榜Tab组件
 * 用于在MainPage中嵌入显示
 */
@Component
export struct RankingTab {
  build() {
    RankingPage()
      .width('100%')
      .height('100%')
  }
}
