import { RecordPage } from './RecordPage'

/**
 * 记录Tab组件
 * 用于在MainPage中嵌入显示
 */
@Component
export struct RecordTab {
  build() {
    RecordPage()
      .width('100%')
      .height('100%')
  }
}
