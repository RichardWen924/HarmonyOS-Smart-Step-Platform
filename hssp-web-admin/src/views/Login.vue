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
            <h2>{{ isLogin ? '欢迎回来' : '快速注册' }}</h2>
            <p>{{ isLogin ? '请登录您的管理端账号以继续' : '创建一个新的管理员账号' }}</p>
          </div>

          <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @keyup.enter="handleSubmit">
            <template v-if="isLogin">
              <el-form-item label="用户名 / 邮箱" prop="username">
                <el-input v-model="form.username" placeholder="输入您的账号" :prefix-icon="User" />
              </el-form-item>
              <el-form-item label="密码" prop="password">
                <el-input v-model="form.password" type="password" show-password placeholder="输入密码" :prefix-icon="Lock" />
              </el-form-item>
            </template>

            <template v-else>
              <el-form-item label="注册邮箱" prop="email">
                <el-input v-model="form.email" placeholder="example@domain.com" :prefix-icon="Message" />
              </el-form-item>
              <el-form-item label="验证码" prop="verification">
                <div class="code-row">
                  <el-input v-model="form.verification" placeholder="验证码" :prefix-icon="Checked" />
                  <el-button 
                    @click="handleSendCode" 
                    :disabled="isSending" 
                    :loading="sending"
                    class="send-code-btn"
                  >
                    {{ sendBtnText }}
                  </el-button>
                </div>
              </el-form-item>
              <el-form-item label="设置新密码" prop="newPassword">
                <el-input v-model="form.newPassword" type="password" show-password placeholder="请设置登录密码" :prefix-icon="Lock" />
              </el-form-item>
            </template>

            <div class="form-actions">
              <el-button type="primary" class="main-btn" :loading="loading" @click="handleSubmit">
                {{ isLogin ? '立即进入' : '完成注册' }}
              </el-button>
              
              <div class="divider">
                <span>或者</span>
              </div>

              <el-button v-if="isLogin" type="default" class="preview-btn" @click="handlePreview">
                快速预览体验
              </el-button>
            </div>
          </el-form>

          <div class="form-footer">
            <span>{{ isLogin ? '还没有账号？' : '已经有账号？' }}</span>
            <a @click="toggleMode" class="toggle-link">{{ isLogin ? '立即注册' : '返回登录' }}</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { User, Lock, Message, Checked, TrendCharts } from '@element-plus/icons-vue';
import { login, register, sendVerification } from '../api/auth';
import { useUserStore } from '../stores/user';

const router = useRouter();
const userStore = useUserStore();

const isLogin = ref(true);
const loading = ref(false);
const sending = ref(false);
const sendTimer = ref(null);
const countdown = ref(0);

const formRef = ref(null);
const form = reactive({
  username: '',
  password: '',
  email: '',
  verification: '',
  newPassword: ''
});

const rules = computed(() => {
  if (isLogin.value) {
    return {
      username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
      password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
    };
  } else {
    return {
      email: [
        { required: true, message: '请输入邮箱', trigger: 'blur' },
        { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
      ],
      verification: [{ required: true, message: '请输入验证码', trigger: 'blur' }],
      newPassword: [{ required: true, message: '请设置密码', trigger: 'blur' }]
    };
  }
});

const isSending = computed(() => countdown.value > 0);
const sendBtnText = computed(() => isSending.value ? `${countdown.value}s` : '发送验证码');

const toggleMode = () => {
  isLogin.value = !isLogin.value;
  formRef.value?.resetFields();
};

const handleSendCode = async () => {
  if (!form.email) {
    ElMessage.warning('请先输入邮箱');
    return;
  }
  formRef.value?.validateField('email', async (valid) => {
    if (valid) {
      try {
        sending.value = true;
        await sendVerification(form.email);
        ElMessage.success('验证码发送成功');
        countdown.value = 60;
        sendTimer.value = setInterval(() => {
          countdown.value--;
          if (countdown.value <= 0) {
            clearInterval(sendTimer.value);
          }
        }, 1000);
      } catch (e) {
        // request.js already throws and shows error
      } finally {
        sending.value = false;
      }
    }
  });
};

const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true;
      try {
        if (isLogin.value) {
          const res = await login({ username: form.username, password: form.password });
          const token = res.data?.token || res.data; // assume token is inside data
          if (token) {
             userStore.setToken(typeof token === 'string' ? token : token.token);
             ElMessage.success('登录成功');
             router.push('/points-rule');
          } else {
             ElMessage.error('登录响应中未发现 Token');
          }
        } else {
          await register({ email: form.email, verification: form.verification, password: form.newPassword });
          ElMessage.success('注册成功，请登录');
          toggleMode();
        }
      } catch (e) {
         // handled by request.js
      } finally {
        loading.value = false;
      }
    }
  });
};

// 临时预览函数
const handlePreview = () => {
  userStore.setToken('preview_token');
  ElMessage.success('已进入预览模式');
  router.push('/points-rule');
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
  background-color: #1e293b;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #fff;
  padding: 40px;
  position: relative;
  overflow: hidden;
}

.login-left::after {
  content: "";
  position: absolute;
  top: -20%;
  right: -20%;
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, rgba(59, 130, 246, 0.2) 0%, transparent 70%);
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
  background-color: #f1f5f9;
  box-shadow: none !important;
  border: 1px solid transparent;
  border-radius: 10px;
  padding: 0 12px;
  height: 44px;
  transition: all 0.3s;
}

:deep(.el-input__wrapper.is-focus) {
  background-color: #fff;
  border-color: #3b82f6;
}

:deep(.el-input__prefix-icon) {
  color: #94a3b8;
}

.code-row {
  display: flex;
  gap: 12px;
  width: 100%;
}

.send-code-btn {
  height: 44px !important;
  border-radius: 10px !important;
  min-width: 100px;
}

.form-actions {
  margin-top: 32px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.main-btn {
  height: 48px !important;
  border-radius: 12px !important;
  font-size: 16px !important;
  font-weight: 600 !important;
  box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3) !important;
}

.preview-btn {
  height: 48px !important;
  border-radius: 12px !important;
  font-weight: 500 !important;
  border: 1px dashed #cbd5e1 !important;
  color: #64748b !important;
}

.divider {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  margin: 4px 0;
}

.divider::before, .divider::after {
  content: "";
  flex: 1;
  height: 1px;
  background-color: #e2e8f0;
}

.divider span {
  font-size: 12px;
  color: #94a3b8;
}

.form-footer {
  margin-top: 32px;
  text-align: center;
  font-size: 14px;
  color: #64748b;
}

.toggle-link {
  color: #3b82f6;
  font-weight: 600;
  cursor: pointer;
  margin-left: 4px;
  text-decoration: none;
  transition: opacity 0.2s;
}

.toggle-link:hover {
  opacity: 0.8;
}

@media (max-width: 768px) {
  .login-box {
    width: 400px;
    min-height: auto;
  }
  .login-left {
    display: none;
  }
}
</style>
