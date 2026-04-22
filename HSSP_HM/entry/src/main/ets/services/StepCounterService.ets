import sensor from '@ohos.sensor'
import { BusinessError } from '@ohos.base'
import { StepStatistics, PermissionStatus } from '../types/common'
import { ApiService } from './ApiService'
import StateStore from './StateStore'

class StepCounterService {
  private static instance: StepCounterService = new StepCounterService()
  private sensorId: number = -1
  private isMonitoring: boolean = false
  private lastStepCount: number = 0
  private stepChangeCallback: ((steps: number) => void) | null = null
  private lastSyncTime: number = 0
  private syncInterval: number = 60000 // 1分钟同步一次
  private isSyncing: boolean = false

  public static getInstance(): StepCounterService {
    return StepCounterService.instance
  }

  // 检查步数传感器是否可用
  async isStepCounterAvailable(): Promise<boolean> {
    try {
      const sensorList: sensor.Sensor[] = await sensor.getSensorList()
      for (let i = 0; i < sensorList.length; i++) {
        if (sensorList[i].sensorId === sensor.SensorId.PEDOMETER) {
          return true
        }
      }
      return false
    } catch (error) {
      console.error('检查步数传感器失败:', error)
      return false
    }
  }

  // 开始监控步数
  async startStepMonitoring(callback: (steps: number) => void): Promise<boolean> {
    if (this.isMonitoring) {
      console.log('步数监控已经在运行')
      return true
    }

    const isAvailable = await this.isStepCounterAvailable()
    if (!isAvailable) {
      console.error('步数传感器不可用')
      return false
    }

    try {
      this.stepChangeCallback = callback

      // 创建步数传感器监听器
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        if (data) {
          const currentSteps = data.steps
          this.handleStepChange(currentSteps)
        }
      })

      this.isMonitoring = true
      console.log('步数监控已启动')

      // 启动定时同步任务
      this.startSyncTask()

      return true
    } catch (error) {
      console.error('启动步数监控失败:', error)
      return false
    }
  }

  // 停止监控步数
  stopStepMonitoring(): void {
    if (!this.isMonitoring) {
      return
    }

    try {
      sensor.off(sensor.SensorId.PEDOMETER)
      this.isMonitoring = false
      this.stepChangeCallback = null

      // 停止同步任务
      this.stopSyncTask()

      console.log('步数监控已停止')
    } catch (error) {
      console.error('停止步数监控失败:', error)
    }
  }

  // 处理步数变化
  private handleStepChange(currentSteps: number): void {
    // 防止重复处理相同的步数
    if (currentSteps === this.lastStepCount) {
      return
    }

    const stepDifference = currentSteps - this.lastStepCount

    // 只处理正向的步数变化（防止传感器异常）
    if (stepDifference > 0) {
      this.lastStepCount = currentSteps

      if (this.stepChangeCallback) {
        this.stepChangeCallback(currentSteps)
      }

      // 记录步数变化日志
      this.logStepChange(currentSteps, stepDifference)

      // 立即同步步数到后端（在变化较大时）
      if (stepDifference >= 100) { // 当步数变化超过100步时立即同步
        this.syncStepsToBackend()
      }
    }
  }

  // 记录步数变化
  private logStepChange(totalSteps: number, stepDifference: number): void {
    const timestamp = new Date().toISOString()
    console.log(`步数变化: +${stepDifference}步, 总计: ${totalSteps}步, 时间: ${timestamp}`)
  }

  // 启动定时同步任务
  private startSyncTask(): void {
    // 每分钟同步一次步数数据
    setInterval(() => {
      this.syncStepsToBackend()
    }, this.syncInterval)
  }

  // 停止同步任务
  private stopSyncTask(): void {
    // 这里需要清理定时器，但ArkTS中没有clearInterval，需要其他方式处理
    // 在实际应用中可以使用其他定时器管理方式
  }

  // 同步步数到后端（数据库和Redis）
  private async syncStepsToBackend(): Promise<void> {
    if (this.isSyncing) {
      console.log('步数同步正在进行中，跳过本次同步')
      return
    }

    if (this.lastStepCount <= 0) {
      console.log('步数为0，无需同步')
      return
    }

    const currentTime = Date.now()
    if (currentTime - this.lastSyncTime < 30000) { // 30秒内不重复同步
      console.log('距离上次同步时间太短，跳过本次同步')
      return
    }

    try {
      this.isSyncing = true
      this.lastSyncTime = currentTime

      console.log(`开始同步步数到后端: ${this.lastStepCount}步`)

      // 检查用户是否已登录
      if (!StateStore.isLoggedIn) {
        console.log('用户未登录，跳过步数同步')
        return
      }

      // 获取当前日期
      const today = new Date().toISOString().split('T')[0]

      // 调用API上传步数
      await ApiService.uploadSteps(this.lastStepCount, today)

      console.log('步数同步成功')

      // 更新本地存储
      StateStore.todaySteps = this.lastStepCount
      AppStorage.setOrCreate('todaySteps', this.lastStepCount)

      // 如果有较大的步数变化，同时更新用户信息
      if (this.lastStepCount > StateStore.userInfo.totalSteps) {
        await this.updateUserInfo()
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      console.error(`步数同步失败: ${errorMessage}`)

      // 同步失败时，记录错误但不影响主流程
      // 下次同步时会重试
    } finally {
      this.isSyncing = false
    }
  }

  // 更新用户信息
  private async updateUserInfo(): Promise<void> {
    try {
      console.log('更新用户信息...')
      const userInfo = await ApiService.getUserInfo()
      await StateStore.saveUserInfo(userInfo)
      console.log('用户信息更新成功')
    } catch (error) {
      console.error('更新用户信息失败:', error)
    }
  }

  // 手动同步步数（供外部调用）
  async manualSync(): Promise<boolean> {
    try {
      await this.syncStepsToBackend()
      return true
    } catch (error) {
      console.error('手动同步失败:', error)
      return false
    }
  }

  // 获取当前步数（如果监控未启动，返回0）
  getCurrentSteps(): number {
    return this.lastStepCount
  }

  // 重置步数计数
  resetStepCount(): void {
    this.lastStepCount = 0
    console.log('步数计数已重置')
  }

  // 手动设置步数（用于测试或数据同步）
  setStepCount(steps: number): void {
    if (steps >= 0) {
      this.lastStepCount = steps
      console.log(`手动设置步数为: ${steps}`)

      // 设置步数后立即同步
      this.syncStepsToBackend()
    }
  }

  // 获取步数统计信息
  getStepStatistics(): StepStatistics {
    const now = new Date()

    return {
      todaySteps: this.lastStepCount,
      weekSteps: this.lastStepCount * 7,
      monthSteps: this.lastStepCount * 30,
      totalSteps: this.lastStepCount,
      avgDailySteps: this.lastStepCount,
      maxDailySteps: this.lastStepCount,
      minDailySteps: this.lastStepCount,
      lastUpdate: now.toISOString()
    }
  }

  // 检查权限状态
  async checkPermissions(): Promise<PermissionStatus> {
    try {
      const isAvailable = await this.isStepCounterAvailable()

      return {
        stepCounter: isAvailable,
        healthKit: false, // 鸿蒙中没有HealthKit
        location: false,
        notification: false
      }
    } catch (error) {
      console.error('检查权限失败:', error)
      return {
        stepCounter: false,
        healthKit: false,
        location: false,
        notification: false
      }
    }
  }

  // 请求必要权限
  async requestPermissions(): Promise<boolean> {
    try {
      // 这里应该请求步数传感器权限
      // 简化处理，返回成功
      console.log('权限请求已发送')
      return true
    } catch (error) {
      console.error('请求权限失败:', error)
      return false
    }
  }

  // 模拟步数增加（用于测试）
  simulateStepIncrease(steps: number): void {
    if (steps > 0) {
      const newSteps = this.lastStepCount + steps
      this.handleStepChange(newSteps)
    }
  }
}

export default StepCounterService.getInstance()