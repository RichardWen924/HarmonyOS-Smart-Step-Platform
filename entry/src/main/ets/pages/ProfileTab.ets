import { ProfilePage } from './ProfilePage'

/**
 * 我的Tab组件
 * 用于在MainPage中嵌入显示
 */
@Component
export struct ProfileTab {
  build() {
    ProfilePage()
      .width('100%')
      .height('100%')
  }
}
