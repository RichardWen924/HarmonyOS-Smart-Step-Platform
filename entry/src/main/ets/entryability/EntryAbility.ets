import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit'
import window from '@ohos.window'
import StateStore from '../services/StateStore'
import { BusinessError } from '@ohos.base'

/**
 * 应用主能力
 */
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('EntryAbility onCreate')
    
    // 初始化StateStore
    this.initializeStateStore()
  }

  onDestroy(): void {
    console.info('EntryAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('EntryAbility onWindowStageCreate')

    // 设置主窗口
    windowStage.loadContent('pages/LoginPage', (err: BusinessError) => {
      if (err) {
        console.error('Failed to load the content. Cause: ' + JSON.stringify(err))
        return
      }
      console.info('Succeeded in loading the content.')
    })
  }

  onWindowStageDestroy(): void {
    console.info('EntryAbility onWindowStageDestroy')
  }

  onForeground(): void {
    console.info('EntryAbility onForeground')
  }

  onBackground(): void {
    console.info('EntryAbility onBackground')
  }

  // 初始化StateStore
  private async initializeStateStore(): Promise<void> {
    try {
      const success = await StateStore.initialize(this.context)
      if (success) {
        console.info('StateStore initialized successfully')
      } else {
        console.error('Failed to initialize StateStore')
      }
    } catch (error) {
      console.error('Error initializing StateStore:', error)
    }
  }
}