import http from '@ohos.net.http'

// 定义类型
export class NetworkDiagnosticResult {
  deviceNetwork: boolean = false
  backendConnection: boolean = false
  apiEndpoints: ApiEndpointStatus[] = []
  suggestions: string[] = []
}

export class ApiEndpointStatus {
  endpoint: string = ''
  available: boolean = false
  statusCode?: number
}

export class EndpointConfig {
  path: string = ''
  method: string = ''
}

/**
 * 网络连接测试工具
 */
export class NetworkTest {
  
  /**
   * 测试基础网络连接
   */
  static async testBasicConnectivity(): Promise<void> {
    console.log('=== 开始网络连接测试 ===')
    
    // 测试1: 检查设备网络状态
    await NetworkTest.testDeviceNetwork()
    
    // 测试2: 测试后端服务连接
    await NetworkTest.testBackendConnection()
    
    // 测试3: 测试具体API端点
    await NetworkTest.testApiEndpoints()
    
    console.log('=== 网络连接测试完成 ===')
  }
  
  /**
   * 测试设备网络状态
   */
  private static async testDeviceNetwork(): Promise<void> {
    console.log('测试1: 检查设备网络状态')
    
    try {
      // 测试访问一个已知的公共网站
      const httpRequest = http.createHttp()
      const response = await httpRequest.request('http://www.baidu.com/', {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      
      httpRequest.destroy()
      
      if (response.responseCode === 200) {
        console.log('✅ 设备网络连接正常')
      } else {
        console.log(`⚠️ 设备网络连接异常，状态码: ${response.responseCode}`)
      }
      
    } catch (error) {
      console.error('❌ 设备网络连接测试失败:', error.message)
      console.log('建议: 请检查设备的网络连接设置')
    }
  }
  
  /**
   * 测试后端服务连接
   */
  private static async testBackendConnection(): Promise<void> {
    console.log('测试2: 测试后端服务连接')
    
    const testUrls: string[] = []
    testUrls.push('http://192.168.59.116:8082/')
    testUrls.push('http://192.168.59.116:8082/user')
    testUrls.push('http://192.168.59.116:8082/user/login')
    
    for (const url of testUrls) {
      try {
        const httpRequest = http.createHttp()
        const response = await httpRequest.request(url, {
          method: http.RequestMethod.GET,
          connectTimeout: 8000,
          readTimeout: 8000
        })
        
        httpRequest.destroy()
        
        console.log(`✅ ${url} - 连接成功 (状态码: ${response.responseCode})`)
        
      } catch (error) {
        console.error(`❌ ${url} - 连接失败:`, error.message)
        
        if (error.message.includes('NetworkError')) {
          console.log('   → 可能原因: 后端服务未启动或端口被占用')
        } else if (error.message.includes('timeout')) {
          console.log('   → 可能原因: 连接超时，后端服务可能未启动')
        } else {
          console.log('   → 可能原因: 网络配置问题')
        }
      }
    }
  }
  
  /**
   * 测试具体API端点
   */
  private static async testApiEndpoints(): Promise<void> {
    console.log('测试3: 测试具体API端点')
    
    const endpoints: EndpointConfig[] = []
    const endpoint1 = new EndpointConfig()
    endpoint1.path = '/user/login'
    endpoint1.method = 'POST'
    endpoints.push(endpoint1)
    
    const endpoint2 = new EndpointConfig()
    endpoint2.path = '/user/register'
    endpoint2.method = 'POST'
    endpoints.push(endpoint2)
    
    const endpoint3 = new EndpointConfig()
    endpoint3.path = '/user/send-code'
    endpoint3.method = 'POST'
    endpoints.push(endpoint3)
    
    const baseUrl = 'http://192.168.59.116:8082'
    
    for (const endpoint of endpoints) {
      const url = baseUrl + endpoint.path
      
      try {
        const httpRequest = http.createHttp()
        const response = await httpRequest.request(url, {
          method: http.RequestMethod.OPTIONS,
          connectTimeout: 5000,
          readTimeout: 5000
        })
        
        httpRequest.destroy()
        
        console.log(`✅ ${endpoint.path} - 端点可用 (状态码: ${response.responseCode})`)
        
      } catch (error) {
        console.error(`❌ ${endpoint.path} - 端点不可用:`, error.message)
      }
    }
  }
  
  /**
   * 获取详细的网络诊断信息
   */
  static async getNetworkDiagnostics(): Promise<NetworkDiagnosticResult> {
    const apiEndpoints: ApiEndpointStatus[] = []
    const suggestions: string[] = []
    
    let deviceNetwork = false
    let backendConnection = false
    
    // 测试设备网络
    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request('http://www.baidu.com/', {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      })
      httpRequest.destroy()
      deviceNetwork = response.responseCode === 200
    } catch (error) {
      suggestions.push('请检查设备网络连接')
    }
    
    // 测试后端连接
    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request('http://192.168.59.116:8082/', {
        method: http.RequestMethod.GET,
        connectTimeout: 8000,
        readTimeout: 8000
      })
      httpRequest.destroy()
      backendConnection = true
    } catch (error) {
      suggestions.push('后端服务可能未启动，请检查Spring Boot应用')
      suggestions.push('确认端口8082没有被其他程序占用')
      suggestions.push('检查防火墙设置，确保端口8082开放')
    }
    
    // 测试API端点
    const endpoints: string[] = []
    endpoints.push('/user/login')
    endpoints.push('/user/register')
    endpoints.push('/user/send-code')
    
    const baseUrl = 'http://192.168.59.116:8082'
    
    for (let i = 0; i < endpoints.length; i++) {
      const endpoint = endpoints[i]
      try {
        const httpRequest = http.createHttp()
        const response = await httpRequest.request(baseUrl + endpoint, {
          method: http.RequestMethod.POST,
          extraData: JSON.stringify({ test: 'connection' }),
          connectTimeout: 5000,
          readTimeout: 5000
        })
        httpRequest.destroy()
        
        const endpointStatus = new ApiEndpointStatus()
        endpointStatus.endpoint = endpoint
        endpointStatus.available = true
        endpointStatus.statusCode = response.responseCode
        apiEndpoints.push(endpointStatus)
      } catch (error) {
        const endpointStatus = new ApiEndpointStatus()
        endpointStatus.endpoint = endpoint
        endpointStatus.available = false
        apiEndpoints.push(endpointStatus)
      }
    }
    
    const result = new NetworkDiagnosticResult()
    result.deviceNetwork = deviceNetwork
    result.backendConnection = backendConnection
    result.apiEndpoints = apiEndpoints
    result.suggestions = suggestions
    
    return result
  }
}