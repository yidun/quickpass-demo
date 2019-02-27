//
//  UASDKLogin.h
//  TYRZSDK
//
//  Created by 谢鸿标 on 2018/10/11.
//  Copyright © 2018 com.CMCC.iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UASDKVERSION @"quick_login_iOS_9.0.11"

NS_ASSUME_NONNULL_BEGIN

@class UAAuthViewController;

@interface UASDKLogin : NSObject

/**
 网络类型及运营商（双卡下，获取上网卡的运营商）
 运营商： 0.未知 / 1.中国移动 / 2.中国联通 / 3.中国电信
 网络类型： 0.无网络/ 1.数据流量 / 2.wifi / 3.数据+wifi
 
 @return  @{NSString : NSNumber}
 */
@property (nonatomic,readonly) NSDictionary<NSString *, NSNumber *> *networkType;

/**
 SDK登录单例管理
 */
@property (nonatomic,class,readonly) UASDKLogin *shareLogin;

/**
 登录超时设置
 
 @param timeoutInterval 单位ms（默认8000毫秒）
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 初始化SDK参数
 
 @param appId 申请能力平台成功后，分配的appId
 @param appKey 申请能力平台成功后，分配的appKey
 */
- (void)registerAppId:(NSString *)appId AppKey:(NSString *)appKey;

/**
 取号，可以先于授权登录getAuthorizationWithAuthViewController调用，目的是减少网关取号带来的成功率低的问题
 
 注：此方法的回调不要嵌套getAuthorizationWithAuthViewController使用
 
 @param completion 回调
 */
- (void)getPhoneNumberCompletion:(void (^)(NSDictionary * sender))completion;

/**
 一键登录，获取到的token，可传给移动认证服务端获取完整手机号
 
 @param completion 回调
 */
- (void)getAuthorizationCompletion:(void (^)(NSDictionary *sender))completion;


/**
 本机号码校验，获取到的token，要结合用户输入的手机号码传给移动认证服务端
 
 @param completion 回调
 */
- (void)mobileAuthCompletion:(void (^)(NSDictionary *sender))completion;

/**
 删除取号缓存数据
 
 @return YES：有缓存已执行删除操作，NO：无缓存不执行删除操作
 */
- (BOOL)delectScrip;

/**
 控制台日志输出控制（默认关闭）
 
 @param enable 开关参数
 */
- (void)printConsoleEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
