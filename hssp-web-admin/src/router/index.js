import { createRouter, createWebHistory } from 'vue-router';
import { useUserStore } from '../stores/user';

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/points-rule',
    name: 'PointsRule',
    component: () => import('../views/PointsRule.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/user-manage',
    name: 'UserManage',
    component: () => import('../views/UserManage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/goods-manage',
    name: 'GoodsManage',
    component: () => import('../views/GoodsManage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/',
    redirect: '/points-rule'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach((to, from, next) => {
  const userStore = useUserStore();
  const token = userStore.token;

  if (to.meta.requiresAuth && !token) {
    next({ name: 'Login' });
  } else if (to.name === 'Login' && token) {
    next({ name: 'PointsRule' }); // Prevent logged-in users from going to login page
  } else {
    next();
  }
});

export default router;
