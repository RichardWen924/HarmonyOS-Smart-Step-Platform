<template>
  <div class="user-manage-container">
    <SideBar />

    <div class="main-content">
      <div class="header-bar">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>管理中心</el-breadcrumb-item>
            <el-breadcrumb-item>用户管理</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <div class="user-profile">
              <el-avatar :size="32" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
              <span class="username">管理员</span>
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <div class="content-wrapper">
        <el-card shadow="never" class="table-card">
          <div class="table-header">
            <div class="title-group">
              <el-tag type="info">共 {{ total }} 名用户</el-tag>
            </div>
            <div class="action-group">
              <el-button 
                type="danger" 
                plain 
                :disabled="selectedIds.length === 0" 
                @click="handleBatchDelete"
              >
                <el-icon style="margin-right: 4px"><Delete /></el-icon>
                批量删除 {{ selectedIds.length > 0 ? `(${selectedIds.length})` : '' }}
              </el-button>
            </div>
          </div>

          <el-table
            v-loading="loading"
            :data="tableData"
            style="width: 100%"
            class="custom-table"
            @selection-change="handleSelectionChange"
          >
            <el-table-column type="selection" width="55" />
            <el-table-column label="用户信息" min-width="200">
              <template #default="{ row }">
                <div class="user-info-cell">
                  <el-avatar :size="40" :src="row.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'" />
                  <div class="user-detail">
                    <div class="nickname">{{ row.nickname || '未设置昵称' }}</div>
                    <div class="username-text">@{{ row.username }}</div>
                  </div>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="email" label="邮箱" width="180" />
            <el-table-column prop="totalPoints" label="总积分" width="120" align="right">
              <template #default="{ row }">
                <span class="numeric-text points">{{ row.totalPoints.toLocaleString() }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="totalStep" label="累计步数" width="150" align="right">
              <template #default="{ row }">
                <span class="numeric-text steps">{{ row.totalStep.toLocaleString() }}</span>
              </template>
            </el-table-column>
             <el-table-column prop="remainingStep" label="剩余步数" width="120" align="right">
               <template #default="{ row }">
                 <span class="numeric-text">{{ row.remainingStep.toLocaleString() }}</span>
               </template>
             </el-table-column>
            <el-table-column label="账号状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.isDeleted == 1 ? 'danger' : 'success'" size="small" effect="light">
                  {{ row.isDeleted == 1 ? '已删除' : '正常' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="160" align="center" fixed="right">
              <template #default="{ row }">
                <div class="table-ops">
                  <el-button link type="primary" @click="handleEdit(row)">
                    <el-icon><EditPen /></el-icon>
                    <span>编辑</span>
                  </el-button>
                  <el-button link type="danger" @click="handleDelete(row)">
                    <el-icon><Delete /></el-icon>
                    <span>删除</span>
                  </el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div class="pagination-wrapper">
            <el-pagination
              layout="total, prev, pager, next"
              :total="total"
              :page-size="10"
              @current-change="handleCurrentChange"
            />
          </div>
        </el-card>
      </div>
    </div>

    <!-- User Detail / Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      title="编辑用户信息"
      width="500px"
      append-to-body
      destroy-on-close
      class="custom-dialog"
    >
      <el-form :model="form" label-position="top">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名">
              <el-input v-model="form.username" disabled placeholder="账号ID不可变更" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别">
              <el-select v-model="form.sex" style="width: 100%">
                <el-option :value="1" label="男" />
                <el-option :value="2" label="女" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="昵称">
              <el-input v-model="form.nickname" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="form.email" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="账户积分">
              <el-input-number v-model="form.totalPoints" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="每日步数上限">
              <el-input-number v-model="form.maxDailySteps" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">
            保存修改
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { useRouter } from 'vue-router';
import { ArrowDown, Delete, EditPen } from '@element-plus/icons-vue';
import SideBar from '../components/SideBar.vue';
import { useUserStore } from '../stores/user';
import { getUserList, updateUser, deleteUsers } from '../api/user';

const router = useRouter();
const userStore = useUserStore();

// Table Data
const tableData = ref([]);
const loading = ref(false);
const total = ref(0);
const selectedIds = ref([]);

// Dialog
const dialogVisible = ref(false);
const submitLoading = ref(false);
const form = reactive({
  id: null,
  username: '',
  nickname: '',
  email: '',
  sex: 1,
  totalPoints: 0,
  totalStep: 0,
  remainingStep: 0,
  maxDailySteps: 0,
  avatar: ''
});

const handleCommand = (command) => {
  if (command === 'logout') {
    handleLogout();
  }
};

const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录并返回首页吗？', '提示', {
    confirmButtonText: '确定退出',
    cancelButtonText: '取消',
    type: 'info'
  }).then(() => {
    userStore.logout();
    router.push('/login');
    ElMessage.success('已安全退出');
  }).catch(() => {});
};

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await getUserList();
    // 假设后端返回的是数组或者包含 records 的对象
    tableData.value = res.data?.records || res.data || [];
    total.value = tableData.value.length;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id);
};

const handleCurrentChange = (val) => {
  // 目前暂无分页接口参数，前端模拟或待后端完善
  fetchList();
};

const handleEdit = (row) => {
  Object.assign(form, row);
  dialogVisible.value = true;
};

const submitForm = async () => {
  submitLoading.value = true;
  try {
    await updateUser(form);
    ElMessage.success('更新成功');
    dialogVisible.value = false;
    fetchList();
  } catch (error) {
    console.error(error);
  } finally {
    submitLoading.value = false;
  }
};

const handleDelete = (row) => {
  confirmDelete([row.id]);
};

const handleBatchDelete = () => {
  confirmDelete(selectedIds.value);
};

const confirmDelete = (ids) => {
  ElMessageBox.confirm('确定要删除选中的用户吗？', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteUsers(ids.join(','));
      ElMessage.success('删除成功');
      fetchList();
    } catch (e) {
      console.error(e);
    }
  });
};

onMounted(() => {
  fetchList();
});
</script>

<style scoped>
.user-manage-container {
  display: flex;
  height: 100vh;
  background-color: #f8fafc;
  overflow: hidden;
}

/* Main Content Area */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.header-bar {
  height: 72px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(8px);
  padding: 0 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e2e8f0;
  z-index: 90;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 12px;
  border-radius: 99px;
  transition: all 0.3s;
  cursor: pointer;
  outline: none;
}

.user-profile:hover {
  background-color: #f1f5f9;
}

.username {
  font-size: 14px;
  font-weight: 500;
  color: #334155;
}

.content-wrapper {
  padding: 32px 40px;
  flex: 1;
  overflow-y: auto;
}

.table-card {
  border-radius: 16px;
  border: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
}

.user-info-cell {
  display: flex;
  align-items: center;
  gap: 16px;
}

.nickname {
  font-weight: 600;
  color: #1e293b;
}

.username-text {
  font-size: 12px;
  color: #64748b;
}

.numeric-text {
  font-family: 'Inter', system-ui, sans-serif;
  font-weight: 600;
  color: #1e293b;
}

.numeric-text.points {
  color: #10b981;
  font-weight: 700;
  background: rgba(16, 185, 129, 0.1);
  padding: 2px 8px;
  border-radius: 4px;
}

.numeric-text.steps { color: #3b82f6; }

.table-ops {
  display: flex;
  justify-content: center;
  gap: 4px;
}

.table-ops :deep(.el-button) {
  display: flex;
  align-items: center;
  gap: 2px;
  font-size: 13px;
  padding: 2px 4px;
  border-radius: 4px;
  transition: all 0.2s;
}

.table-ops :deep(.el-button--primary:hover) {
  background-color: rgba(59, 130, 246, 0.1);
}

.table-ops :deep(.el-button--danger:hover) {
  background-color: rgba(239, 68, 68, 0.1);
}

.pagination-wrapper {
  margin-top: 32px;
  display: flex;
  justify-content: flex-end;
}

.custom-table {
  --el-table-border-color: #f1f5f9;
  --el-table-header-bg-color: #f8fafc;
}

.custom-table :deep(.el-table__header) th {
  color: #64748b;
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 12px 0;
}

.custom-table :deep(.el-table__row) td {
  padding: 12px 0;
}

:deep(.el-table__row) {
  height: auto;
}

/* Dialog Styling */
:deep(.el-dialog) {
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

:deep(.el-dialog__header) {
  margin-right: 0;
  padding: 24px 32px;
  background-color: #f8fafc;
  border-bottom: 1px solid #e2e8f0;
}

:deep(.el-dialog__title) {
  font-weight: 700;
  color: #1e293b;
}

:deep(.el-dialog__body) {
  padding: 32px;
}

.dialog-footer {
  padding: 20px 32px 32px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
