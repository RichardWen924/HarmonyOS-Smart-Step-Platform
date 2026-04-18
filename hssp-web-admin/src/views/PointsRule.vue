<template>
  <div class="points-rule-container">
    <div class="side-nav">
      <div class="logo">
        <el-icon :size="24" color="#409EFF"><TrendCharts /></el-icon>
        <span>步数积分管理系统</span>
      </div>
      <el-menu
        default-active="1"
        class="el-menu-vertical"
      >
        <el-menu-item index="1">
          <el-icon><List /></el-icon>
          <span>积分规则设置</span>
        </el-menu-item>
      </el-menu>
      
      <div class="user-info-section">
      </div>
    </div>

    <div class="main-content">
      <div class="header-bar">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>管理中心</el-breadcrumb-item>
            <el-breadcrumb-item>积分规则</el-breadcrumb-item>
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
              <el-tag type="info">共 {{ total }} 条规则</el-tag>
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
              <el-button type="primary" @click="handleAdd">
                <el-icon style="margin-right: 4px"><Plus /></el-icon>新增规则
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
            <el-table-column prop="ruleName" label="规则名称" min-width="200" />
            <el-table-column prop="stepsRequired" label="所需步数" width="180" align="right">
              <template #default="{ row }">
                <span class="numeric-text">{{ row.stepsRequired.toLocaleString() }}</span> 步
              </template>
            </el-table-column>
            <el-table-column prop="pointsAwarded" label="奖励积分" width="150" align="center">
              <template #default="{ row }">
                <el-tag type="success" effect="light" class="points-badge">
                  +{{ row.pointsAwarded }} 积分
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="isActive" label="状态" width="100" align="center">
              <template #default="{ row }">
                <el-switch
                  v-model="row.isActive"
                  :active-value="1"
                  :inactive-value="0"
                  @change="(val) => handleStatusChange(row, val)"
                />
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
              v-model:current-page="pageParams.current"
              v-model:page-size="pageParams.size"
              :page-sizes="[10, 20, 50]"
              layout="total, sizes, prev, pager, next"
              :total="total"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
            >
              <template #total>
                <span>共 {{ total }} 条资料</span>
              </template>
            </el-pagination>
          </div>
        </el-card>
      </div>
    </div>

    <!-- Add / Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增积分规则' : '编辑积分规则'"
      width="460px"
      append-to-body
      destroy-on-close
      class="custom-dialog"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="form.ruleName" placeholder="例如：每日达标奖励" maxlength="20" show-word-limit />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所需步数" prop="stepsRequired">
              <el-input-number v-model="form.stepsRequired" :min="1" :step="1000" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="奖励积分" prop="pointsAwarded">
              <el-input-number v-model="form.pointsAwarded" :min="1" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">
            提交保存
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
import { List, User, Plus, TrendCharts, ArrowDown, Delete } from '@element-plus/icons-vue';
import { useUserStore } from '../stores/user';
import { getPointsRulePage, addPointsRule, updatePointsRule, deletePointsRules } from '../api/points';

const router = useRouter();
const userStore = useUserStore();

// Table Data
const tableData = ref([]);
const loading = ref(false);
const total = ref(0);
const pageParams = reactive({
  current: 1,
  size: 10
});
const selectedIds = ref([]);

// Dialog
const dialogVisible = ref(false);
const dialogType = ref('add'); 
const submitLoading = ref(false);
const formRef = ref(null);
const form = reactive({
  id: null,
  ruleName: '',
  stepsRequired: 1,
  pointsAwarded: 1
});

const rules = {
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  stepsRequired: [{ required: true, type: 'number', message: '步数必填', trigger: 'blur' }],
  pointsAwarded: [{ required: true, type: 'number', message: '积分必填', trigger: 'blur' }]
};

const handleCommand = (command) => {
  if (command === 'logout') {
    handleLogout();
  }
};

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await getPointsRulePage(pageParams);
    tableData.value = res.data?.records || res.data || [];
    total.value = res.data?.total || tableData.value.length || 0;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id).filter(id => id != null);
};

const handleSizeChange = (val) => {
  pageParams.size = val;
  fetchList();
};

const handleCurrentChange = (val) => {
  pageParams.current = val;
  fetchList();
};

const handleStatusChange = async (row, val) => {
  try {
    await updatePointsRule({
      ...row,
      isActive: val
    });
    ElMessage.success(`规则已${val === 1 ? '开启' : '关闭'}`);
  } catch (error) {
    // 恢复原始状态
    row.isActive = val === 1 ? 0 : 1;
    console.error(error);
  }
};

const handleAdd = () => {
  dialogType.value = 'add';
  form.id = null;
  form.ruleName = '';
  form.stepsRequired = 1000;
  form.pointsAwarded = 10;
  dialogVisible.value = true;
};

const handleEdit = (row) => {
  dialogType.value = 'edit';
  form.id = row.id;
  form.ruleName = row.ruleName;
  form.stepsRequired = row.stepsRequired;
  form.pointsAwarded = row.pointsAwarded;
  dialogVisible.value = true;
};

const handleDelete = (row) => {
  confirmDelete([row.id]);
};

const handleBatchDelete = () => {
  if (selectedIds.value.length === 0) return;
  confirmDelete(selectedIds.value);
};

const confirmDelete = (ids) => {
  ElMessageBox.confirm('数据删除后无法恢复，确定要继续吗？', '操作确认', {
    confirmButtonText: '确定删除',
    cancelButtonText: '取消',
    type: 'warning',
    buttonSize: 'default'
  }).then(async () => {
    try {
      await deletePointsRules(ids);
      ElMessage.success('操作成功');
      if (ids.length >= tableData.value.length && pageParams.current > 1) {
         pageParams.current--;
      }
      fetchList();
    } catch (e) {
      console.error(e);
    }
  }).catch(() => {});
};

const submitForm = () => {
  if (!formRef.value) return;
  formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true;
      try {
        if (dialogType.value === 'add') {
          await addPointsRule({
            ruleName: form.ruleName,
            stepsRequired: form.stepsRequired,
            pointsAwarded: form.pointsAwarded
          });
          ElMessage.success('新增成功');
        } else {
          await updatePointsRule(form);
          ElMessage.success('修改成功');
        }
        dialogVisible.value = false;
        fetchList();
      } catch (e) {
        console.error(e);
      } finally {
        submitLoading.value = false;
      }
    }
  });
};

const resetForm = () => {
  if (formRef.value) formRef.value.resetFields();
};

const handleLogout = () => {
  ElMessageBox.confirm('退出后需要重新登录，确定退出吗？', '提示', {
    confirmButtonText: '退出登录',
    cancelButtonText: '取消',
    type: 'info'
  }).then(() => {
    userStore.logout();
    router.push('/login');
    ElMessage.success('已安全退出');
  }).catch(() => {});
};

onMounted(() => {
  fetchList();
});
</script>

<style scoped>
.points-rule-container {
  display: flex;
  height: 100vh;
  background-color: #f8fafc; /* 更现代的淡蓝灰背景 */
  overflow: hidden;
}

/* Sidebar Styling */
.side-nav {
  width: 260px;
  background-color: #1e293b; /* 深色主题边栏 */
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 10px rgba(0, 0, 0, 0.05);
  z-index: 100;
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

.user-info-section {
  display: none; /* 移动到顶部栏 */
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

.header-right {
  display: flex;
  align-items: center;
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

.user-profile:focus-visible {
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
  border-radius: 16px; /* 更圆润的边框 */
  border: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
}

.action-group {
  display: flex;
  gap: 16px;
}

/* 按钮样式美化 */
.el-button {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.2s;
}

.el-button--primary:not(.is-link) {
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.title-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.numeric-text {
  font-family: 'Inter', system-ui, sans-serif;
  font-weight: 600;
  color: #1e293b;
}

.points-text {
  color: #10b981;
  font-weight: 700;
  background: rgba(16, 185, 129, 0.1);
  padding: 2px 8px;
  border-radius: 4px;
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
  padding: 8px 0; /* 缩小表头行距 */
}

.custom-table :deep(.el-table__row) td {
  padding: 8px 0; /* 缩小数据行行距 */
}

/* 操作按钮样式优化 */
.table-ops {
  display: flex;
  justify-content: center;
  gap: 4px; /* 进一步缩小按钮间距 */
}

.table-ops :deep(.el-button) {
  display: flex;
  align-items: center;
  gap: 2px; /* 缩小图标和文字的间距 */
  font-size: 13px; /* 稍微缩小字号 */
  padding: 2px 4px; /* 缩小内边距 */
  border-radius: 4px;
  transition: all 0.2s;
}

.table-ops :deep(.el-button--primary:hover) {
  background-color: rgba(59, 130, 246, 0.1);
}

.table-ops :deep(.el-button--danger:hover) {
  background-color: rgba(239, 68, 68, 0.1);
}

.table-ops .el-icon {
  font-size: 16px;
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
