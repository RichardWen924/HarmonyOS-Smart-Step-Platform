const fs = require('fs');
const file = 'src/views/Login.vue';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(/'Login to HSSP Admin'/g, "'登录 HSSP 管理后台'");
content = content.replace(/'Register'/g, "'注册'");
content = content.replace(/label="Email\/User"/g, 'label="账号"');
content = content.replace(/placeholder="Enter email or username"/g, 'placeholder="请输入邮箱或用户名"');
content = content.replace(/label="Email"/g, 'label="邮箱"');
content = content.replace(/placeholder="Enter email address"/g, 'placeholder="请输入邮箱地址"');
content = content.replace(/label="Password"/g, 'label="密码"');
content = content.replace(/placeholder="Enter password"/g, 'placeholder="请输入密码"');
content = content.replace(/label="Captacha"/g, 'label="验证码"');
content = content.replace(/placeholder="Enter verification code"/g, 'placeholder="请输入验证码"');
content = content.replace(/placeholder="Setup password"/g, 'placeholder="设置新密码"');
content = content.replace(/'Login'/g, "'登录'");
content = content.replace(/'Need an account\? Register here'/g, "'没有账号？点击注册'");
content = content.replace(/'Already have an account\? Login'/g, "'已有账号？点击登录'");
content = content.replace(/'Please enter account'/g, "'请输入账号'");
content = content.replace(/'Please enter password'/g, "'请输入密码'");
content = content.replace(/'Please enter email'/g, "'请输入邮箱'");
content = content.replace(/'Please enter a valid email'/g, "'请输入有效的邮箱地址'");
content = content.replace(/'Please enter verification code'/g, "'请输入验证码'");
content = content.replace(/'Please setup a password'/g, "'请设置新密码'");
content = content.replace(/'Send Code'/g, "'发送验证码'");
content = content.replace(/'Please enter email first'/g, "'请先输入邮箱'");
content = content.replace(/'Code sent successfully'/g, "'验证码发送成功'");
content = content.replace(/'Login successful'/g, "'登录成功'");
content = content.replace(/'Token not found in response'/g, "'响应中未找到 Token'");
content = content.replace(/'Registration successful\. Please login\.'/g, "'注册成功，请登录。'");

// Update preview handler if not matching exact string
if (!content.includes('const handlePreview = () => {')) {
  content = content.replace('</script>', `
// 临时预览函数
const handlePreview = () => {
  userStore.setToken('preview_token');
  ElMessage.success('已进入预览模式');
  router.push('/points-rule');
};
</script>`);
}

fs.writeFileSync(file, content, 'utf8');
console.log("Translation done");
