import ExtensionAbility from '@ohos.app.ability.ExtensionAbility'
import { Want } from '@kit.AbilityKit'

/**
 * 应用备份能力
 */
export default class EntryBackupAbility extends ExtensionAbility {
  onCreate(want: Want): void {
    console.info('EntryBackupAbility onCreate')
  }

  onDestroy(): void {
    console.info('EntryBackupAbility onDestroy')
  }
}