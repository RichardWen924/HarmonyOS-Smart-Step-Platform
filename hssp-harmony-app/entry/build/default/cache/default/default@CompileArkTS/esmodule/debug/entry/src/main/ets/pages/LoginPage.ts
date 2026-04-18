if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface LoginPage_Params {
    account?: string;
    password?: string;
    loginType?: LoginType;
    email?: string;
    verificationCode?: string;
    nickname?: string;
    confirmPassword?: string;
    isRegisterMode?: boolean;
    isLoading?: boolean;
    countdown?: number;
    isSendingCode?: boolean;
    showPassword?: boolean;
    apiClient?;
    stateStore?;
}
import promptAction from "@ohos:promptAction";
import router from "@ohos:router";
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import StateStore from "@normalized:N&&&entry/src/main/ets/services/StateStore&";
import type { ApiResponse, LoginResponse } from '../types/common';
import { AppColors, AppFonts, AppSpacing, AppBorderRadius, AppIcons } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
enum LoginType {
    PASSWORD = 1,
    VERIFICATION_CODE = 2
}
class LoginPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__account = new ObservedPropertySimplePU('', this, "account");
        this.__password = new ObservedPropertySimplePU('', this, "password");
        this.__loginType = new ObservedPropertySimplePU(LoginType.PASSWORD
        // 注册相关
        , this, "loginType");
        this.__email = new ObservedPropertySimplePU('', this, "email");
        this.__verificationCode = new ObservedPropertySimplePU('', this, "verificationCode");
        this.__nickname = new ObservedPropertySimplePU('', this, "nickname");
        this.__confirmPassword = new ObservedPropertySimplePU(''
        // UI 状态
        , this, "confirmPassword");
        this.__isRegisterMode = new ObservedPropertySimplePU(false, this, "isRegisterMode");
        this.__isLoading = new ObservedPropertySimplePU(false, this, "isLoading");
        this.__countdown = new ObservedPropertySimplePU(0, this, "countdown");
        this.__isSendingCode = new ObservedPropertySimplePU(false, this, "isSendingCode");
        this.__showPassword = new ObservedPropertySimplePU(false, this, "showPassword");
        this.apiClient = ApiClient.getInstance();
        this.stateStore = StateStore;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: LoginPage_Params) {
        if (params.account !== undefined) {
            this.account = params.account;
        }
        if (params.password !== undefined) {
            this.password = params.password;
        }
        if (params.loginType !== undefined) {
            this.loginType = params.loginType;
        }
        if (params.email !== undefined) {
            this.email = params.email;
        }
        if (params.verificationCode !== undefined) {
            this.verificationCode = params.verificationCode;
        }
        if (params.nickname !== undefined) {
            this.nickname = params.nickname;
        }
        if (params.confirmPassword !== undefined) {
            this.confirmPassword = params.confirmPassword;
        }
        if (params.isRegisterMode !== undefined) {
            this.isRegisterMode = params.isRegisterMode;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.countdown !== undefined) {
            this.countdown = params.countdown;
        }
        if (params.isSendingCode !== undefined) {
            this.isSendingCode = params.isSendingCode;
        }
        if (params.showPassword !== undefined) {
            this.showPassword = params.showPassword;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
        if (params.stateStore !== undefined) {
            this.stateStore = params.stateStore;
        }
    }
    updateStateVars(params: LoginPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__account.purgeDependencyOnElmtId(rmElmtId);
        this.__password.purgeDependencyOnElmtId(rmElmtId);
        this.__loginType.purgeDependencyOnElmtId(rmElmtId);
        this.__email.purgeDependencyOnElmtId(rmElmtId);
        this.__verificationCode.purgeDependencyOnElmtId(rmElmtId);
        this.__nickname.purgeDependencyOnElmtId(rmElmtId);
        this.__confirmPassword.purgeDependencyOnElmtId(rmElmtId);
        this.__isRegisterMode.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
        this.__countdown.purgeDependencyOnElmtId(rmElmtId);
        this.__isSendingCode.purgeDependencyOnElmtId(rmElmtId);
        this.__showPassword.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__account.aboutToBeDeleted();
        this.__password.aboutToBeDeleted();
        this.__loginType.aboutToBeDeleted();
        this.__email.aboutToBeDeleted();
        this.__verificationCode.aboutToBeDeleted();
        this.__nickname.aboutToBeDeleted();
        this.__confirmPassword.aboutToBeDeleted();
        this.__isRegisterMode.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        this.__countdown.aboutToBeDeleted();
        this.__isSendingCode.aboutToBeDeleted();
        this.__showPassword.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    // 登录相关
    private __account: ObservedPropertySimplePU<string>;
    get account() {
        return this.__account.get();
    }
    set account(newValue: string) {
        this.__account.set(newValue);
    }
    private __password: ObservedPropertySimplePU<string>;
    get password() {
        return this.__password.get();
    }
    set password(newValue: string) {
        this.__password.set(newValue);
    }
    private __loginType: ObservedPropertySimplePU<LoginType>;
    get loginType() {
        return this.__loginType.get();
    }
    set loginType(newValue: LoginType) {
        this.__loginType.set(newValue);
    }
    // 注册相关
    private __email: ObservedPropertySimplePU<string>;
    get email() {
        return this.__email.get();
    }
    set email(newValue: string) {
        this.__email.set(newValue);
    }
    private __verificationCode: ObservedPropertySimplePU<string>;
    get verificationCode() {
        return this.__verificationCode.get();
    }
    set verificationCode(newValue: string) {
        this.__verificationCode.set(newValue);
    }
    private __nickname: ObservedPropertySimplePU<string>;
    get nickname() {
        return this.__nickname.get();
    }
    set nickname(newValue: string) {
        this.__nickname.set(newValue);
    }
    private __confirmPassword: ObservedPropertySimplePU<string>;
    get confirmPassword() {
        return this.__confirmPassword.get();
    }
    set confirmPassword(newValue: string) {
        this.__confirmPassword.set(newValue);
    }
    // UI 状态
    private __isRegisterMode: ObservedPropertySimplePU<boolean>;
    get isRegisterMode() {
        return this.__isRegisterMode.get();
    }
    set isRegisterMode(newValue: boolean) {
        this.__isRegisterMode.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private __countdown: ObservedPropertySimplePU<number>;
    get countdown() {
        return this.__countdown.get();
    }
    set countdown(newValue: number) {
        this.__countdown.set(newValue);
    }
    private __isSendingCode: ObservedPropertySimplePU<boolean>;
    get isSendingCode() {
        return this.__isSendingCode.get();
    }
    set isSendingCode(newValue: boolean) {
        this.__isSendingCode.set(newValue);
    }
    private __showPassword: ObservedPropertySimplePU<boolean>;
    get showPassword() {
        return this.__showPassword.get();
    }
    set showPassword(newValue: boolean) {
        this.__showPassword.set(newValue);
    }
    private apiClient;
    private stateStore;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgCard);
            Column.clip(true);
        }, Column);
        // 顶部装饰背景 - 固定高度，不会被Scroll遮挡
        this.buildBackground.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.scrollable(ScrollDirection.Vertical);
            Scroll.layoutWeight(1);
            Scroll.margin({ top: -40 });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
        }, Column);
        // Logo 和标题
        this.buildHeader.bind(this)();
        // 表单区域
        this.buildForm.bind(this)();
        // 底部链接
        this.buildFooter.bind(this)();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    // 构建背景装饰
    buildBackground(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height(150);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 渐变背景装饰
            Row.create();
            // 渐变背景装饰
            Row.width('100%');
            // 渐变背景装饰
            Row.justifyContent(FlexAlign.SpaceBetween);
            // 渐变背景装饰
            Row.padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(80);
            Column.height(80);
            Column.backgroundColor(AppColors.primaryLight);
            Column.borderRadius(AppBorderRadius.radiusFull);
            Column.opacity(0.3);
            Column.margin({ right: AppSpacing.space2Xl });
        }, Column);
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(60);
            Column.height(60);
            Column.backgroundColor(AppColors.successLight);
            Column.borderRadius(AppBorderRadius.radiusFull);
            Column.opacity(0.2);
            Column.margin({ top: AppSpacing.space3Xl });
        }, Column);
        Column.pop();
        // 渐变背景装饰
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 添加一些间距，确保Logo区域不会被遮挡
            Blank.create();
            // 添加一些间距，确保Logo区域不会被遮挡
            Blank.height(60);
        }, Blank);
        // 添加一些间距，确保Logo区域不会被遮挡
        Blank.pop();
        Column.pop();
    }
    // 构建头部
    buildHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Logo 区域
            Column.create();
            // Logo 区域
            Column.width('100%');
            // Logo 区域
            Column.alignItems(HorizontalAlign.Center);
            // Logo 区域
            Column.margin({ top: AppSpacing.space2Xl, bottom: AppSpacing.space4Xl });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(AppIcons.steps);
            Text.fontSize(64);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('运动健康');
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.titleColor);
            Text.margin({ bottom: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('每一步都算数');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        // Logo 区域
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题
            Column.create();
            // 标题
            Column.width('100%');
            // 标题
            Column.alignItems(HorizontalAlign.Start);
            // 标题
            Column.margin({ bottom: AppSpacing.space4Xl });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.isRegisterMode ? '注册账号' : '欢迎回来');
            Text.fontSize(AppFonts.fontSize4Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.titleColor);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.isRegisterMode ? '开启您的运动之旅' : '记录每一步的精彩');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        // 标题
        Column.pop();
        Column.pop();
    }
    // 构建表单
    buildForm(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isRegisterMode) {
                this.ifElseBranchUpdateFunction(0, () => {
                    // 注册表单
                    this.buildEmailInput.bind(this)();
                    this.buildVerificationCodeInput.bind(this)();
                    this.buildNicknameInput.bind(this)();
                    this.buildPasswordInput.bind(this)(true);
                    this.buildConfirmPasswordInput.bind(this)();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('立即注册');
                        Button.width('100%');
                        Button.height(52);
                        Button.fontSize(AppFonts.fontSizeLg);
                        Button.fontWeight(AppFonts.fontWeightMedium);
                        Button.backgroundColor(AppColors.successColor);
                        Button.fontColor(Color.White);
                        Button.borderRadius(AppBorderRadius.radius2Xl);
                        Button.enabled(!this.isLoading && this.canRegister());
                        Button.opacity(this.canRegister() ? 1 : 0.6);
                        Button.onClick(() => {
                            this.handleRegister();
                        });
                        Button.margin({ top: AppSpacing.spaceLg });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    // 登录表单
                    this.buildAccountInput.bind(this)();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 登录方式切换
                        Row.create();
                        // 登录方式切换
                        Row.width('100%');
                        // 登录方式切换
                        Row.margin({ bottom: AppSpacing.spaceLg });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('登录方式');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.textSecondary);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.loginType === LoginType.PASSWORD ? '密码登录' : '验证码登录');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.primaryColor);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.onClick(() => {
                            this.loginType = this.loginType === LoginType.PASSWORD
                                ? LoginType.VERIFICATION_CODE
                                : LoginType.PASSWORD;
                        });
                    }, Text);
                    Text.pop();
                    // 登录方式切换
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if (this.loginType === LoginType.PASSWORD) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.buildPasswordInput.bind(this)(false);
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                                this.buildVerificationCodeInput.bind(this)(false);
                            });
                        }
                    }, If);
                    If.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('登录');
                        Button.width('100%');
                        Button.height(52);
                        Button.fontSize(AppFonts.fontSizeLg);
                        Button.fontWeight(AppFonts.fontWeightMedium);
                        Button.backgroundColor(AppColors.primaryColor);
                        Button.fontColor(Color.White);
                        Button.borderRadius(AppBorderRadius.radius2Xl);
                        Button.enabled(!this.isLoading && this.canLogin());
                        Button.opacity(this.canLogin() ? 1 : 0.6);
                        Button.onClick(() => {
                            this.handleLogin();
                        });
                        Button.margin({ top: AppSpacing.spaceLg });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 忘记密码
                        Row.create();
                        // 忘记密码
                        Row.width('100%');
                        // 忘记密码
                        Row.margin({ top: AppSpacing.spaceLg });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('忘记密码？');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.primaryColor);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.onClick(() => {
                            promptAction.showToast({
                                message: '请联系客服重置密码',
                                duration: 2000
                            });
                        });
                    }, Text);
                    Text.pop();
                    // 忘记密码
                    Row.pop();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    // 构建账号输入
    buildAccountInput(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('账号');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请输入用户名或邮箱' });
            TextInput.width('100%');
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.account = value.trim();
            });
        }, TextInput);
        Column.pop();
    }
    // 构建邮箱输入
    buildEmailInput(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('邮箱');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请输入邮箱地址' });
            TextInput.width('100%');
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.type(InputType.Email);
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.email = value.trim();
            });
        }, TextInput);
        Column.pop();
    }
    // 构建验证码输入
    buildVerificationCodeInput(forRegister: boolean = true, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('验证码');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请输入验证码' });
            TextInput.layoutWeight(1);
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.verificationCode = value.trim();
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.countdown > 0 ? `${this.countdown}s` : '获取验证码');
            Button.fontSize(AppFonts.fontSizeSm);
            Button.backgroundColor(this.countdown > 0 || this.isSendingCode ? AppColors.borderColor : AppColors.primaryColor);
            Button.fontColor(Color.White);
            Button.borderRadius(AppBorderRadius.radiusBase);
            Button.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            Button.margin({ left: AppSpacing.spaceSm });
            Button.enabled(this.countdown === 0 && !this.isSendingCode);
            Button.onClick(() => {
                this.sendVerificationCode(forRegister);
            });
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    // 构建昵称输入
    buildNicknameInput(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('昵称（可选）');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请输入昵称' });
            TextInput.width('100%');
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.nickname = value.trim();
            });
        }, TextInput);
        Column.pop();
    }
    // 构建密码输入
    buildPasswordInput(isRegister: boolean, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: isRegister ? AppSpacing.spaceLg : 0 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('密码');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: isRegister ? '请设置密码' : '请输入密码' });
            TextInput.layoutWeight(1);
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.type(this.showPassword ? InputType.Normal : InputType.Password);
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.password = value;
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 显示/隐藏密码按钮
            Text.create(this.showPassword ? '🙈' : '👁️');
            // 显示/隐藏密码按钮
            Text.fontSize(AppFonts.fontSizeLg);
            // 显示/隐藏密码按钮
            Text.margin({ left: AppSpacing.spaceSm });
            // 显示/隐藏密码按钮
            Text.onClick(() => {
                this.showPassword = !this.showPassword;
            });
        }, Text);
        // 显示/隐藏密码按钮
        Text.pop();
        Row.pop();
        Column.pop();
    }
    // 构建确认密码输入
    buildConfirmPasswordInput(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.margin({ bottom: AppSpacing.space3Xl });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('确认密码');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.alignSelf(ItemAlign.Start);
            Text.margin({ bottom: AppSpacing.spaceSm });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请再次输入密码' });
            TextInput.width('100%');
            TextInput.height(52);
            TextInput.borderRadius(AppBorderRadius.radiusBase);
            TextInput.backgroundColor(AppColors.bgColor);
            TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
            TextInput.type(InputType.Password);
            TextInput.fontSize(AppFonts.fontSizeBase);
            TextInput.fontColor(AppColors.textColor);
            TextInput.onChange((value: string) => {
                this.confirmPassword = value;
            });
        }, TextInput);
        Column.pop();
    }
    // 构建底部
    buildFooter(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.Center);
            Row.margin({ top: AppSpacing.space3Xl });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.isRegisterMode ? '已有账号？' : '没有账号？');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textSecondary);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.isRegisterMode ? '立即登录' : '立即注册');
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.primaryColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.margin({ left: AppSpacing.spaceSm });
            Text.onClick(() => {
                this.isRegisterMode = !this.isRegisterMode;
                this.clearForm();
            });
        }, Text);
        Text.pop();
        Row.pop();
    }
    // 验证是否可以登录
    private canLogin(): boolean {
        if (!this.account)
            return false;
        if (this.loginType === LoginType.PASSWORD && !this.password)
            return false;
        if (this.loginType === LoginType.VERIFICATION_CODE && !this.verificationCode)
            return false;
        return true;
    }
    // 验证是否可以注册
    private canRegister(): boolean {
        if (!this.email || !this.password || !this.confirmPassword || !this.verificationCode)
            return false;
        if (this.password !== this.confirmPassword)
            return false;
        if (this.password.length < 6)
            return false;
        return true;
    }
    // 发送验证码
    private async sendVerificationCode(forRegister: boolean): Promise<void> {
        const targetEmail = forRegister ? this.email : this.account;
        if (!targetEmail || !targetEmail.includes('@')) {
            promptAction.showToast({
                message: '请输入有效的邮箱地址',
                duration: 2000
            });
            return;
        }
        this.isSendingCode = true;
        try {
            const type = forRegister ? 1 : 2; // 1: 注册，2: 登录
            const response = await this.apiClient.sendVerificationCode(targetEmail, type);
            if (response.code === 1) {
                promptAction.showToast({
                    message: '验证码已发送',
                    duration: 2000
                });
                // 开始倒计时
                this.countdown = 60;
                const timer = setInterval(() => {
                    this.countdown--;
                    if (this.countdown <= 0) {
                        clearInterval(timer);
                    }
                }, 1000);
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            promptAction.showToast({
                message: '发送失败',
                duration: 2000
            });
        }
        finally {
            this.isSendingCode = false;
        }
    }
    // 处理登录
    private async handleLogin(): Promise<void> {
        if (!this.canLogin()) {
            promptAction.showToast({
                message: '请填写完整信息',
                duration: 2000
            });
            return;
        }
        this.isLoading = true;
        try {
            let response: ApiResponse<LoginResponse>;
            if (this.loginType === LoginType.PASSWORD) {
                response = await this.apiClient.loginByPassword(this.account, this.password);
            }
            else {
                response = await this.apiClient.loginByCode(this.account, this.verificationCode);
            }
            if (response.code === 1 && response.data) {
                // 保存用户信息
                await this.stateStore.login(response.data.userInfo, response.data.token);
                promptAction.showToast({
                    message: '登录成功',
                    duration: 1500
                });
                // 跳转到主页面
                setTimeout(() => {
                    router.replaceUrl({
                        url: 'pages/MainPage'
                    });
                }, 1500);
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            console.error('Login failed:', error);
            promptAction.showToast({
                message: '登录失败，请重试',
                duration: 2000
            });
        }
        finally {
            this.isLoading = false;
        }
    }
    // 处理注册
    private async handleRegister(): Promise<void> {
        if (!this.canRegister()) {
            if (this.password !== this.confirmPassword) {
                promptAction.showToast({
                    message: '两次输入的密码不一致',
                    duration: 2000
                });
                return;
            }
            promptAction.showToast({
                message: '请填写完整信息',
                duration: 2000
            });
            return;
        }
        this.isLoading = true;
        try {
            const response = await this.apiClient.register(this.email, this.verificationCode, this.nickname || undefined);
            if (response.code === 1 && response.data) {
                // 保存用户信息
                await this.stateStore.login(response.data.userInfo, response.data.token);
                promptAction.showToast({
                    message: '注册成功',
                    duration: 1500
                });
                // 跳转到主页面
                setTimeout(() => {
                    router.replaceUrl({
                        url: 'pages/MainPage'
                    });
                }, 1500);
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            console.error('Register failed:', error);
            promptAction.showToast({
                message: '注册失败，请重试',
                duration: 2000
            });
        }
        finally {
            this.isLoading = false;
        }
    }
    // 清空表单
    private clearForm(): void {
        this.account = '';
        this.password = '';
        this.email = '';
        this.verificationCode = '';
        this.nickname = '';
        this.confirmPassword = '';
        this.countdown = 0;
        this.showPassword = false;
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "LoginPage";
    }
}
registerNamedRoute(() => new LoginPage(undefined, {}), "", { bundleName: "com.hssp.app", moduleName: "entry", pagePath: "pages/LoginPage", pageFullPath: "entry/src/main/ets/pages/LoginPage", integratedHsp: "false", moduleType: "followWithHap" });
