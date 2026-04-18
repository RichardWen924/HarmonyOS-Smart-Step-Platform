import axios from 'axios';
import { ElMessage } from 'element-plus';
import { useUserStore } from '../stores/user';
import router from '../router';

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '',
  timeout: 10000,
});

request.interceptors.request.use(
  (config) => {
    const userStore = useUserStore();
    // 如果是登录接口，不加 Authorization 头，避免旧的/非法 token 导致 403
    if (userStore.token && !config.url.endsWith('/login')) {
      config.headers.Authorization = 'Bearer ' + userStore.token;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

request.interceptors.response.use(
  (response) => {
    const res = response.data;
    if (res.code !== 1) {
      ElMessage.error(res.msg || '请求失败');
      return Promise.reject(new Error(res.msg || '错误'));
    }
    return res;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      const userStore = useUserStore();
      userStore.logout();
      router.push('/login');
      ElMessage.error('登录已过期或未授权，请重新登录。');
    } else {
      ElMessage.error(error.message || '网络错误');
    }
    return Promise.reject(error);
  }
);

export default request;
