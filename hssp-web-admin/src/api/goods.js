import request from '../utils/request';

/**
 * 获取商品分页列表
 * @param {Object} params { current, size }
 */
export function getGoodsPage(params) {
  return request({
    url: '/goods/admin/page',
    method: 'get',
    params: {
      page: params.current,
      size: params.size
    }
  });
}

/**
 * 根据 ID 获取商品详情
 */
export function getGoodsById(id) {
  return request({
    url: `/goods/admin/${id}`,
    method: 'get'
  });
}

/**
 * 添加商品
 */
export function addGoods(data) {
  return request({
    url: '/goods/admin',
    method: 'post',
    data
  });
}

/**
 * 修改商品
 */
export function updateGoods(data) {
  return request({
    url: '/goods/admin',
    method: 'put',
    data
  });
}

/**
 * 删除商品
 */
export function deleteGoods(id) {
  return request({
    url: `/goods/admin/${id}`,
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
    url: `/goods/admin/status/${id}`,
    method: 'put',
    params: { status }
  });
}
