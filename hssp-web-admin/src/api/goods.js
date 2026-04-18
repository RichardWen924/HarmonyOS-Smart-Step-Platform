import request from '../utils/request';

/**
 * 获取商品列表
 * 说明：文档未明确分页参数，这里直接调用获取
 */
export function getGoodsList() {
  return request({
    url: '/admin/goods/list', // 假设列表接口
    method: 'get'
  });
}

/**
 * 添加商品
 */
export function addGoods(data) {
  return request({
    url: '/admin/goods',
    method: 'post',
    data
  });
}

/**
 * 修改商品
 */
export function updateGoods(data) {
  return request({
    url: '/admin/goods',
    method: 'put',
    data
  });
}

/**
 * 删除商品
 */
export function deleteGoods(id) {
  return request({
    url: `/admin/goods/${id}`,
    method: 'delete'
  });
}

/**
 * 切换商品状态 (上架/下架)
 * @param {number} id 商品ID
 * @param {number} status 0:上架, 1:下架
 */
export function updateGoodsStatus(id, status) {
  return request({
    url: `/admin/goods/status/${id}`,
    method: 'put',
    params: { status }
  });
}
