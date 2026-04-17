import { MallPage } from './MallPage'

/**
 * 商城Tab组件
 * 用于在MainPage中嵌入显示
 */
@Component
export struct MallTab {
  build() {
    MallPage()
      .width('100%')
      .height('100%')
  }
}