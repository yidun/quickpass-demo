一键登录 iOS SDK 接入指南
===
### 一、SDK集成
####1.搭建开发环境
* 1、导入 `NTESQuickPass.framework` 到XCode工程，直接拖拽`NTESQuickPass.framework`文件到Xcode工程内(请勾选Copy items if needed选项)
* 2、添加依赖库，在项目设置target -> 选项卡General ->Linked Frameworks and Libraries添加如下依赖库： 
	* `TYRZSDK.framework`
	* `EAccountApiSDK.framework`
	* `libz.1.2.8.tbd`
	* `libc++.1.tbd`
* 3、在Xcode中找到`TARGETS-->Build Setting-->Linking-->Other Linker Flags`在这个选项中需要添加 `-ObjC`
    
   __备注:__  
   
   (1)如果已存在上述的系统framework，则忽略
   
   (2)SDK 最低兼容系统版本 iOS 9.0

  
### 二、SDK 使用

#### 2.1 Object-C 工程

* 1、在项目需要使用SDK的文件中引入QuickLogin SDK头文件，如下：

		#import <NTESQuickPass/NTESQuickPass.h>
		
* 2、在需要使用一键登录的页面初始化 SDK，如下：

		- (void)viewDidLoad {
			[super viewDidLoad];
		    
			// sdk调用
			self.manager = [NTESQuickLoginManager sharedInstance];
		}
		
* 3、在使用一键登录之前，请先调用shouldQuickLogin方法，判断当前上网卡的网络环境和运营商是否可以一键登录，若可以一键登录，继续执行下面的步骤；否则，建议后续直接走降级方案（例如短信）
		
		BOOL shouldQL = [self.manager shouldQuickLogin];

* 4、使用易盾提供的businessID进行初始化业务，回调中返回初始化结果，如下：

		[self.manager registerWithBusinessID:@"yourBusinessID" timeout:3*1000 configURL:nil extData:nil completion:^(NSDictionary * _Nullable params, BOOL success) {
            if (success) {
                // 初始化成功，获取token
            } else {
            	// 初始化失败
            }
        }];
* 5、进行一键登录前，需要提前调用预取号接口，获取用户脱敏手机号，如下：

		 [self.manager getPhoneNumberCompletion:^(BOOL success, NSString * _Nullable securityPhone) {
            if (success) {
            	// 成功获取脱敏手机号
            } else {
	         	// 获取脱敏手机号失败
            }
	    }];
	    
* 6、登录认证接口（登录界面必须遵守移动、电信认证授权页面设计规范），调用方式如下：

		[self.manager authorizeLoginCompletion:^(BOOL success, NSDictionary * _Nullable params) {
	        if (success) {
	            // 取号成功，获取acessToken
	        } else {
				// 取号失败
	        }
	    }];

 __备注:__  在获取accessToken成功的回调里，结合第4步获取的token字段，做下一步check接口的验证；在获取accessToken失败的回调里做客户端的下一步处理，如短信验证。    


### 三、SDK 接口

* 1、回调block
	
		/**
		 *  @abstract   block
		 *
		 *  @说明        初始化结果的回调，返回preCheck的token信息
		 */
		typedef void(^NTESQLInitHandler)(NSDictionary * _Nullable params, BOOL success);
-		
		
		/**
		 *  @abstract   block
		 *
		 *  @说明        运营商预取号结果的回调，返回预取号是否成功、脱敏手机号
		 */
		typedef void(^NTESQLGetPhoneNumHandler)(BOOL success, NSString * _Nullable securityPhone);
-		
		
		/**
		 *  @abstract   block
		 *
		 *  @说明        运营商登录认证的回调，返回认证是否成功、accessToken信息
		 */
		typedef void(^NTESQLAuthorizeHandler)(BOOL success, NSDictionary * _Nullable params);
		
* 2、参数
		
		/**
		 *  @abstract   属性
		 *
		 *  @说明        设置运营商预取号和授权登录接口的超时时间，单位ms，默认为3000ms
		 */
		@property (nonatomic, assign) NSTimeInterval timeoutInterval;


* 3、单例

		/**
		 *  @abstract   单例
		 *
		 *  @return     返回NTESQuickLoginManager对象
		 */
		+ (NTESQuickLoginManager *)sharedInstance;

* 4、API接口

		/**
		 *  @abstract   判断当前上网卡的网络环境和运营商是否可以一键登录（必须开启蜂窝流量，必须上网网卡为移动或者电信运营商）
		 */
		- (BOOL)shouldQuickLogin;
-

		/**
		 *  @abstract   获取当前上网卡的运营商，1:电信 2.移动 3.联通
		 */
		- (NSInteger)getCarrier;
-
		
		/**
		 *  @abstract   配置参数
		 *
		 *  @param      businessID          易盾分配的业务方ID
		 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
		 *  @param      initHandler         返回初始化结果
		 *
		 */
		- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout completion:(NTESQLInitHandler)initHandler;
-
		
		/**
		 *  @abstract   配置参数
		 *
		 *  @param      businessID          易盾分配的业务方ID
		 *  @param      timeout             初始化接口超时时间，单位ms，不传或传0默认3000ms，最大不超过10000ms
		 *  @param      configURL           preCheck接口的私有化url，若传nil或@""，默认使用@"https://ye.dun.163yun.com/v1/oneclick/preCheck"
		 *  @param      extData             当设置configURL时，可以增加额外参数，接入方自行处理
		 *  @param      initHandler         返回初始化结果
		 *
		 */
		- (void)registerWithBusinessID:(NSString *)businessID timeout:(NSTimeInterval)timeout configURL:(NSString * _Nullable)configURL extData:(id _Nullable)extData completion:(NTESQLInitHandler)initHandler;
-
		
		/**
		 *  @abstract   配置参数，请确保在初始化成功后再调用预取号接口
		 *
		 *  @param      phoneNumberHandler  返回预取号结果
		 *
		 */
		- (void)getPhoneNumberCompletion:(NTESQLGetPhoneNumHandler)phoneNumberHandler;
-
		
		/**
		 *  @abstract   授权登录（取号接口），注意：此方法不要嵌套在getPhoneNumberCompletion的回调使用
		 *
		 *  @param      authorizeHandler    登录授权结果回调
		 */
		- (void)authorizeLoginCompletion:(NTESQLAuthorizeHandler)authorizeHandler;

		
__注__：因出于安全考虑，为了防止一键登录接口被恶意用户刷量造成经济损失，一键登录让接入者通过自己的服务端去调用易盾check接口，通知接入者一键登录是否通过。详细介绍请开发者参考易盾一键登录服务端接口文档。		

        
        

	
