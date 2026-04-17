import promptAction from '@ohos.promptAction'

// 定义对话框按钮接口
interface DialogButton {
  text: string;
  color: string;
}

// 定义对话框选项接口
interface DialogOptions {
  title: string;
  message: string;
  autoCancel: boolean;
  buttons: DialogButton[];
}

// 定义对话框结果接口
interface DialogResult {
  index: number;
}

/**
 * 提示工具类
 * 提供Toast、Dialog等提示功能
 */
export class PromptUtil {
  
  /**
   * 显示Toast提示
   */
  static showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: 200
    })
  }

  /**
   * 显示确认对话框
   */
  static async showConfirmDialog(title: string, message: string): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      // 创建按钮数组
      const buttons: DialogButton[] = [
        {
          text: '确定',
          color: '#007DFF'
        },
        {
          text: '取消',
          color: '#999999'
        }
      ]

      const options: DialogOptions = {
        title: title,
        message: message,
        autoCancel: true,
        buttons: buttons
      }

      // 使用showDialog方法
      promptAction.showDialog(options)
        .then((result: DialogResult) => {
          // 确定按钮index为0
          resolve(result.index === 0)
        })
        .catch(() => {
          resolve(false)
        })
    })
  }

  /**
   * 显示错误提示
   */
  static showError(message: string): void {
    promptAction.showToast({
      message: `❌ ${message}`,
      duration: 3000,
      bottom: 200
    })
  }

  /**
   * 显示成功提示
   */
  static showSuccess(message: string): void {
    promptAction.showToast({
      message: `✅ ${message}`,
      duration: 2000,
      bottom: 200
    })
  }

  /**
   * 显示警告提示
   */
  static showWarning(message: string): void {
    promptAction.showToast({
      message: `⚠️ ${message}`,
      duration: 2500,
      bottom: 200
    })
  }
}

export default PromptUtil