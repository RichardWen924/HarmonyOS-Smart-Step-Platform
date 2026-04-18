if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ProfilePage_Params {
    userInfo?: UserInfo | null;
    isEditing?: boolean;
    editNickname?: string;
    editEmail?: string;
    editSex?: number;
    showPasswordDialog?: boolean;
    oldPassword?: string;
    newPassword?: string;
    confirmPassword?: string;
    stateStore?;
    apiClient?;
}
import promptAction from "@ohos:promptAction";
import router from "@ohos:router";
import StateStore from "@normalized:N&&&entry/src/main/ets/services/StateStore&";
import ApiClient from "@normalized:N&&&entry/src/main/ets/services/ApiClient&";
import type { UserInfo } from '../types/common';
import { AppColors, AppFonts, AppSpacing, AppBorderRadius, AppIcons } from "@normalized:N&&&entry/src/main/ets/config/DesignSystem&";
import AppShadows from "@normalized:N&&&entry/src/main/ets/config/AppShadows&";
class ProfilePage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__userInfo = new ObservedPropertyObjectPU(null, this, "userInfo");
        this.__isEditing = new ObservedPropertySimplePU(false, this, "isEditing");
        this.__editNickname = new ObservedPropertySimplePU('', this, "editNickname");
        this.__editEmail = new ObservedPropertySimplePU('', this, "editEmail");
        this.__editSex = new ObservedPropertySimplePU(0, this, "editSex");
        this.__showPasswordDialog = new ObservedPropertySimplePU(false, this, "showPasswordDialog");
        this.__oldPassword = new ObservedPropertySimplePU('', this, "oldPassword");
        this.__newPassword = new ObservedPropertySimplePU('', this, "newPassword");
        this.__confirmPassword = new ObservedPropertySimplePU('', this, "confirmPassword");
        this.stateStore = StateStore;
        this.apiClient = ApiClient.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ProfilePage_Params) {
        if (params.userInfo !== undefined) {
            this.userInfo = params.userInfo;
        }
        if (params.isEditing !== undefined) {
            this.isEditing = params.isEditing;
        }
        if (params.editNickname !== undefined) {
            this.editNickname = params.editNickname;
        }
        if (params.editEmail !== undefined) {
            this.editEmail = params.editEmail;
        }
        if (params.editSex !== undefined) {
            this.editSex = params.editSex;
        }
        if (params.showPasswordDialog !== undefined) {
            this.showPasswordDialog = params.showPasswordDialog;
        }
        if (params.oldPassword !== undefined) {
            this.oldPassword = params.oldPassword;
        }
        if (params.newPassword !== undefined) {
            this.newPassword = params.newPassword;
        }
        if (params.confirmPassword !== undefined) {
            this.confirmPassword = params.confirmPassword;
        }
        if (params.stateStore !== undefined) {
            this.stateStore = params.stateStore;
        }
        if (params.apiClient !== undefined) {
            this.apiClient = params.apiClient;
        }
    }
    updateStateVars(params: ProfilePage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__userInfo.purgeDependencyOnElmtId(rmElmtId);
        this.__isEditing.purgeDependencyOnElmtId(rmElmtId);
        this.__editNickname.purgeDependencyOnElmtId(rmElmtId);
        this.__editEmail.purgeDependencyOnElmtId(rmElmtId);
        this.__editSex.purgeDependencyOnElmtId(rmElmtId);
        this.__showPasswordDialog.purgeDependencyOnElmtId(rmElmtId);
        this.__oldPassword.purgeDependencyOnElmtId(rmElmtId);
        this.__newPassword.purgeDependencyOnElmtId(rmElmtId);
        this.__confirmPassword.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__userInfo.aboutToBeDeleted();
        this.__isEditing.aboutToBeDeleted();
        this.__editNickname.aboutToBeDeleted();
        this.__editEmail.aboutToBeDeleted();
        this.__editSex.aboutToBeDeleted();
        this.__showPasswordDialog.aboutToBeDeleted();
        this.__oldPassword.aboutToBeDeleted();
        this.__newPassword.aboutToBeDeleted();
        this.__confirmPassword.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __userInfo: ObservedPropertyObjectPU<UserInfo | null>;
    get userInfo() {
        return this.__userInfo.get();
    }
    set userInfo(newValue: UserInfo | null) {
        this.__userInfo.set(newValue);
    }
    private __isEditing: ObservedPropertySimplePU<boolean>;
    get isEditing() {
        return this.__isEditing.get();
    }
    set isEditing(newValue: boolean) {
        this.__isEditing.set(newValue);
    }
    private __editNickname: ObservedPropertySimplePU<string>;
    get editNickname() {
        return this.__editNickname.get();
    }
    set editNickname(newValue: string) {
        this.__editNickname.set(newValue);
    }
    private __editEmail: ObservedPropertySimplePU<string>;
    get editEmail() {
        return this.__editEmail.get();
    }
    set editEmail(newValue: string) {
        this.__editEmail.set(newValue);
    }
    private __editSex: ObservedPropertySimplePU<number>;
    get editSex() {
        return this.__editSex.get();
    }
    set editSex(newValue: number) {
        this.__editSex.set(newValue);
    }
    private __showPasswordDialog: ObservedPropertySimplePU<boolean>;
    get showPasswordDialog() {
        return this.__showPasswordDialog.get();
    }
    set showPasswordDialog(newValue: boolean) {
        this.__showPasswordDialog.set(newValue);
    }
    private __oldPassword: ObservedPropertySimplePU<string>;
    get oldPassword() {
        return this.__oldPassword.get();
    }
    set oldPassword(newValue: string) {
        this.__oldPassword.set(newValue);
    }
    private __newPassword: ObservedPropertySimplePU<string>;
    get newPassword() {
        return this.__newPassword.get();
    }
    set newPassword(newValue: string) {
        this.__newPassword.set(newValue);
    }
    private __confirmPassword: ObservedPropertySimplePU<string>;
    get confirmPassword() {
        return this.__confirmPassword.get();
    }
    set confirmPassword(newValue: string) {
        this.__confirmPassword.set(newValue);
    }
    private stateStore;
    private apiClient;
    aboutToAppear() {
        this.loadUserInfo();
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor(AppColors.bgColor);
        }, Column);
        // 顶部导航栏
        this.buildHeader.bind(this)();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.scrollable(ScrollDirection.Vertical);
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.spaceLg);
        }, Column);
        // 用户信息卡片
        this.buildUserCard.bind(this)();
        // 统计数据
        this.buildStatistics.bind(this)();
        // 功能菜单
        this.buildFunctionMenu.bind(this)();
        // 退出登录
        this.buildLogoutButton.bind(this)();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    // 构建头部
    buildHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: AppSpacing.space3Xl, right: AppSpacing.space3Xl, top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
            Row.backgroundColor(AppColors.bgCard);
            Row.shadow(AppShadows.shadowSm);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('个人中心');
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.titleColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isEditing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('取消');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textSecondary);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.onClick(() => {
                            this.isEditing = false;
                            this.loadUserInfo();
                        });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('保存');
                        Button.fontSize(AppFonts.fontSizeBase);
                        Button.backgroundColor(AppColors.primaryColor);
                        Button.fontColor(Color.White);
                        Button.borderRadius(AppBorderRadius.radius2Xl);
                        Button.padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl });
                        Button.margin({ left: AppSpacing.spaceSm });
                        Button.onClick(() => {
                            this.saveUserInfo();
                        });
                    }, Button);
                    Button.pop();
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('编辑');
                        Button.fontSize(AppFonts.fontSizeBase);
                        Button.backgroundColor(AppColors.bgColor);
                        Button.fontColor(AppColors.textColor);
                        Button.borderRadius(AppBorderRadius.radius2Xl);
                        Button.padding({ left: AppSpacing.space2Xl, right: AppSpacing.space2Xl });
                        Button.onClick(() => {
                            this.startEditing();
                        });
                    }, Button);
                    Button.pop();
                });
            }
        }, If);
        If.pop();
        Row.pop();
    }
    // 构建用户信息卡片
    buildUserCard(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 头像
            Column.create();
            // 头像
            Column.width(100);
            // 头像
            Column.height(100);
            // 头像
            Column.backgroundColor(AppColors.primaryLight);
            // 头像
            Column.borderRadius(AppBorderRadius.radiusFull);
            // 头像
            Column.justifyContent(FlexAlign.Center);
            // 头像
            Column.onClick(() => {
                if (this.isEditing) {
                    promptAction.showToast({
                        message: '头像修改功能开发中',
                        duration: 2000
                    });
                }
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(AppIcons.profile);
            Text.fontSize(48);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isEditing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('点击修改头像');
                        Text.fontSize(AppFonts.fontSizeXs);
                        Text.fontColor(AppColors.primaryColor);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                        Text.margin({ top: AppSpacing.spaceXs });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // 头像
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 昵称和邮箱
            Column.create();
            // 昵称和邮箱
            Column.alignItems(HorizontalAlign.Center);
            // 昵称和邮箱
            Column.margin({ top: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isEditing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        TextInput.create({ placeholder: '请输入昵称' });
                        TextInput.width('100%');
                        TextInput.height(44);
                        TextInput.borderRadius(AppBorderRadius.radiusBase);
                        TextInput.backgroundColor(AppColors.bgColor);
                        TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
                        TextInput.textAlign(TextAlign.Center);
                        TextInput.fontSize(AppFonts.fontSizeLg);
                        TextInput.fontColor(AppColors.titleColor);
                        TextInput.fontWeight(AppFonts.fontWeightMedium);
                        TextInput.onChange((value: string) => {
                            this.editNickname = value.trim();
                        });
                    }, TextInput);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.userInfo?.nickname || '未设置昵称');
                        Text.fontSize(AppFonts.fontSize2Xl);
                        Text.fontWeight(AppFonts.fontWeightBold);
                        Text.fontColor(AppColors.titleColor);
                        Text.margin({ top: AppSpacing.spaceLg });
                    }, Text);
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isEditing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        TextInput.create({ placeholder: '请输入邮箱' });
                        TextInput.width('100%');
                        TextInput.height(44);
                        TextInput.borderRadius(AppBorderRadius.radiusBase);
                        TextInput.backgroundColor(AppColors.bgColor);
                        TextInput.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg });
                        TextInput.textAlign(TextAlign.Center);
                        TextInput.margin({ top: AppSpacing.spaceSm });
                        TextInput.type(InputType.Email);
                        TextInput.fontSize(AppFonts.fontSizeBase);
                        TextInput.fontColor(AppColors.textColor);
                        TextInput.onChange((value: string) => {
                            this.editEmail = value.trim();
                        });
                    }, TextInput);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.userInfo?.email || '');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textSecondary);
                        Text.margin({ top: AppSpacing.spaceXs });
                    }, Text);
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 性别选择（编辑模式）
            if (this.isEditing) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('100%');
                        Row.margin({ top: AppSpacing.spaceLg });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('性别');
                        Text.fontSize(AppFonts.fontSizeBase);
                        Text.fontColor(AppColors.textColor);
                        Text.fontWeight(AppFonts.fontWeightMedium);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('男');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(this.editSex === 1 ? Color.White : AppColors.textColor);
                        Text.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
                        Text.backgroundColor(this.editSex === 1 ? AppColors.primaryColor : AppColors.bgColor);
                        Text.borderRadius(AppBorderRadius.radiusFull);
                        Text.onClick(() => {
                            this.editSex = 1;
                        });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('女');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(this.editSex === 2 ? Color.White : AppColors.textColor);
                        Text.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
                        Text.backgroundColor(this.editSex === 2 ? AppColors.warningColor : AppColors.bgColor);
                        Text.borderRadius(AppBorderRadius.radiusFull);
                        Text.margin({ left: AppSpacing.spaceSm });
                        Text.onClick(() => {
                            this.editSex = 2;
                        });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('保密');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(this.editSex === 0 ? Color.White : AppColors.textColor);
                        Text.padding({ left: AppSpacing.spaceLg, right: AppSpacing.spaceLg, top: AppSpacing.spaceSm, bottom: AppSpacing.spaceSm });
                        Text.backgroundColor(this.editSex === 0 ? AppColors.textSecondary : AppColors.bgColor);
                        Text.borderRadius(AppBorderRadius.radiusFull);
                        Text.margin({ left: AppSpacing.spaceSm });
                        Text.onClick(() => {
                            this.editSex = 0;
                        });
                    }, Text);
                    Text.pop();
                    Row.pop();
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.userInfo?.sex === 1 ? '男' : this.userInfo?.sex === 2 ? '女' : '');
                        Text.fontSize(AppFonts.fontSizeSm);
                        Text.fontColor(AppColors.textSecondary);
                        Text.margin({ top: AppSpacing.spaceXs });
                    }, Text);
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        // 昵称和邮箱
        Column.pop();
        Column.pop();
    }
    // 构建统计数据
    buildStatistics(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(AppSpacing.space3Xl);
            Row.backgroundColor(AppColors.bgCard);
            Row.borderRadius(AppBorderRadius.radiusLg);
            Row.shadow(AppShadows.shadowBase);
            Row.margin({ bottom: AppSpacing.spaceLg });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.userInfo?.totalSteps.toLocaleString() || '0');
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.primaryColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('总步数');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.vertical(true);
            Divider.height(40);
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.userInfo?.totalPoints.toLocaleString() || '0');
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.warningColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('总积分');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.vertical(true);
            Divider.height(40);
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.layoutWeight(1);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.userInfo?.remainingSteps.toLocaleString() || '0');
            Text.fontSize(AppFonts.fontSize3Xl);
            Text.fontWeight(AppFonts.fontWeightBold);
            Text.fontColor(AppColors.successColor);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('剩余步数');
            Text.fontSize(AppFonts.fontSizeSm);
            Text.fontColor(AppColors.textSecondary);
            Text.margin({ top: AppSpacing.spaceXs });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
    }
    // 构建功能菜单
    buildFunctionMenu(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(AppSpacing.space3Xl);
            Column.backgroundColor(AppColors.bgCard);
            Column.borderRadius(AppBorderRadius.radiusLg);
            Column.shadow(AppShadows.shadowBase);
            Column.margin({ bottom: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 账户安全
            Text.create('账户安全');
            // 账户安全
            Text.fontSize(AppFonts.fontSizeSm);
            // 账户安全
            Text.fontColor(AppColors.textSecondary);
            // 账户安全
            Text.alignSelf(ItemAlign.Start);
            // 账户安全
            Text.margin({ bottom: AppSpacing.spaceLg });
        }, Text);
        // 账户安全
        Text.pop();
        this.buildMenuItem.bind(this)(AppIcons.security, '修改密码', () => {
            this.showPasswordDialog = true;
        });
        this.buildMenuItem.bind(this)(AppIcons.notification, '账号绑定', () => {
            promptAction.showToast({
                message: '账号绑定功能开发中',
                duration: 2000
            });
        });
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 通用设置
            Text.create('通用设置');
            // 通用设置
            Text.fontSize(AppFonts.fontSizeSm);
            // 通用设置
            Text.fontColor(AppColors.textSecondary);
            // 通用设置
            Text.alignSelf(ItemAlign.Start);
            // 通用设置
            Text.margin({ bottom: AppSpacing.spaceLg, top: AppSpacing.space2Xl });
        }, Text);
        // 通用设置
        Text.pop();
        this.buildMenuItem.bind(this)(AppIcons.settings, '步数设置', () => {
            promptAction.showToast({
                message: '步数设置功能开发中',
                duration: 2000
            });
        });
        this.buildMenuItem.bind(this)(AppIcons.clock, '消息通知', () => {
            promptAction.showToast({
                message: '消息通知功能开发中',
                duration: 2000
            });
        });
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 关于
            Text.create('关于');
            // 关于
            Text.fontSize(AppFonts.fontSizeSm);
            // 关于
            Text.fontColor(AppColors.textSecondary);
            // 关于
            Text.alignSelf(ItemAlign.Start);
            // 关于
            Text.margin({ bottom: AppSpacing.spaceLg, top: AppSpacing.space2Xl });
        }, Text);
        // 关于
        Text.pop();
        this.buildMenuItem.bind(this)(AppIcons.info, '关于我们', () => {
            promptAction.showToast({
                message: '版本：v1.0.0\n运动让生活更美好',
                duration: 3000
            });
        });
        this.buildMenuItem.bind(this)(AppIcons.document, '用户协议', () => {
            promptAction.showToast({
                message: '用户协议内容开发中',
                duration: 2000
            });
        });
        this.buildMenuItem.bind(this)(AppIcons.privacy, '隐私政策', () => {
            promptAction.showToast({
                message: '隐私政策内容开发中',
                duration: 2000
            });
        });
        Column.pop();
    }
    // 构建菜单项
    buildMenuItem(icon: string, title: string, onClick: () => void, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ top: AppSpacing.spaceLg, bottom: AppSpacing.spaceLg });
            Row.onClick(onClick);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(icon);
            Text.fontSize(AppFonts.fontSize2Xl);
            Text.margin({ right: AppSpacing.spaceLg });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.fontSize(AppFonts.fontSizeBase);
            Text.fontColor(AppColors.textColor);
            Text.fontWeight(AppFonts.fontWeightMedium);
            Text.layoutWeight(1);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('›');
            Text.fontSize(AppFonts.fontSizeLg);
            Text.fontColor(AppColors.borderColor);
        }, Text);
        Text.pop();
        Row.pop();
    }
    // 构建退出登录按钮
    buildLogoutButton(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding({ bottom: AppSpacing.space3Xl, top: AppSpacing.spaceLg });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('退出登录');
            Button.width('100%');
            Button.height(52);
            Button.fontSize(AppFonts.fontSizeLg);
            Button.fontWeight(AppFonts.fontWeightMedium);
            Button.backgroundColor(AppColors.errorColor);
            Button.fontColor(Color.White);
            Button.borderRadius(AppBorderRadius.radius2Xl);
            Button.onClick(() => {
                this.handleLogout();
            });
        }, Button);
        Button.pop();
        Column.pop();
    }
    // 加载用户信息
    private async loadUserInfo(): Promise<void> {
        try {
            const userInfo = await this.stateStore.getUserInfo();
            this.userInfo = userInfo;
            this.editNickname = userInfo.nickname;
            this.editEmail = userInfo.email;
            this.editSex = userInfo.sex || 0;
        }
        catch (error) {
            console.error('Failed to load user info:', error);
        }
    }
    // 开始编辑
    private startEditing(): void {
        this.isEditing = true;
        this.loadUserInfo();
    }
    // 保存用户信息
    private async saveUserInfo(): Promise<void> {
        if (!this.editNickname.trim()) {
            promptAction.showToast({
                message: '请输入昵称',
                duration: 2000
            });
            return;
        }
        if (this.editEmail && !this.editEmail.includes('@')) {
            promptAction.showToast({
                message: '请输入有效的邮箱地址',
                duration: 2000
            });
            return;
        }
        try {
            const response = await this.apiClient.updateUserInfo({
                email: this.editEmail,
                nickname: this.editNickname,
                sex: this.editSex
            });
            if (response.code === 1) {
                // 更新本地用户信息
                const newUserInfo: UserInfo = {
                    id: this.userInfo!.id,
                    username: this.userInfo!.username,
                    email: this.editEmail,
                    nickname: this.editNickname,
                    sex: this.editSex,
                    totalSteps: this.userInfo!.totalSteps,
                    totalPoints: this.userInfo!.totalPoints,
                    remainingSteps: this.userInfo!.remainingSteps
                };
                await this.stateStore.saveUserInfo(newUserInfo);
                this.userInfo = newUserInfo;
                this.isEditing = false;
                promptAction.showToast({
                    message: '✅ 保存成功',
                    duration: 2000
                });
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            console.error('Failed to save user info:', error);
            promptAction.showToast({
                message: '❌ 保存失败，请重试',
                duration: 2000
            });
        }
    }
    // 修改密码
    private async changePassword(): Promise<void> {
        if (!this.oldPassword || !this.newPassword || !this.confirmPassword) {
            promptAction.showToast({
                message: '请填写完整信息',
                duration: 2000
            });
            return;
        }
        if (this.newPassword.length < 6) {
            promptAction.showToast({
                message: '密码长度不能少于 6 位',
                duration: 2000
            });
            return;
        }
        if (this.newPassword !== this.confirmPassword) {
            promptAction.showToast({
                message: '两次输入的密码不一致',
                duration: 2000
            });
            return;
        }
        try {
            const response = await this.apiClient.updatePassword(this.oldPassword, this.newPassword);
            if (response.code === 1) {
                promptAction.showToast({
                    message: '✅ 密码修改成功',
                    duration: 2000
                });
                this.showPasswordDialog = false;
                this.oldPassword = '';
                this.newPassword = '';
                this.confirmPassword = '';
            }
            else {
                promptAction.showToast({
                    message: response.message,
                    duration: 2000
                });
            }
        }
        catch (error) {
            console.error('Failed to change password:', error);
            promptAction.showToast({
                message: '❌ 修改失败，请重试',
                duration: 2000
            });
        }
    }
    // 处理退出登录
    private async handleLogout(): Promise<void> {
        try {
            await this.stateStore.logout();
            promptAction.showToast({
                message: '👋 已退出登录',
                duration: 2000
            });
            router.clear();
            router.pushUrl({
                url: 'pages/LoginPage'
            });
        }
        catch (error) {
            console.error('Failed to logout:', error);
            promptAction.showToast({
                message: '❌ 退出失败，请重试',
                duration: 2000
            });
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "ProfilePage";
    }
}
registerNamedRoute(() => new ProfilePage(undefined, {}), "", { bundleName: "com.hssp.app", moduleName: "entry", pagePath: "pages/ProfilePage", pageFullPath: "entry/src/main/ets/pages/ProfilePage", integratedHsp: "false", moduleType: "followWithHap" });
