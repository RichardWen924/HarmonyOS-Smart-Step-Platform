import http from '@ohos.net.http'
import {
  UserInfo, StepRecord, ApiResponse, LoginResponse,
  Product, ExchangeRecord, PageData, ExchangeResponse
} from '../types/common'
import { UserInfoImpl } from './StateStore'

// API 响应数据结构
class SyncStepsData {
  syncedSteps: number = 0
  timestamp: string = ''
}

class PointsRule {
  rule: string = ''
  minSteps?: number
  ratio?: number
  maxDailyExchange?: number
  validityPeriod?: string
}

// Product 类实现
class ProductImpl implements Product {
  id: number = 0
  name: string = ''
  description: string = ''
  points: number = 0
  stock: number = 0
  category: string = ''
  
  constructor(id: number, name: string, description: string, points: number, stock: number, category: string) {
    this.id = id
    this.name = name
    this.description = description
    this.points = points
    this.stock = stock
    this.category = category
  }
}

// ExchangeRecord 类实现
class ExchangeRecordImpl implements ExchangeRecord {
  id: number = 0
  productId: number = 0
  productName: string = ''
  points: number = 0
  status: number = 0
  exchangeTime: string = ''
  remark: string = ''
  
  constructor(id: number, productId: number, productName: string, points: number, status: number, exchangeTime: string, remark: string) {
    this.id = id
    this.productId = productId
    this.productName = productName
    this.points = points
    this.status = status
    this.exchangeTime = exchangeTime
    this.remark = remark
  }
}

// ExchangeResponse 类实现
class ExchangeResponseImpl implements ExchangeResponse {
  exchangedSteps: number = 0
  gainedPoints: number = 0
  remainingSteps: number = 0
  totalPoints: number = 0
  timestamp: string = ''
}

// StepRecord 类实现
class StepRecordImpl implements StepRecord {
  id: number = 0
  steps: number = 0
  date: string = ''
  timestamp: string = ''
  
  constructor(id: number, steps: number, date: string, timestamp: string) {
    this.id = id
    this.steps = steps
    this.date = date
    this.timestamp = timestamp
  }
}

// PageData 类实现
class PageDataImpl<T> implements PageData<T> {
  list: T[] = []
  total: number = 0
  page: number = 0
  pageSize: number = 0
  
  constructor(list: T[], total: number, page: number, pageSize: number) {
    this.list = list
    this.total = total
    this.page = page
    this.pageSize = pageSize
  }
}

// UserInfo 类实现（本地）
class LocalUserInfoImpl implements UserInfo {
  id: number = 0
  username: string = ''
  email: string = ''
  nickname: string = ''
  sex: number = 0
  avatar?: string
  totalSteps: number = 0
  totalPoints: number = 0
  remainingSteps: number = 0
  
  constructor(id: number, username: string, email: string, nickname: string, sex: number, totalSteps: number, totalPoints: number, remainingSteps: number) {
    this.id = id
    this.username = username
    this.email = email
    this.nickname = nickname
    this.sex = sex
    this.totalSteps = totalSteps
    this.totalPoints = totalPoints
    this.remainingSteps = remainingSteps
  }
}

// StepStatisticsData 类实现
class StepStatisticsData {
  records: StepRecord[] = []
  totalSteps: number = 0
  avgSteps: number = 0
  maxSteps: number = 0
}

// PointsData 类实现
class PointsData {
  totalPoints: number = 0
  remainingSteps: number = 0
}

// ApiResponse 类实现
class ApiResponseImpl<T> implements ApiResponse<T> {
  code: number = 0
  message: string = ''
  data: T
  
  constructor(code: number, message: string, data: T) {
    this.code = code
    this.message = message
    this.data = data
  }
}

class ApiClient {
  private static instance: ApiClient = new ApiClient()
  private baseUrl: string = 'http://localhost:3000/api'
  private token: string = ''

  public static getInstance(): ApiClient {
    return ApiClient.instance
  }

  setToken(token: string): void {
    this.token = token
  }

  getToken(): string {
    return this.token
  }

  private async request<T>(url: string, method: http.RequestMethod | string, data?: Record<string, string | number | boolean>): Promise<T> {
    try {
      const httpRequest = http.createHttp()
      const headerRecord: Record<string, string> = {
        'Content-Type': 'application/json'
      }
      
      if (this.token) {
        headerRecord['Authorization'] = `Bearer ${this.token}`
      }
      
      const options: http.HttpRequestOptions = {
        method: method as http.RequestMethod,
        header: headerRecord
      }

      if (data && (method === 'POST' || method === 'PUT')) {
        options.extraData = JSON.stringify(data)
      }

      const response = await httpRequest.request(url, options)
      httpRequest.destroy()

      if (response.responseCode === 200) {
        return response.result as T
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('Request failed:', error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  async sendVerificationCode(email: string, type: number): Promise<ApiResponse<boolean>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'email': email,
        'type': type
      }
      return await this.request<ApiResponse<boolean>>(`${this.baseUrl}/send-verification`, 'POST', requestData)
    } catch (error) {
      await this.delay(1000)
      return new ApiResponseImpl(1, '验证码已发送', true)
    }
  }

  async register(email: string, verificationCode: string, nickname?: string): Promise<ApiResponse<LoginResponse>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'email': email,
        'verification': verificationCode
      }
      if (nickname) {
        requestData['nickname'] = nickname
      }
      const result = await this.request<ApiResponse<LoginResponse>>(`${this.baseUrl}/register`, 'POST', requestData)
      if (result.code === 1 && result.data) {
        this.setToken(result.data.token)
      }
      return result
    } catch (error) {
      await this.delay(1000)
      const userInfo: UserInfo = new LocalUserInfoImpl(
        1,
        email,
        email,
        nickname || '新用户',
        0,
        0,
        0,
        0
      )
      const loginData: LoginResponse = new LoginResponse()
      loginData.userInfo = userInfo
      loginData.token = 'mock_token_' + Date.now()
      this.setToken(loginData.token)
      return new ApiResponseImpl(1, '注册成功', loginData)
    }
  }

  async loginByPassword(account: string, password: string): Promise<ApiResponse<LoginResponse>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'account': account,
        'password': password,
        'loginType': 1
      }
      const result = await this.request<ApiResponse<LoginResponse>>(`${this.baseUrl}/login`, 'POST', requestData)
      if (result.code === 1 && result.data) {
        this.setToken(result.data.token)
      }
      return result
    } catch (error) {
      await this.delay(1000)
      const userInfo: UserInfo = new LocalUserInfoImpl(
        1,
        account,
        account,
        '测试用户',
        0,
        10000,
        500,
        5000
      )
      const loginData: LoginResponse = new LoginResponse()
      loginData.userInfo = userInfo
      loginData.token = 'mock_token_' + Date.now()
      this.setToken(loginData.token)
      return new ApiResponseImpl(1, '登录成功', loginData)
    }
  }

  async loginByCode(account: string, verificationCode: string): Promise<ApiResponse<LoginResponse>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'account': account,
        'verificationCode': verificationCode,
        'loginType': 2
      }
      const result = await this.request<ApiResponse<LoginResponse>>(`${this.baseUrl}/login`, 'POST', requestData)
      if (result.code === 1 && result.data) {
        this.setToken(result.data.token)
      }
      return result
    } catch (error) {
      await this.delay(1000)
      const userInfo: UserInfo = new LocalUserInfoImpl(
        1,
        account,
        account,
        '测试用户',
        0,
        10000,
        500,
        5000
      )
      const loginData: LoginResponse = new LoginResponse()
      loginData.userInfo = userInfo
      loginData.token = 'mock_token_' + Date.now()
      this.setToken(loginData.token)
      return new ApiResponseImpl(1, '登录成功', loginData)
    }
  }

  async uploadSteps(steps: number, date: string): Promise<ApiResponse<SyncStepsData>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'steps': steps,
        'date': date,
        'timestamp': new Date().toISOString()
      }
      return await this.request<ApiResponse<SyncStepsData>>(`${this.baseUrl}/user/steps`, 'POST', requestData)
    } catch (error) {
      await this.delay(800)
      const syncData: SyncStepsData = new SyncStepsData()
      syncData.syncedSteps = steps
      syncData.timestamp = new Date().toISOString()
      return new ApiResponseImpl(1, '同步成功', syncData)
    }
  }

  async getStepStatistics(days: number): Promise<ApiResponse<StepStatisticsData>> {
    try {
      return await this.request<ApiResponse<StepStatisticsData>>(`${this.baseUrl}/user/steps/statistics?days=${days}`, 'GET')
    } catch (error) {
      await this.delay(800)
      const mockRecords: StepRecord[] = []
      let totalSteps = 0
      let maxSteps = 0
      
      for (let i = 0; i < days; i++) {
        const steps = Math.floor(Math.random() * 5000) + 5000
        const stepRecord: StepRecord = new StepRecordImpl(
          i + 1,
          steps,
          new Date(Date.now() - i * 86400000).toISOString().split('T')[0],
          new Date().toISOString()
        )
        mockRecords.push(stepRecord)
        totalSteps += steps
        if (steps > maxSteps) maxSteps = steps
      }
      
      const result: StepStatisticsData = {
        records: mockRecords,
        totalSteps: totalSteps,
        avgSteps: Math.round(totalSteps / days),
        maxSteps: maxSteps
      }
      
      return new ApiResponseImpl(1, 'success', result)
    }
  }

  async getRankings(periodType: string, page: number, pageSize: number): Promise<ApiResponse<PageData<UserInfo>>> {
    try {
      return await this.request<ApiResponse<PageData<UserInfo>>>(`${this.baseUrl}/user/rankings`, 'GET')
    } catch (error) {
      await this.delay(800)
      const mockList: UserInfo[] = []
      for (let i = 0; i < pageSize; i++) {
        const userInfo: UserInfo = new LocalUserInfoImpl(
          i + 1,
          `user${i + 1}`,
          `user${i + 1}@example.com`,
          `用户${i + 1}`,
          i % 2 === 0 ? 0 : 1,
          Math.floor(Math.random() * 50000) + 10000,
          Math.floor(Math.random() * 1000) + 100,
          Math.floor(Math.random() * 5000)
        )
        mockList.push(userInfo)
      }
      const pageData: PageData<UserInfo> = new PageDataImpl(mockList, 100, page, pageSize)
      return new ApiResponseImpl(1, 'success', pageData)
    }
  }

  async getUserPoints(): Promise<ApiResponse<PointsData>> {
    try {
      return await this.request<ApiResponse<PointsData>>(`${this.baseUrl}/user/points`, 'GET')
    } catch (error) {
      await this.delay(300)
      const pointsData: PointsData = new PointsData()
      pointsData.totalPoints = Math.floor(Math.random() * 5000) + 500
      pointsData.remainingSteps = Math.floor(Math.random() * 20000) + 5000
      return new ApiResponseImpl(1, '获取成功', pointsData)
    }
  }

  async exchangePoints(steps: number): Promise<ApiResponse<ExchangeResponse>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'steps': steps
      }
      return await this.request<ApiResponse<ExchangeResponse>>(`${this.baseUrl}/user/exchange`, 'POST', requestData)
    } catch (error) {
      await this.delay(700)
      const points = Math.floor(steps / 100)
      const exchangeData: ExchangeResponse = new ExchangeResponseImpl()
      exchangeData.exchangedSteps = steps
      exchangeData.gainedPoints = points
      exchangeData.remainingSteps = Math.floor(Math.random() * 10000)
      exchangeData.totalPoints = Math.floor(Math.random() * 5000) + points
      exchangeData.timestamp = new Date().toISOString()
      return new ApiResponseImpl(1, '兑换成功', exchangeData)
    }
  }

  async getPointsRules(): Promise<ApiResponse<PointsRule[]>> {
    try {
      return await this.request<ApiResponse<PointsRule[]>>(`${this.baseUrl}/user/rules`, 'GET')
    } catch (error) {
      await this.delay(300)
      const mockRules: PointsRule[] = [
        new PointsRule(),
        new PointsRule(),
        new PointsRule()
      ]
      mockRules[0].rule = '每 100 步可兑换 1 积分'
      mockRules[0].minSteps = 100
      mockRules[0].ratio = 0.01
      
      mockRules[1].rule = '每日最多兑换 10000 步'
      mockRules[1].maxDailyExchange = 10000
      
      mockRules[2].rule = '积分永久有效'
      mockRules[2].validityPeriod = 'permanent'
      
      return new ApiResponseImpl(1, '获取成功', mockRules)
    }
  }

  async getProducts(page: number = 1, pageSize: number = 10): Promise<ApiResponse<PageData<Product>>> {
    try {
      return await this.request<ApiResponse<PageData<Product>>>(`${this.baseUrl}/mall/products?page=${page}&pageSize=${pageSize}`, 'GET')
    } catch (error) {
      await this.delay(400)
      const mockProducts: Product[] = [
        new ProductImpl(1, '运动手环', '智能计步，健康监测', 5000, 100, '电子产品'),
        new ProductImpl(2, '运动水杯', '便携保温，健康材质', 2000, 200, '生活用品'),
        new ProductImpl(3, '运动毛巾', '吸汗透气，柔软舒适', 800, 500, '运动配件'),
        new ProductImpl(4, '健身垫', '防滑耐磨，家用必备', 3500, 150, '健身器材'),
        new ProductImpl(5, '运动袜', '透气减震，专业运动', 1200, 300, '服饰'),
        new ProductImpl(6, '跳绳', '计数跳绳，健身减肥', 1500, 250, '健身器材'),
        new ProductImpl(7, '运动背包', '轻便耐用，大容量', 4500, 120, '箱包'),
        new ProductImpl(8, '护腕套装', '运动防护，透气舒适', 600, 400, '运动配件')
      ]
      const pageData: PageData<Product> = new PageDataImpl(mockProducts.slice((page - 1) * pageSize, page * pageSize), mockProducts.length, page, pageSize)
      return new ApiResponseImpl(1, '获取成功', pageData)
    }
  }

  async exchangeProduct(productId: number, address?: string): Promise<ApiResponse<boolean>> {
    try {
      const requestData: Record<string, number | string | boolean> = {
        'productId': productId
      }
      if (address) {
        requestData['address'] = address
      }
      return await this.request<ApiResponse<boolean>>(`${this.baseUrl}/mall/exchange`, 'POST', requestData)
    } catch (error) {
      await this.delay(600)
      return new ApiResponseImpl(1, '兑换成功', true)
    }
  }

  async getExchangeRecords(page: number = 1, pageSize: number = 10): Promise<ApiResponse<PageData<ExchangeRecord>>> {
    try {
      return await this.request<ApiResponse<PageData<ExchangeRecord>>>(`${this.baseUrl}/user/exchange-records?page=${page}&pageSize=${pageSize}`, 'GET')
    } catch (error) {
      await this.delay(400)
      const mockRecords: ExchangeRecord[] = [
        new ExchangeRecordImpl(1, 1, '运动手环', 5000, 1, new Date(Date.now() - 86400000 * 5).toISOString(), '已发货'),
        new ExchangeRecordImpl(2, 3, '运动毛巾', 800, 2, new Date(Date.now() - 86400000 * 10).toISOString(), '已完成')
      ]
      const pageData: PageData<ExchangeRecord> = new PageDataImpl(mockRecords, mockRecords.length, page, pageSize)
      return new ApiResponseImpl(1, '获取成功', pageData)
    }
  }

  async getAllExchangeRecords(): Promise<ApiResponse<ExchangeRecord[]>> {
    try {
      return await this.request<ApiResponse<ExchangeRecord[]>>(`${this.baseUrl}/user/exchange-records/all`, 'GET')
    } catch (error) {
      await this.delay(400)
      const mockRecords: ExchangeRecord[] = [
        {
          id: 1,
          productId: 1,
          productName: '运动手环',
          points: 5000,
          status: 1,
          exchangeTime: new Date(Date.now() - 86400000 * 5).toISOString(),
          type: 'points',
          steps: 0,
          description: '已发货'
        } as ExchangeRecord,
        {
          id: 2,
          productId: 3,
          productName: '运动毛巾',
          points: 800,
          status: 2,
          exchangeTime: new Date(Date.now() - 86400000 * 10).toISOString(),
          type: 'points',
          steps: 0,
          description: '已完成'
        } as ExchangeRecord
      ]
      return new ApiResponseImpl(1, '获取成功', mockRecords)
    }
  }

  async getUserInfo(): Promise<ApiResponse<UserInfo>> {
    try {
      return await this.request<ApiResponse<UserInfo>>(`${this.baseUrl}/user`, 'GET')
    } catch (error) {
      await this.delay(300)
      return new ApiResponseImpl(1, '获取成功', new LocalUserInfoImpl(0, '', '', '', 0, 0, 0, 0))
    }
  }

  async updateUserInfo(userInfo: Partial<UserInfo>): Promise<ApiResponse<boolean>> {
    try {
      const requestData: Record<string, string | number | boolean> = {}
      Object.keys(userInfo).forEach(key => {
        requestData[key] = (userInfo as Record<string, string | number | boolean>)[key]
      })
      return await this.request<ApiResponse<boolean>>(`${this.baseUrl}/user`, 'PUT', requestData)
    } catch (error) {
      await this.delay(600)
      return new ApiResponseImpl(1, '更新成功', true)
    }
  }

  async updatePassword(oldPassword: string, newPassword: string): Promise<ApiResponse<boolean>> {
    try {
      const requestData: Record<string, string | number | boolean> = {
        'oldPassword': oldPassword,
        'newPassword': newPassword
      }
      return await this.request<ApiResponse<boolean>>(`${this.baseUrl}/user/password`, 'PUT', requestData)
    } catch (error) {
      await this.delay(600)
      return new ApiResponseImpl(1, '修改成功', true)
    }
  }
}

export default ApiClient