import http from '@ohos.net.http'
import AppConfig from '../config/AppConfig'
import { 
  ApiResponse, 
  LoginRequest, 
  LoginResponse, 
  RegisterRequest, 
  VerificationRequest, 
  UserInfo, 
  StepRecord, 
  StepStatistics, 
  RankingItem, 
  ExchangeRequest, 
  ExchangeResponse,
  ExchangeRecord 
} from '../types/common'

/**
 * API 客户端服务类
 * 负责与后端 API 进行通信
 */
class ApiClientImpl {
  private static instance: ApiClientImpl
  private baseUrl: string = AppConfig.baseUrl
  private timeout: number = AppConfig.timeout
  private maxRetries: number = AppConfig.maxRetries
  private retryDelay: number = AppConfig.retryDelay
  
  // JWT Token 存储
  private jwtToken: string = ''
  
  /**
   * 获取 ApiClient 实例（单例模式）
   */
  public static getInstance(): ApiClientImpl {
    if (!ApiClientImpl.instance) {
      ApiClientImpl.instance = new ApiClientImpl()
    }
    return ApiClientImpl.instance
  }

  /**
   * 设置 JWT Token
   */
  public setToken(token: string): void {
    this.jwtToken = token
  }

  /**
   * 获取当前 Token
   */
  public getToken(): string {
    return this.jwtToken
  }

  /**
   * 清除 Token
   */
  public clearToken(): void {
    this.jwtToken = ''
  }

  /**
   * 发送 HTTP 请求的通用方法
   */
  private async request<T>(endpoint: string, options: http.HttpRequestOptions, retryCount: number = 0): Promise<ApiResponse<T>> {
    // 如果启用了 Mock 数据，则返回模拟数据
    if (AppConfig.enableMock) {
      return this.getMockResponse<T>(endpoint)
    }

    const httpRequest = http.createHttp()
    const url = `${this.baseUrl}${endpoint}`
    
    try {
      // 设置请求头
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      }
      
      // 如果存在 JWT Token，添加到 Authorization 头
      if (this.jwtToken) {
        headers['Authorization'] = `Bearer ${this.jwtToken}`
      }
      
      const requestOptions: http.HttpRequestOptions = {
        method: options.method,
        header: headers,
        extraData: options.extraData,
        readTimeout: this.timeout,
        connectTimeout: this.timeout
      }

      console.log(`Sending ${options.method} request to: ${url}`)
      
      const response = await httpRequest.request(url, requestOptions)
      
      if (response.responseCode === 200) {
        try {
          const result = JSON.parse(response.result as string) as ApiResponse<T>
          console.log(`API Response for ${endpoint}:`, result)
          return result
        } catch (parseError) {
          console.error('Failed to parse response:', parseError)
          throw new Error('Invalid response format')
        }
      } else if (response.responseCode === 401) {
        // Token 过期或无效
        this.clearToken()
        throw new Error('Authentication failed')
      } else if (response.responseCode >= 500 && retryCount < this.maxRetries) {
        // 服务器错误，重试
        console.log(`Retrying request (${retryCount + 1}/${this.maxRetries})...`)
        await this.delay(this.retryDelay)
        return this.request<T>(endpoint, options, retryCount + 1)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      console.error(`Request failed for ${url}:`, error)
      
      // 网络错误，重试
      if (retryCount < this.maxRetries) {
        console.log(`Retrying request due to network error (${retryCount + 1}/${this.maxRetries})...`)
        await this.delay(this.retryDelay)
        return this.request<T>(endpoint, options, retryCount + 1)
      }
      
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(String(error))
      }
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 延迟函数
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  /**
   * 密码登录
   */
  async loginByPassword(account: string, password: string): Promise<ApiResponse<LoginResponse>> {
    // 判断是用户名还是邮箱：包含@符号的是邮箱，否则是用户名
    const isEmail = account.includes('@')
    const requestData: LoginRequest = {
      password: password
    }
    
    // 根据账号类型设置对应的字段
    if (isEmail) {
      requestData.email = account
    } else {
      requestData.username = account
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    const response = await this.request<LoginResponse>('/user/login', options)
    
    // 如果登录成功，保存 Token
    if (response.code === 1 && response.data?.token) {
      this.setToken(response.data.token)
    }
    
    return response
  }

  /**
   * 验证码登录
   */
  async loginByCode(account: string, code: string): Promise<ApiResponse<LoginResponse>> {
    // 判断是用户名还是邮箱：包含@符号的是邮箱，否则是用户名
    const isEmail = account.includes('@')
    const requestData: LoginRequest = {
      verification: code
    }
    
    // 根据账号类型设置对应的字段
    if (isEmail) {
      requestData.email = account
    } else {
      requestData.username = account
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    const response = await this.request<LoginResponse>('/user/login-by-code', options)
    
    // 如果登录成功，保存 Token
    if (response.code === 1 && response.data?.token) {
      this.setToken(response.data.token)
    }
    
    return response
  }

  /**
   * 用户注册
   */
  async register(email: string, code: string): Promise<ApiResponse<LoginResponse>> {
    const requestData: RegisterRequest = {
      email: email,
      verification: code
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    const response = await this.request<LoginResponse>('/user/register', options)
    
    // 如果注册成功，保存 Token
    if (response.code === 1 && response.data?.token) {
      this.setToken(response.data.token)
    }
    
    return response
  }

  /**
   * 发送验证码
   */
  async sendVerificationCode(email: string): Promise<ApiResponse<void>> {
    const requestData: VerificationRequest = {
      email: email
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    return await this.request<void>('/user/send-code', options)
  }

  /**
   * 获取用户信息
   */
  async getUserInfo(): Promise<ApiResponse<UserInfo>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    
    return await this.request<UserInfo>('/user', options)
  }

  /**
   * 更新用户信息
   */
  async updateUserInfo(userInfo: Partial<UserInfo>): Promise<ApiResponse<UserInfo>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.PUT,
      extraData: JSON.stringify(userInfo)
    }
    
    return await this.request<UserInfo>('/user', options)
  }

  /**
   * 修改密码
   */
  async updatePassword(oldPassword: string, newPassword: string): Promise<ApiResponse<void>> {
    interface PasswordUpdateRequest {
      oldPassword: string;
      newPassword: string;
    }
    
    const requestData: PasswordUpdateRequest = {
      oldPassword: oldPassword,
      newPassword: newPassword
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.PUT,
      extraData: JSON.stringify(requestData)
    }
    
    return await this.request<void>('/user/password', options)
  }

  /**
   * 上传步数数据
   */
  async uploadStepData(steps: number, date: string): Promise<ApiResponse<void>> {
    interface StepUploadData {
      steps: number;
      date: string;
    }
    
    const requestData: StepUploadData = {
      steps: steps,
      date: date
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    return await this.request<void>('/steps/upload', options)
  }

  /**
   * 获取步数统计
   */
  async getStepStatistics(date?: string): Promise<ApiResponse<StepStatistics>> {
    const endpoint = date ? `/steps/statistics?date=${date}` : '/steps/statistics'
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    
    return await this.request<StepStatistics>(endpoint, options)
  }

  /**
   * 获取排行榜
   */
  async getRankingList(type: 'daily' | 'weekly' | 'monthly'): Promise<ApiResponse<RankingItem[]>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    
    return await this.request<RankingItem[]>(`/ranking/${type}`, options)
  }

  /**
   * 步数兑换积分
   */
  async exchangePoints(steps: number): Promise<ApiResponse<ExchangeResponse>> {
    const requestData: ExchangeRequest = {
      steps: steps
    }
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }
    
    return await this.request<ExchangeResponse>('/exchange/points', options)
  }

  /**
   * 获取所有兑换记录
   */
  async getAllExchangeRecords(): Promise<ApiResponse<ExchangeRecord[]>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    
    return await this.request<ExchangeRecord[]>('/exchange/records', options)
  }

  /**
   * 上传步数（别名方法，与uploadStepData保持一致）
   */
  async uploadSteps(steps: number, date: string): Promise<ApiResponse<void>> {
    return this.uploadStepData(steps, date)
  }

  /**
   * 获取模拟数据（开发测试用）
   */
  private getMockResponse<T>(endpoint: string): ApiResponse<T> {
    console.log('Using mock data for:', endpoint)
    
    // 为mock数据创建显式类型
    interface MockLoginResponse {
      token: string;
      userInfo: UserInfo;
      expiresIn: number;
    }

    // 创建mock用户信息
    const mockUserInfo: UserInfo = {
      id: 123,
      username: 'testuser',
      email: 'test@example.com',
      nickname: '测试用户',
      totalSteps: 15000,
      totalPoints: 150,
      remainingSteps: 8500
    }

    const newUserInfo: UserInfo = {
      id: 123,
      username: 'newuser',
      email: 'new@example.com',
      nickname: '新用户',
      totalSteps: 0,
      totalPoints: 0,
      remainingSteps: 0
    }

    const mockLoginResponse: MockLoginResponse = {
      token: 'mock-jwt-token-123456',
      userInfo: mockUserInfo,
      expiresIn: 7200
    }

    const newUserLoginResponse: MockLoginResponse = {
      token: 'mock-jwt-token-123456',
      userInfo: newUserInfo,
      expiresIn: 7200
    }

    // 根据不同的端点返回不同的模拟数据
    const mockResponses: Record<string, ApiResponse<MockLoginResponse | UserInfo | void>> = {
      '/user/login': {
        code: 1,
        message: '登录成功',
        data: mockLoginResponse
      } as ApiResponse<MockLoginResponse>,
      '/user/register': {
        code: 1,
        message: '注册成功',
        data: newUserLoginResponse
      } as ApiResponse<MockLoginResponse>,
      '/user/send-code': {
        code: 1,
        message: '验证码发送成功',
        data: undefined
      } as ApiResponse<void>,
      '/user': {
        code: 1,
        message: '获取成功',
        data: mockUserInfo
      } as ApiResponse<UserInfo>
    }
    
    // 默认响应
    const defaultResponse: ApiResponse<T> = {
      code: 1,
      message: 'Mock response',
      data: undefined
    } as ApiResponse<T>
    
    // 获取响应数据
    const response = mockResponses[endpoint] || defaultResponse
    
    // 返回类型化的响应
    return response as ApiResponse<T>
  }
}

// 创建 API 客户端实例
export const ApiClient = ApiClientImpl.getInstance()

// 导出默认实例
export default ApiClient