import ApiClient from '../services/ApiClient'
import StateStore from '../services/StateStore'
import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import { UserInfo, PointRule, ExchangeResponse } from '../types/common'

@Entry
@Component
export struct PointsExchangePage {
  @State todaySteps: number = 0
  @State totalPoints: number = 0

  @State exchangeSteps: string = ''
  @State isLoading: boolean = false
  @State pointRules: PointRule[] = []

  private stateStore = StateStore

  aboutToAppear() {
    console.log('PointsExchangePage: aboutToAppear called')
    this.loadUserData()
    this.loadPointRules()
  }

  // 加载用户数据
  private async loadUserData(): Promise<void> {
    try {
      console.log('PointsExchangePage: 开始从后端加载用户数据')

      // 从后端获取最新的用户信息（包含剩余步数和总积分）
      const userInfoResponse = await ApiClient.getUserInfo()

      if (userInfoResponse.code === 1 && userInfoResponse.data) {
        // 更新本地存储
        await this.stateStore.saveUserInfo(userInfoResponse.data)

        // 使用剩余步数作为今日步数
        this.todaySteps = userInfoResponse.data.remainingSteps || 0
        this.totalPoints = userInfoResponse.data.totalPoints || 0

        console.log('PointsExchangePage: 从后端加载用户数据成功')
        console.log('剩余步数:', this.todaySteps, '总积分:', this.totalPoints)
      } else {
        console.warn('PointsExchangePage: 后端请求失败，使用本地数据')
        // 降级方案：从本地存储加载
        const userInfo = await this.stateStore.getUserInfo()
        this.todaySteps = userInfo.remainingSteps || 0
        this.totalPoints = userInfo.totalPoints || 0
      }
    } catch (error) {
      console.error('Failed to load user data from backend:', error)
      // 降级方案：从本地存储加载
      try {
        const userInfo = await this.stateStore.getUserInfo()
        this.todaySteps = userInfo.remainingSteps || 0
        this.totalPoints = userInfo.totalPoints || 0
      } catch (localError) {
        console.error('Failed to load local user data:', localError)
      }
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      Scroll() {
        Column() {
          // 用户步数信息卡片
          this.buildStepsInfoCard()

          // 积分兑换规则说明
          this.buildRulesCard()

          // 步数输入区域
          this.buildInputSection()


        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Button('←')
        .fontSize(24)
        .backgroundColor(Color.Transparent)
        .fontColor('#007DFF')
        .onClick(() => {
          router.back()
        })

      Text('积分兑换')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildStepsInfoCard() {
    Column() {
      Row() {
        Column() {
          Text('👣')
            .fontSize(32)
            .margin({ bottom: 8 })

          Text(this.todaySteps.toLocaleString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34C759')

          Text('剩余步数')
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height(60)

        Column() {
          Text('💰')
            .fontSize(32)
            .margin({ bottom: 8 })

          Text(this.totalPoints.toLocaleString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')

          Text('可用积分')
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  buildRulesCard() {
    Column() {
      Row() {
        Text('📋')
          .fontSize(20)
          .margin({ right: 8 })

        Text('兑换规则')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.pointRules.length > 0) {
        ForEach(this.pointRules, (rule: PointRule) => {
          Row() {
            Text('•')
              .fontSize(16)
              .fontColor('#007DFF')
              .margin({ right: 8 })

            Text(`${rule.stepsRequired.toLocaleString()} 步 → ${rule.pointsAwarded} 积分`)
              .fontSize(14)
              .fontColor('#333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        })
      } else {
        Text('1000 步 → 1 积分（默认规则）')
          .fontSize(14)
          .fontColor('#666')
      }

      Text('💡 系统会自动按最优规则组合兑换')
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 12 })
        .padding({ left: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  buildInputSection() {
    Column() {
      Text('输入兑换步数')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      TextInput({ placeholder: `最多可兑换 ${this.todaySteps.toLocaleString()} 步`, text: this.exchangeSteps })
        .width('100%')
        .height(50)
        .borderRadius(8)
        .backgroundColor('#FFFFFF')
        .padding({ left: 12, right: 12 })
        .type(InputType.Number)
        .fontSize(18)
        .onChange((value: string) => {
          this.exchangeSteps = value
        })

      // 快捷输入按钮
      Row() {
        Text('快捷选择：')
          .fontSize(12)
          .fontColor('#999')
          .margin({ right: 8 })

        Button('1000')
          .fontSize(12)
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .enabled(1000 <= this.todaySteps)
          .onClick(() => {
            const actualSteps = Math.min(1000, this.todaySteps)
            this.exchangeSteps = actualSteps.toString()
            console.log('PointsExchangePage: 快捷选择步数:', actualSteps)
          })

        Button('5000')
          .fontSize(12)
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .enabled(5000 <= this.todaySteps)
          .onClick(() => {
            const actualSteps = Math.min(5000, this.todaySteps)
            this.exchangeSteps = actualSteps.toString()
            console.log('PointsExchangePage: 快捷选择步数:', actualSteps)
          })

        Button('10000')
          .fontSize(12)
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .enabled(10000 <= this.todaySteps)
          .onClick(() => {
            const actualSteps = Math.min(10000, this.todaySteps)
            this.exchangeSteps = actualSteps.toString()
            console.log('PointsExchangePage: 快捷选择步数:', actualSteps)
          })

        Button('全部')
          .fontSize(12)
          .backgroundColor('#E3F2FD')
          .fontColor('#007DFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .enabled(this.todaySteps > 0)
          .onClick(() => {
            this.exchangeSteps = this.todaySteps.toString()
            console.log('PointsExchangePage: 选择全部步数:', this.todaySteps)
          })
      }
      .width('100%')
      .margin({ top: 12 })
      .justifyContent(FlexAlign.Start)

      // 兑换按钮
      Button('确认兑换')
        .width('100%')
        .height(45)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .enabled(!this.isLoading && this.exchangeSteps.length > 0)
        .margin({ top: 20 })
        .onClick(() => {
          console.log('PointsExchangePage: 点击确认兑换按钮，步数:', this.exchangeSteps)
          this.confirmExchange()
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }



  async loadPointRules() {
    try {
      console.log('PointsExchangePage: 开始加载积分规则')
      const result = await ApiClient.getPointRules()
      console.log('PointsExchangePage: 积分规则加载结果:', result)

      if (result.code === 1) {
        this.pointRules = result.data
      } else {
        console.error('加载积分规则失败:', result.message)
        // 设置默认规则
        this.pointRules = [
          { id: 1, ruleName: '默认规则', stepsRequired: 1000, pointsAwarded: 1, isActive: 1 }
        ]
      }
    } catch (error) {
      console.error('加载积分规则失败:', error)
      // 设置默认规则
      this.pointRules = [
        { id: 1, ruleName: '默认规则', stepsRequired: 1000, pointsAwarded: 1, isActive: 1 }
      ]
    }
  }



  async confirmExchange() {
    const steps = parseInt(this.exchangeSteps)

    if (!steps || steps <= 0) {
      promptAction.showToast({ message: '请输入有效的步数', duration: 2000 })
      return
    }

    if (steps > this.todaySteps) {
      promptAction.showToast({ message: `步数不能超过剩余步数 ${this.todaySteps}`, duration: 2000 })
      return
    }

    // 显示确认对话框
    try {
      const confirmed = await new Promise<boolean>((resolve) => {
        promptAction.showDialog({
          title: '确认兑换',
          message: `确定要兑换 ${steps.toLocaleString()} 步吗？\n将按照兑换规则自动计算获得积分`,
          buttons: [
            { text: '取消', color: '#666666' },
            { text: '确定', color: '#007DFF' }
          ]
        }).then((result) => {
          resolve(result.index === 1)
        })
      })

      if (confirmed) {
        this.isLoading = true
        console.log('PointsExchangePage: 开始兑换积分，步数:', steps)

        // 使用ApiClient直接调用，而不是ApiService
        const result = await ApiClient.exchangePoints(steps)
        console.log('PointsExchangePage: 兑换结果:', JSON.stringify(result))
        console.log('PointsExchangePage: result.data:', JSON.stringify(result.data))

        if (result.code === 1) {
          promptAction.showToast({
            message: `兑换成功！获得 ${result.data.gainedPoints?.toLocaleString()} 积分`,
            duration: 2000
          })

          console.log('PointsExchangePage: 后端返回的数据 -', JSON.stringify(result.data))

          // 直接使用后端返回的最新数据，避免再次查询
          const newRemainingSteps = result.data.remainingSteps || 0
          const newTotalPoints = result.data.totalPoints || 0

          console.log('PointsExchangePage: 准备更新界面 - 剩余步数:', newRemainingSteps, '总积分:', newTotalPoints)

          // 先重置表单，再更新状态（确保状态变化被检测到）
          this.exchangeSteps = ''

          // 使用临时变量强制触发状态更新
          this.todaySteps = 0
          this.totalPoints = 0

          // 延迟一下再设置真实值，确保状态变化被检测到
          setTimeout(() => {
            this.todaySteps = newRemainingSteps
            this.totalPoints = newTotalPoints

            console.log('PointsExchangePage: 界面已更新 - 剩余步数:', this.todaySteps, '总积分:', this.totalPoints)

            // 更新本地存储
            this.stateStore.updateTodaySteps(this.todaySteps)
            this.stateStore.updatePoints(this.totalPoints, this.todaySteps)
            
            // 显示成功提示后，延迟返回主页
            setTimeout(() => {
              router.back()
            }, 1500)
          }, 100)
        } else {
          console.error('PointsExchangePage: 兑换失败，错误码:', result.code, '消息:', result.message)
          promptAction.showToast({
            message: `兑换失败: ${result.message}`,
            duration: 2000
          })
        }
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      console.error('PointsExchangePage: 兑换失败:', errorMessage)
      promptAction.showToast({ message: `兑换失败: ${errorMessage}`, duration: 2000 })
    } finally {
      this.isLoading = false
    }
  }
}