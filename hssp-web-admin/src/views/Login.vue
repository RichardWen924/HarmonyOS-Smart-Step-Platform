<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-left">
        <div class="welcome-content">
          <el-icon class="welcome-icon" :size="64"><TrendCharts /></el-icon>
          <h1>步数积分管理系统</h1>
          <p>高效管理您的步数兑换规则与用户积分数据</p>
        </div>
      </div>
      <div class="login-right">
        <div class="form-wrapper">
          <div class="form-header">
            <h2>欢迎回来</h2>
            <p>请登录您的管理端账号以继续</p>
          </div>

          <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @keyup.enter="handleSubmit">
            <el-form-item label="用户名 / 邮箱" prop="username">
              <el-input v-model="form.username" placeholder="输入您的账号" :prefix-icon="User" />
            </el-form-item>
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" type="password" show-password placeholder="输入密码" :prefix-icon="Lock" />
            </el-form-item>

            <div class="form-actions">
              <el-button type="primary" class="main-btn" :loading="loading" @click="handleSubmit">
                立即进入
              </el-button>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { User, Lock, TrendCharts } from '@element-plus/icons-vue';
import { login } from '../api/auth';
import { useUserStore } from '../stores/user';

const router = useRouter();
const userStore = useUserStore();

const loading = ref(false);

const formRef = ref(null);
const form = reactive({
  username: '',
  password: ''
});

const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
};

const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true;
      try {
        const res = await login({ username: form.username, password: form.password });
        const token = res.data?.token || res.data; // assume token is inside data
        if (token) {
           userStore.setToken(typeof token === 'string' ? token : token.token);
           ElMessage.success('登录成功');
           router.push('/points-rule');
        } else {
           ElMessage.error('登录响应中未发现 Token');
        }
      } catch (e) {
         // handled by request.js
      } finally {
        loading.value = false;
      }
    }
  });
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f8fafc;
  background-image: radial-gradient(at 0% 0%, hsla(210, 100%, 93%, 1) 0, transparent 50%), 
                    radial-gradient(at 50% 0%, hsla(210, 100%, 95%, 1) 0, transparent 50%), 
                    radial-gradient(at 100% 0%, hsla(210, 100%, 93%, 1) 0, transparent 50%);
}

.login-box {
  display: flex;
  width: 900px;
  max-width: 95vw;
  min-height: 600px;
  background-color: #fff;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
}

.login-left {
  flex: 1.1;
  background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  color: #fff;
  padding: 40px;
  position: relative;
  overflow: hidden;
}

.login-left::before {
  content: "";
  position: absolute;
  top: -10%;
  left: -10%;
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(59, 130, 246, 0.1) 0%, transparent 70%);
  border-radius: 50%;
}

.login-left::after {
  content: "";
  position: absolute;
  bottom: -10%;
  right: -10%;
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, rgba(37, 99, 235, 0.15) 0%, transparent 70%);
  border-radius: 50%;
}

.welcome-content {
  text-align: center;
  z-index: 10;
}

.welcome-icon {
  margin-bottom: 24px;
  color: #3b82f6;
  filter: drop-shadow(0 0 15px rgba(59, 130, 246, 0.5));
}

.welcome-content h1 {
  font-size: 28px;
  margin-bottom: 16px;
  font-weight: 700;
  letter-spacing: 1px;
}

.welcome-content p {
  font-size: 16px;
  color: #94a3b8;
  line-height: 1.6;
}

.login-right {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
}

.form-wrapper {
  width: 100%;
  max-width: 360px;
  padding: 40px 20px;
}

.form-header {
  margin-bottom: 32px;
}

.form-header h2 {
  font-size: 24px;
  color: #1e293b;
  margin-bottom: 8px;
  font-weight: 600;
}

.form-header p {
  font-size: 14px;
  color: #64748b;
}

:deep(.el-form-item__label) {
  font-size: 13px;
  font-weight: 600;
  color: #475569;
  margin-bottom: 4px;
}

:deep(.el-input__wrapper) {
  background-color: #f8fafc;
  box-shadow: none !important;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 0 16px;
  height: 48px;
  transition: all 0.3s;
}

:deep(.el-input__wrapper.is-focus) {
  background-color: #fff;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1) !important;
}

:deep(.el-input__prefix-icon) {
  color: #64748b;
  font-size: 18px;
}

.form-actions {
  margin-top: 16px;
}

.main-btn {
  width: 100%;
  height: 48px !important;
  border-radius: 12px !important;
  font-size: 16px !important;
  font-weight: 600 !important;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%) !important;
  border: none !important;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3) !important;
  transition: all 0.3s !important;
}

.main-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4) !important;
}

@media (max-width: 768px) {
  .login-box {
    width: 400px;
    min-height: auto;
    margin: 20px;
  }
  .login-left {
    display: none;
  }
}
</style>
