import ApiClient from './entry/src/main/ets/services/ApiClient'

// 测试API客户端功能
async function testApiClient() {
  console.log('Testing ApiClient...')
  
  try {
    // 测试登录功能
    const loginResponse = await ApiClient.loginByPassword('test@example.com', 'password123')
    console.log('Login response:', loginResponse)
    
    // 测试获取用户信息
    const userInfoResponse = await ApiClient.getUserInfo()
    console.log('User info response:', userInfoResponse)
    
    console.log('API Client test completed successfully!')
  } catch (error) {
    console.error('API Client test failed:', error)
  }
}

// 执行测试
testApiClient()