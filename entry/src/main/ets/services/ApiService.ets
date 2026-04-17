import { ApiClient } from './ApiClient'
import { UserInfo, PointRule, ExchangePreview, ExchangeResponse, ApiResponse } from '../types/common'

/**
 * API服务类
 * 提供积分兑换相关的API调用
 */
export class ApiService {
  
  /**
   * 获取积分兑换规则
   */
  static async getPointRules(): Promise<PointRule[]> {
    try {
      const response = await ApiClient.getPointRules()
      if (response.code === 1 && response.data) {
        return response.data
      }
      return []
    } catch (error) {
      console.error('获取积分规则失败:', error)
      return []
    }
  }

  /**
   * 预览兑换结果
   */
  static async previewExchange(steps: number): Promise<ExchangePreview> {
    try {
      const response = await ApiClient.previewExchange(steps)
      if (response.code === 1 && response.data) {
        return response.data
      }
      throw new Error(response.message || '预览失败')
    } catch (error) {
      console.error('预览兑换失败:', error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    }
  }

  /**
   * 执行积分兑换
   */
  static async exchangePoints(steps: number): Promise<ExchangeResponse> {
    try {
      const response = await ApiClient.exchangePoints(steps)
      if (response.code === 1 && response.data) {
        return response.data
      }
      throw new Error(response.message || '兑换失败')
    } catch (error) {
      console.error('积分兑换失败:', error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    }
  }

  /**
   * 上传步数数据
   */
  static async uploadSteps(steps: number, date: string): Promise<void> {
    try {
      const response = await ApiClient.uploadSteps(steps, date)
      if (response.code !== 1) {
        throw new Error(response.message || '步数上传失败')
      }
    } catch (error) {
      console.error('步数上传失败:', error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    }
  }

  /**
   * 获取用户信息
   */
  static async getUserInfo(): Promise<UserInfo> {
    try {
      const response = await ApiClient.getUserInfo()
      if (response.code === 1 && response.data) {
        return response.data
      }
      throw new Error(response.message || '获取用户信息失败')
    } catch (error) {
      console.error('获取用户信息失败:', error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    }
  }
}

export default ApiService