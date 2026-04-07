import request from '../utils/request';

export const getPointsRulePage = (params) => {
  return request({
    url: '/admin/points/page',
    method: 'get',
    params // { current, size }
  });
};

export const addPointsRule = (data) => {
  return request({
    url: '/admin/points',
    method: 'post',
    data // { ruleName, stepsRequired, pointsAwarded }
  });
};

export const updatePointsRule = (data) => {
  return request({
    url: '/admin/points',
    method: 'put',
    data // { id, ruleName, stepsRequired, pointsAwarded }  
  });
};

export const deletePointsRules = (ids) => {
  return request({
    url: '/admin/points',
    method: 'delete',
    data: { ids } 
  });
};

export const getAllPointsRules = () => {
  return request({
    url: '/admin/points',
    method: 'get'
  });
};
