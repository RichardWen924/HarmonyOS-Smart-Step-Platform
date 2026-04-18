<template>
  <div class="side-nav">
    <div class="logo">
      <el-icon :size="24" color="#409EFF"><TrendCharts /></el-icon>
      <span>步数积分管理系统</span>
    </div>
    <el-menu
      :default-active="activeMenu"
      class="el-menu-vertical"
      @select="handleMenuSelect"
    >
      <el-menu-item index="1">
        <el-icon><List /></el-icon>
        <span>积分规则管理</span>
      </el-menu-item>
      <el-menu-item index="2">
        <el-icon><User /></el-icon>
        <span>用户管理</span>
      </el-menu-item>
    </el-menu>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { List, User, TrendCharts } from '@element-plus/icons-vue';

const route = useRoute();
const router = useRouter();

// 根据当前路由决定激活的菜单项
const activeMenu = computed(() => {
  if (route.path.includes('points-rule')) return '1';
  if (route.path.includes('user-manage')) return '2';
  return '1';
});

const handleMenuSelect = (index) => {
  if (index === '1') router.push('/points-rule');
  if (index === '2') router.push('/user-manage');
};
</script>

<style scoped>
.side-nav {
  width: 260px;
  background-color: #1e293b;
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 10px rgba(0, 0, 0, 0.05);
  z-index: 100;
  height: 100vh;
}

.logo {
  height: 72px;
  display: flex;
  align-items: center;
  padding: 0 24px;
  gap: 12px;
  font-size: 18px;
  font-weight: 700;
  color: #f8fafc;
  background-color: rgba(255, 255, 255, 0.05);
}

.el-menu-vertical {
  border-right: none;
  flex: 1;
  background-color: transparent;
  padding-top: 16px;
}

:deep(.el-menu-item) {
  height: 50px;
  line-height: 50px;
  margin: 4px 12px;
  border-radius: 8px;
  color: #94a3b8;
}

:deep(.el-menu-item.is-active) {
  background-color: #3b82f6 !important;
  color: #ffffff !important;
}

:deep(.el-menu-item:hover) {
  background-color: rgba(255, 255, 255, 0.1);
  color: #f8fafc;
}
</style>
