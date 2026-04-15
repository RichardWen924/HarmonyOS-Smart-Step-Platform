import request from '../utils/request';

export const sendVerification = (email) => {
  return request({
    url: '/admin/send-verification',
    method: 'post',
    data: { email }
  });
};

export const register = (data) => {
  return request({
    url: '/admin/register',
    method: 'post',
    data
  });
};

export const login = (data) => {
  return request({
    url: '/admin/login',
    method: 'post',
    data
  });
};
