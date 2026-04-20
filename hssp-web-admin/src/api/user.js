import request from '../utils/request'

/**
 * 查询用户分页列表
 * @param {Object} params { current, size }
 */
export const getUserPage = (params) => {
    return request({
        url: '/admin/user/page',
        method: 'get',
        params
    })
}

/**
 * 重置用户密码
 * @param {number} id 用户ID
 */
export const resetPassword = (id) => {
    return request({
        url: '/admin/user/password',
        method: 'put',
        params: { id }
    })
}

/**
 * 查询用户列表
 */
export const getUserList = () => {
    return request({
        url: '/admin/user',
        method: 'get'
    })
}

/**
 * 查询指定用户信息
 * @param {string} id 用户ID
 */
export const getUserById = (id) => {
    return request({
        url: `/admin/user/${id}`,
        method: 'get'
    })
}

/**
 * 修改用户信息
 * @param {Object} data 用户对象
 */
export const updateUser = (data) => {
    return request({
        url: '/admin/user',
        method: 'put',
        data
    })
}

/**
 * 批量删除用户信息
 * @param {string} ids 用户ID（多个以逗号分隔）
 */
export const deleteUsers = (ids) => {
    return request({
        url: `/admin/user/${ids}`,
        method: 'delete'
    })
}
