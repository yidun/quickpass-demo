//
//  UASDKLogin.h
//  TYRZSDK
//
//  Created by 谢鸿标 on 2018/10/11.
//  Copyright © 2018 com.CMCC.iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UASDKVERSION @"quick_login_iOS_9.0.13"

NS_ASSUME_NONNULL_BEGIN

@interface UASDKLogin : NSObject

/**
 SDK登录单例管理
 */
@property (nonatomic,class,readonly) UASDKLogin *shareLogin;

/**
 网络类型及运营商（双卡下，获取上网卡的运营商）
 运营商： 0.未知 / 1.中国移动 / 2.中国联通 / 3.中国电信
 网络类型： 0.无网络/ 1.数据流量 / 2.wifi / 3.数据+wifi
 
 @return  @{NSString : NSNumber}
 */
@property (nonatomic,readonly) NSDictionary<NSString *, NSNumber *> *networkType;

/**
 初始化SDK参数

 @param appId 申请能力平台成功后，分配的appId
 @param appKey 申请能力平台成功后，分配的appKey
 @param encrypType 缺省参数，开发者统一填写nil
 */
- (void)registerAppId:(NSString *)appId appKey:(NSString *)appKey encrypType:(NSString *_Nullable)encrypType;

/**
 设置超时

 @param timeout 超时
 */
- (void)setTimeoutInterval:(NSTimeInterval)timeout;

/**
 取号

 @param completion 回调
 */
- (void)getPhoneNumberCompletion:(void(^)(NSDictionary *_Nonnull result))completion;

/**
 获取授权登录token

 @param completion 回调
 */
- (void)getAuthorizationCompletion:(void(^)(NSDictionary *_Nonnull result))completion;

/**
 获取本机号码校验token

 @param completion 回调
 */
- (void)mobileAuthCompletion:(void(^)(NSDictionary *_Nonnull result))completion;

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
