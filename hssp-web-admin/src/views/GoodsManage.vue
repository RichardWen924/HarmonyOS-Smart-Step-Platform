<template>
  <div class="goods-manage-container">
    <SideBar />

    <div class="main-content">
      <div class="header-bar">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>管理中心</el-breadcrumb-item>
            <el-breadcrumb-item>商品管理</el-breadcrumb-item>
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
              <el-tag type="info">共 {{ total }} 件商品</el-tag>
            </div>
            <div class="action-group">
              <el-button type="primary" @click="handleAdd">
                <el-icon style="margin-right: 4px"><Plus /></el-icon>新增商品
              </el-button>
            </div>
          </div>

          <el-table
            v-loading="loading"
            :data="tableData"
            style="width: 100%"
            class="custom-table"
          >
            <el-table-column label="商品信息" min-width="250">
              <template #default="{ row }">
                <div class="goods-info-cell">
                  <el-image
                    class="goods-cover"
                    :src="row.coverUrl"
                    fit="cover"
                  >
                    <template #error>
                      <div class="image-slot">
                        <el-icon><Picture /></el-icon>
                      </div>
                    </template>
                  </el-image>
                  <div class="goods-detail">
                    <div class="goods-name">{{ row.goodsName }}</div>
                    <div class="goods-id">ID: {{ row.id }}</div>
                  </div>
                </div>
              </template>
            </el-table-column>

            <el-table-column prop="requiredPoints" label="所需积分" width="150" align="right">
              <template #default="{ row }">
                <span class="numeric-text points">{{ row.requiredPoints.toLocaleString() }}</span>
              </template>
            </el-table-column>

            <el-table-column prop="displayNum" label="排序权重" width="120" align="center">
              <template #default="{ row }">
                <span class="numeric-text">{{ row.displayNum }}</span>
              </template>
            </el-table-column>

            <el-table-column label="状态" width="120" align="center">
              <template #default="{ row }">
                <el-switch
                  v-model="row.isDeleted"
                  :active-value="0"
                  :inactive-value="1"
                  active-text="上架"
                  inactive-text="下架"
                  inline-prompt
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
            />
          </div>
        </el-card>
      </div>
    </div>

    <!-- Goods Add / Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增商品' : '编辑商品信息'"
      width="500px"
      append-to-body
      destroy-on-close
      class="custom-dialog"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-form-item label="商品名称" prop="goodsName">
          <el-input v-model="form.goodsName" placeholder="输入商品名称" />
        </el-form-item>

        <el-form-item label="封面图片路径" prop="coverUrl">
          <el-input v-model="form.coverUrl" placeholder="输入图片 URL 地址" />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所需积分" prop="requiredPoints">
              <el-input-number v-model="form.requiredPoints" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序权重" prop="displayNum">
              <el-input-number v-model="form.displayNum" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">
            保存提交
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
import { ArrowDown, Delete, EditPen, Plus, Picture } from '@element-plus/icons-vue';
import SideBar from '../components/SideBar.vue';
import { useUserStore } from '../stores/user';
import { getGoodsPage, addGoods, updateGoods, deleteGoods, updateGoodsStatus } from '../api/goods';

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

// Dialog
const dialogVisible = ref(false);
const dialogType = ref('add');
const submitLoading = ref(false);
const formRef = ref(null);
const form = reactive({
  id: null,
  goodsName: '',
  requiredPoints: 0,
  coverUrl: '',
  displayNum: 0,
  isDeleted: 0
});

const rules = {
  goodsName: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  requiredPoints: [{ required: true, message: '请输入所需积分', trigger: 'blur' }],
  coverUrl: [{ required: true, message: '请输入封面图地址', trigger: 'blur' }]
};

const handleCommand = (command) => {
  if (command === 'logout') {
    handleLogout();
  }
};

const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '退出',
    cancelButtonText: '取消',
    type: 'info'
  }).then(() => {
    userStore.logout();
    router.push('/login');
    ElMessage.success('已安全退出');
  });
};

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await getGoodsPage(pageParams);
    tableData.value = res.data?.records || res.data || [];
    total.value = res.data?.total || tableData.value.length;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleStatusChange = async (row, val) => {
  try {
    await updateGoodsStatus(row.id, val);
    ElMessage.success(`商品已${val === 0 ? '上架' : '下架'}`);
  } catch (error) {
    row.isDeleted = val === 0 ? 1 : 0;
  }
};

const handleAdd = () => {
  dialogType.value = 'add';
  Object.assign(form, {
    id: null,
    goodsName: '',
    requiredPoints: 0,
    coverUrl: '',
    displayNum: 0,
    isDeleted: 0
  });
  dialogVisible.value = true;
};

const handleEdit = (row) => {
  dialogType.value = 'edit';
  Object.assign(form, row);
  dialogVisible.value = true;
};

const handleSizeChange = (val) => {
  pageParams.size = val;
  fetchList();
};

const handleCurrentChange = (val) => {
  pageParams.current = val;
  fetchList();
};

const submitForm = () => {
  formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true;
      try {
        if (dialogType.value === 'add') {
          await addGoods(form);
          ElMessage.success('新增成功');
        } else {
          await updateGoods(form);
          ElMessage.success('修改成功');
        }
        dialogVisible.value = false;
        fetchList();
      } catch (error) {
        console.error(error);
      } finally {
        submitLoading.value = false;
      }
    }
  });
};

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该商品吗？', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteGoods(row.id);
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
.goods-manage-container {
  display: flex;
  height: 100vh;
  background-color: #f8fafc;
  overflow: hidden;
}

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

.pagination-wrapper {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
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

.goods-info-cell {
  display: flex;
  align-items: center;
  gap: 16px;
}

.goods-cover {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  background-color: #f1f5f9;
}

.image-slot {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  color: #94a3b8;
  font-size: 24px;
}

.goods-name {
  font-weight: 600;
  color: #1e293b;
}

.goods-id {
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

/* Dialog Styling */
:deep(.el-dialog) {
  border-radius: 20px;
  overflow: hidden;
}

:deep(.el-dialog__header) {
  padding: 24px 32px;
  background-color: #f8fafc;
  border-bottom: 1px solid #e2e8f0;
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
