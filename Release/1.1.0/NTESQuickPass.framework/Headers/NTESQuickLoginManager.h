//
//  NTESQuickLoginManager.h
//  NTESQuickPass
//
//  Created by Ke Xu on 2018/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @abstract   block
 *
 *  @说明        初始化结果的回调，返回preCheck的token信息
 */
typedef void(^NTESQLInitHandler)(NSDictionary * _Nullable params, BOOL success);

/**
 *  @abstract   block
 *
 *  @说明        运营商预取号结果的回调，返回预取号是否成功、脱敏手机号
 */
typedef void(^NTESQLGetPhoneNumHandler)(BOOL success, NSString * _Nullable securityPhone);

/**
 *  @abstract   block
 *
 *  @说明        运营商登录认证的回调，返回认证是否成功、accessToken信息
 */
typedef void(^NTESQLAuthorizeHandler)(BOOL success, NSDictionary * _Nullable params);

@interface NTESQuickLoginManager : NSObject

/**
 *  @abstract   属性
 *
 *  @说明        设置运营商预取号和授权登录接口的超时时间，单位ms，默认为3000ms
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  @abstract   单例
 *
 *  @return     返回NTESQuickLoginManager对象
 */
+ (NTESQuickLoginManager *)sharedInstance;

/**
 *  @abstract   判断当前上网卡的网络环境和运营商是否可以一键登录（必须开启蜂窝流量，必须上网网卡为移动或者电信运营商）
 */
- (BOOL)shouldQuickLogin;

/**
 *  @abstract   获取当前上网卡的运营商，1:电信 2.移动 3.联通
 */
- (NSInteger)getCarrier;

/**
 *  @abstract   配置参数
 *
 *  @param      businessID          易盾分配的业务方ID
 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
 *  @param      initHandler         返回初始化结果
 *
 */
- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout completion:(NTESQLInitHandler)initHandler;

/**
 *  @abstract   配置参数
 *
 *  @param      businessID          易盾分配的业务方ID
 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
 *  @param      urlPrefix           preCheck接口的私有化域名，若传nil或@""，默认使用@"https://ye.dun.163yun.com"
 *  @param      initHandler         返回初始化结果
 *
 */
- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout urlPrefix:(NSString * _Nullable)urlPrefix completion:(NTESQLInitHandler)initHandler;

/**
 *  @abstract   配置参数，请确保在初始化成功后再调用预取号接口
 *
 *  @param      phoneNumberHandler  返回预取号结果
 *
 */
- (void)getPhoneNumberCompletion:(NTESQLGetPhoneNumHandler)phoneNumberHandler;

/**
 *  @abstract   授权登录（取号接口），注意：此方法不要嵌套在getPhoneNumberCompletion的回调使用
 *
 *  @param      authorizeHandler    登录授权结果回调
 */
- (void)authorizeLoginCompletion:(NTESQLAuthorizeHandler)authorizeHandler;

/**
 获取当前SDK版本号
 */
- (NSString *)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
