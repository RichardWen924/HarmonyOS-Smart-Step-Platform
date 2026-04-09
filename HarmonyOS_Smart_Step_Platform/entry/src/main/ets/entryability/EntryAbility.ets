import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import StateStore from '../services/StateStore'
import StepCounterService from '../services/StepCounterService'

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private stateStore = StateStore
  private stepService = StepCounterService

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      const errorObj = err as Error | Record<string, string | number | boolean>
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(errorObj));
    }
    
    // 初始化状态存储
    await this.stateStore.initialize(this.context)
    
    // 加载已保存的token到API客户端
    const savedToken = this.stateStore.getToken()
    if (savedToken) {
      const ApiClient = await import('../services/ApiClient')
      ApiClient.default.setToken(savedToken)
    }
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    // 停止步数监控
    this.stepService.stopStepMonitoring()
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 根据登录状态决定初始页面
    const initialPage = this.stateStore.isLoggedIn ? 'pages/MainPage' : 'pages/LoginPage'

    windowStage.loadContent(initialPage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    // 应用回到前台时恢复步数监控
    if (this.stateStore.isLoggedIn) {
      this.stepService.startStepMonitoring((steps: number) => {
        // 保存步数数据
      const lastUpdate = new Date().toISOString()
      this.stateStore.saveStepData(steps, lastUpdate)
      })
    }
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    // 应用进入后台时停止步数监控以节省电量
    this.stepService.stopStepMonitoring()
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}