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
  ExchangeRecord,
  PointRule,
  ExchangePreview,
  ExtendedProduct
} from '../types/common'

// 积分响应接口
interface PointsResponse {
  totalPoints: number
}

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
  public enableMock: boolean = AppConfig.enableMock
  public enableLog: boolean = AppConfig.enableLog

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
    // 禁用Mock数据，始终使用真实后端API
    if (false) {
      // Mock数据功能已禁用
      return this.getMockResponse<T>(endpoint)
    }

    const httpRequest = http.createHttp()
    const url = `${this.baseUrl}${endpoint}`

    try {
      // 设置请求头
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      }

      // 如果存在 JWT Token,添加到 Authorization 头
      console.log('=== Token Debug Info ===')
      console.log('jwtToken exists:', !!this.jwtToken)
      console.log('jwtToken value:', this.jwtToken ? this.jwtToken.substring(0, 20) + '...' : 'null')
      console.log('jwtToken length:', this.jwtToken?.length || 0)

      if (this.jwtToken) {
        headers['Authorization'] = `Bearer ${this.jwtToken}`
        console.log('Authorization header set:', headers['Authorization'].substring(0, 30) + '...')
      } else {
        console.warn('⚠️ WARNING: No token available! Request will fail authentication!')
      }
      console.log('========================')

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
   * 创建错误响应（避免使用unknown类型）
   */
  private createErrorResponse<T>(code: number, message: string): ApiResponse<T> {
    const errorResponse: ApiResponse<T> = {
      code: code,
      message: message,
      data: undefined as T
    }
    return errorResponse
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

    const response = await this.request<string>('/user/login', options)

    // 后端返回的data是直接token字符串，不是对象
    console.log('=== Login Response Debug ===')
    console.log('response.code:', response.code)
    console.log('response.message:', response.message)
    console.log('typeof response.data:', typeof response.data)
    console.log('response.data value:', response.data ? (typeof response.data === 'string' ? response.data.substring(0, 30) + '...' : JSON.stringify(response.data)) : 'null')

    // 如果登录成功,保存 Token (后端直接返回token字符串)
    if (response.code === 1 && response.data && typeof response.data === 'string') {
      console.log('✅ Saving token to ApiClient...')
      this.setToken(response.data)
      console.log('✅ Token saved! Current token length:', this.jwtToken.length)
      
      // 登录成功后，立即获取用户信息
      console.log('🔄 Fetching user info after login...')
      try {
        const userInfoResponse = await this.getUserInfo()
        if (userInfoResponse.code === 1 && userInfoResponse.data) {
          console.log('✅ User info fetched successfully:', userInfoResponse.data.username)
          // 将用户信息包装到LoginResponse中
          const loginResponse: ApiResponse<LoginResponse> = {
            code: response.code,
            message: response.message,
            data: new LoginResponse(response.data, userInfoResponse.data, 7200)
          }
          return loginResponse
        }
      } catch (error) {
        console.error('❌ Failed to fetch user info:', error)
      }
    } else {
      console.error('❌ Login failed or no token in response!')
      console.error('response.data type:', typeof response.data)
      console.error('response.data value:', response.data)
    }
    console.log('===========================')

    // 为了兼容前端其他代码,将字符串token包装成LoginResponse对象
    const loginResponse: ApiResponse<LoginResponse> = {
      code: response.code,
      message: response.message,
      data: new LoginResponse(response.data || '', {} as UserInfo, 7200)
    }

    return loginResponse
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

    const response = await this.request<string>('/user/login-by-code', options)

    // 后端返回的data是直接token字符串，不是对象
    console.log('=== Login By Code Response Debug ===')
    console.log('response.code:', response.code)
    console.log('typeof response.data:', typeof response.data)

    // 如果登录成功,保存 Token (后端直接返回token字符串)
    if (response.code === 1 && response.data && typeof response.data === 'string') {
      console.log('✅ Saving token to ApiClient...')
      this.setToken(response.data)
      console.log('✅ Token saved! Current token length:', this.jwtToken.length)
      
      // 登录成功后，立即获取用户信息
      console.log('🔄 Fetching user info after login...')
      try {
        const userInfoResponse = await this.getUserInfo()
        if (userInfoResponse.code === 1 && userInfoResponse.data) {
          console.log('✅ User info fetched successfully:', userInfoResponse.data.username)
          // 将用户信息包装到LoginResponse中
          const loginResponse: ApiResponse<LoginResponse> = {
            code: response.code,
            message: response.message,
            data: new LoginResponse(response.data, userInfoResponse.data, 7200)
          }
          return loginResponse
        }
      } catch (error) {
        console.error('❌ Failed to fetch user info:', error)
      }
    } else {
      console.error('❌ Login failed or no token in response!')
    }
    console.log('=====================================')

    // 为了兼容前端其他代码,将字符串token包装成LoginResponse对象
    const loginResponse: ApiResponse<LoginResponse> = {
      code: response.code,
      message: response.message,
      data: new LoginResponse(response.data || '', {} as UserInfo, 7200)
    }

    return loginResponse
  }

  /**
   * 用户注册
   */
  async register(username: string, email: string, code: string, password?: string): Promise<ApiResponse<void>> {
    // 构建请求数据，如果提供了密码则包含该字段
    if (password) {
      const requestData: RegisterRequest = {
        username: username,
        email: email,
        verification: code,
        password: password
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify(requestData)
      }

      const response = await this.request<void>('/user/register', options)

      // 注册接口后端只返回success消息,不返回token
      // 注册成功后应该跳转到登录页面,而不是自动登录
      console.log('=== Register Response Debug ===')
      console.log('response.code:', response.code)
      console.log('response.message:', response.message)
      console.log('Note: Register endpoint does not return token, user should login after registration')
      console.log('==================================')

      return response
    } else {
      // 定义注册请求接口（不包含密码字段）
      interface RegisterWithoutPassword {
        username: string;
        email: string;
        verification: string;
      }

      const requestData: RegisterWithoutPassword = {
        username: username,
        email: email,
        verification: code
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify(requestData)
      }

      const response = await this.request<void>('/user/register', options)

      // 注册接口后端只返回success消息,不返回token
      // 注册成功后应该跳转到登录页面,而不是自动登录
      console.log('=== Register Response Debug ===')
      console.log('response.code:', response.code)
      console.log('response.message:', response.message)
      console.log('Note: Register endpoint does not return token, user should login after registration')
      console.log('==================================')

      return response
    }
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

    // 后端路径是 /user/send-verification, 不是 /user/send-code
    return await this.request<void>('/user/send-verification', options)
  }

  /**
   * 获取用户信息
   */
  async getUserInfo(): Promise<ApiResponse<UserInfo>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    // 后端返回的字段名是 totalStep, remainingStep (单数)
    // 前端期望的字段名是 totalSteps, remainingSteps (复数)
    // 需要在接收到数据后进行转换
    interface BackendUserVo {
      id: number;
      username: string;
      email: string;
      nickname: string;
      sex?: number;
      avatar?: string;
      totalStep: number;        // 后端字段名
      totalPoints: number;
      remainingStep: number;    // 后端字段名
      maxDailySteps?: number;
      updateTime?: string;
    }

    const response = await this.request<BackendUserVo>('/user/info', options)

    // 转换字段名
    if (response.code === 1 && response.data) {
      const userInfo: UserInfo = {
        id: response.data.id,
        username: response.data.username,
        email: response.data.email,
        nickname: response.data.nickname,
        sex: response.data.sex,
        avatar: response.data.avatar,
        totalSteps: response.data.totalStep,       // 转换: totalStep -> totalSteps
        totalPoints: response.data.totalPoints,
        remainingSteps: response.data.remainingStep // 转换: remainingStep -> remainingSteps
      }

      return {
        code: response.code,
        message: response.message,
        data: userInfo
      }
    }

    // 如果响应失败，返回错误响应
    interface ErrorResponse {
      code: number;
      message: string;
      data: undefined;
    }

    const errorResponse: ErrorResponse = {
      code: response.code,
      message: response.message,
      data: undefined
    }

    return this.createErrorResponse<UserInfo>(response.code, response.message)
  }

  /**
   * 更新用户信息
   */
  async updateUserInfo(userInfo: Partial<UserInfo>): Promise<ApiResponse<UserInfo>> {
    // 转换前端字段为后端字段
    interface BackendChangeInfoDto {
      nickname?: string;
      email?: string;
      sex?: number;
      avatar?: string;
    }

    const requestData: BackendChangeInfoDto = {
      nickname: userInfo.nickname,
      email: userInfo.email,
      sex: userInfo.sex,
      avatar: userInfo.avatar
    }

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.PUT,
      extraData: JSON.stringify(requestData)
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

    // 后端路径是 /user/steps/upload
    return await this.request<void>('/user/steps/upload', options)
  }

  /**
   * 获取步数统计
   */
  async getStepStatistics(date?: string): Promise<ApiResponse<StepStatistics>> {
    // 后端路径是 /user/steps/statistics
    const endpoint = date ? `/user/steps/statistics?date=${date}` : '/user/steps/statistics'
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    return await this.request<StepStatistics>(endpoint, options)
  }

  /**
   * 获取排行榜
   */
  async getRankingList(type: 'daily' | 'weekly' | 'monthly'): Promise<ApiResponse<RankingItem[]>> {
    // 后端路径是 /user/rankings,参数是 periodType, 不是 /ranking/{type}
    const periodType = type === 'daily' ? 'day' : type === 'weekly' ? 'week' : 'month'
    const endpoint = `/user/rankings?periodType=${periodType}&pageNum=1&pageSize=100`

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    return await this.request<RankingItem[]>(endpoint, options)
  }

  /**
   * 获取当前用户在指定周期的排名
   */
  async getUserRanking(periodType: 'daily' | 'weekly' | 'monthly' = 'monthly'): Promise<ApiResponse<RankingItem | null>> {
    // 转换周期类型
    const backendPeriodType = periodType === 'daily' ? 'day' : periodType === 'weekly' ? 'week' : 'month'
    const endpoint = `/user/ranking/my?periodType=${backendPeriodType}`

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    return await this.request<RankingItem | null>(endpoint, options)
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

    // PointsController在Mall服务中, 路径是 /points/exchange
    return await this.request<ExchangeResponse>('/points/exchange', options)
  }

  /**
   * 获取积分兑换规则
   */
  async getPointRules(): Promise<ApiResponse<PointRule[]>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    return await this.request<PointRule[]>('/points/rules', options)
  }

  /**
   * 预览兑换结果
   */
  async previewExchange(steps: number): Promise<ApiResponse<ExchangePreview>> {
    const requestData: ExchangeRequest = {
      steps: steps
    }

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }

    return await this.request<ExchangePreview>('/points/preview', options)
  }

  /**
   * 获取所有兑换记录
   */
  async getAllExchangeRecords(): Promise<ApiResponse<ExchangeRecord[]>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    // 后端路径是 /user/exchange/records
    return await this.request<ExchangeRecord[]>('/user/exchange/records', options)
  }

  /**
   * 获取用户积分 (新增)
   */
  async getUserPoints(): Promise<ApiResponse<PointsResponse>> {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }

    return await this.request<PointsResponse>('/user/points', options)
  }

  /**
   * 上传步数（别名方法，与uploadStepData保持一致）
   */
  async uploadSteps(steps: number, date: string): Promise<ApiResponse<void>> {
    return this.uploadStepData(steps, date)
  }

  /**
   * 获取步数趋势数据（数据分析）
   */
  async getStepTrend(days: number = 7): Promise<ApiResponse<StepRecord[]>> {
    const endpoint = `/user/steps/trend?days=${days}`
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    return await this.request<StepRecord[]>(endpoint, options)
  }

  /**
   * 获取步数记录列表（用于RecordPage）
   */
  async getStepRecords(pageNum: number = 1, pageSize: number = 20): Promise<ApiResponse<StepRecord[]>> {
    const endpoint = `/user/steps/records?pageNum=${pageNum}&pageSize=${pageSize}`
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    return await this.request<StepRecord[]>(endpoint, options)
  }

  /**
   * 获取商品列表
   */
  async getProducts(): Promise<ApiResponse<ExtendedProduct[]>> {
    console.log('=== ApiClient: 开始请求商品列表 ===')
    // 添加时间戳参数避免缓存
    const timestamp = new Date().getTime()
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      }
    }
  
    // 后端返回的是MallGoods对象，需要转换为前端期望的 ExtendedProduct格式
    interface BackendMallGoods {
      id: number;
      goodsName: string;
      requiredPoints: number;
      coverUrl?: string;
      displayNum?: number;
      stock?: number;
      salesCount?: number;
      isDeleted?: number;
      createTime?: string;
      updateTime?: string;
    }
  
    // 添加时间戳避免缓存
    const response = await this.request<BackendMallGoods[]>(`/mall/products?t=${timestamp}`, options)
    
    console.log('ApiClient: 后端响应 - code:', response.code)
    console.log('ApiClient: 后端响应 - message:', response.message)
    console.log('ApiClient: 后端响应 - data:', response.data ? response.data.length : 'null', '个商品')

    // 转换字段名和数据结构
    if (response.code === 1 && response.data) {
      console.log('ApiClient: 开始转换数据...')
      console.log('ApiClient: 后端返回的原始数据:', JSON.stringify(response.data))
      const products: ExtendedProduct[] = []
      for (const goods of response.data) {
        console.log('ApiClient: 处理商品 - ID:', goods.id, '名称:', goods.goodsName, 'stock:', goods.stock, 'displayNum:', goods.displayNum)
        const product: ExtendedProduct = {
          id: goods.id,
          name: goods.goodsName,
          description: '精美商品，欢迎兑换',
          points: goods.requiredPoints,
          pointsRequired: goods.requiredPoints,
          image: goods.coverUrl || '',
          stock: goods.stock !== undefined && goods.stock !== null ? goods.stock : 0,  // 直接使用stock字段作为库存
          type: 'physical',
          category: 'mall'
        }
        console.log('ApiClient: 转换后商品 - ID:', product.id, '名称:', product.name, '库存:', product.stock)
        products.push(product)
      }
      console.log('ApiClient: 转换完成，共', products.length, '个商品')
      if (products.length > 0) {
        console.log('ApiClient: 第一个商品示例 - ID:', products[0].id, '名称:', products[0].name, '库存:', products[0].stock)
      }

      const result: ApiResponse<ExtendedProduct[]> = {
        code: response.code,
        message: response.message,
        data: products
      }
      return result
    }

    console.warn('ApiClient: 响应失败或无数据，返回空数组')
    // 返回空数组而不是直接转换类型
    const emptyResult: ApiResponse<ExtendedProduct[]> = {
      code: response.code,
      message: response.message,
      data: []
    }
    return emptyResult
  }

  /**
   * 兑换商品
   */
  async exchangeProduct(productId: number, points: number): Promise<ApiResponse<ExchangeResponse>> {
    console.log('=== ApiClient: 开始兑换商品 ===')
    console.log('ApiClient: productId:', productId)
    console.log('ApiClient: points:', points)
    
    interface ProductExchangeRequest {
      goodsId: number;  // 后端期望的字段名是goodsId
    }

    const requestData: ProductExchangeRequest = {
      goodsId: productId  // 使用goodsId而非productId
    }

    console.log('ApiClient: 请求数据:', JSON.stringify(requestData))

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify(requestData)
    }

    // 后端路径是 /mall/products/exchange
    console.log('ApiClient: 请求URL: /mall/products/exchange')
    const result = await this.request<ExchangeResponse>('/mall/products/exchange', options)
    
    console.log('ApiClient: 响应结果 - code:', result.code, 'message:', result.message)
    console.log('=== ApiClient: 兑换请求完成 ===')
    
    return result
  }

  /**
   * 获取兑换记录列表（包含步数记录和积分兑换记录）
   */
  async getExchangeRecords(pageNum: number = 1, pageSize: number = 20): Promise<ApiResponse<ExchangeRecord[]>> {
    const endpoint = `/user/exchange/records?pageNum=${pageNum}&pageSize=${pageSize}`
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET
    }
    return await this.request<ExchangeRecord[]>(endpoint, options)
  }

  /**
   * 获取模拟数据（开发测试用）
   */
  private getMockResponse<T>(endpoint: string): ApiResponse<T> {
    console.log('Using mock data for:', endpoint)

    // 为mock数据创建显示类型
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
      },
      '/user/register': {
        code: 1,
        message: '注册成功',
        data: newUserLoginResponse
      },
      '/user/send-verification': {
        code: 1,
        message: '验证码发送成功',
        data: undefined
      },
      '/user': {
        code: 1,
        message: '获取成功',
        data: mockUserInfo
      }
    }

    // 默认响应
    const defaultResponse: ApiResponse<T> = {
      code: 1,
      message: 'Mock response',
      data: undefined
    } as ApiResponse<T>

    // 获取响应数据 - 使用类型安全的访问
    const response: ApiResponse<MockLoginResponse | UserInfo | void> | undefined = mockResponses[endpoint]
    if (response) {
      return response as ApiResponse<T>
    }

    return defaultResponse
  }
}

// 创建 API 客户端实例
export const ApiClient = ApiClientImpl.getInstance()

// 导出默认实例
export default ApiClient