//
//  UASDKErrorCode.h
//  TYRZSDK
//
//  Created by 谢鸿标 on 2018/10/24.
//  Copyright © 2018 com.CMCC.iOS. All rights reserved.
//

#ifndef UASDKErrorCode_h
#define UASDKErrorCode_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UASDKErrorCode) {
    
    // 客户端返回码
    UASDKErrorCodeSuccess                              = 103000,
    //无网络（4G网络下，App未被允许访问蜂窝网）
    UASDKErrorCodeNoNetwork                            = 200022,
    //请求超时
    UASDKErrorCodeRequestTimeout                       = 200023,
    //未知错误，一般配合描述分析
    UASDKErrorCodeUnknownError                         = 200025,
    //蜂窝未开启（纯WiFi状态下返回该错误码）
    UASDKErrorCodeNonCellularNetwork                   = 200027,
    //重定向失败
    UASDKErrorCodeWAPRedirectFailed                    = 200038,
    //手机没有SIM卡
    UASDKErrorCodePhoneWithoutSIM                      = 200048,
    //Socket创建失败或发送接收数据错误
    UASDKErrorCodeSocketError                          = 200050,
    //异常数据
    UASDKErrorCodeExceptionData                        = 200064,
    //CA根证书认证失败
    UASDKErrorCodeCAAuthFailed                         = 200072,
    //本机号码校验仅支持移动号码
    UASDKErrorCodeMobileAuthCMCCOnly                   = 200080,
    
};

#endif /* UASDKErrorCode_h */
