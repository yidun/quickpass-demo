//
//  NTESQuickLoginCMModel.h
//  NTESQuickPass
//
//  Created by Ke Xu on 2019/7/16.
//

#import <UIKit/UIKit.h>

/**
 *  移动授权页面自定义项
 */

@interface NTESQuickLoginCMModel : NSObject

/**
 版本注意事项:
 授权页面的各个控件的Y轴默认值都是以375*667屏幕为基准 系数 ： 当前屏幕高度/667
 1、当设置Y轴并有效时 偏移量OffsetY属于相对导航栏的绝对Y值
 2、（负数且超出当前屏幕无效）为保证各个屏幕适配,请自行设置好Y轴在屏幕上的比例（推荐:当前屏幕高度/667）
 */

#pragma mark -----------------------------授权页面----------------------------------

#pragma mark 自定义控件
/**授权界面自定义控件View的Block*/
@property (nonatomic,copy) void(^authViewBlock)(UIView *customView);
/**授权界面背景图片*/
@property (nonatomic,strong) UIImage *authPageBackgroundImage;

#pragma mark 导航栏
/**导航栏颜色*/
@property (nonatomic,strong) UIColor *navColor;
/**状态栏着色样式*/
@property (nonatomic,assign) UIBarStyle barStyle;
/**导航栏标题*/
@property (nonatomic,strong) NSAttributedString *navText;
/**导航返回图标(尺寸根据图片大小)*/
@property (nonatomic,strong) UIImage *navReturnImg;
/**是否隐藏导航栏，默认不隐藏，隐藏后可自定义状态栏*/
@property (nonatomic,assign) BOOL navHidden;
/**导航栏右侧自定义控件（导航栏传 UIBarButtonItem对象 自定义传非UIBarButtonItem ）*/
@property (nonatomic,strong) id navControl;

#pragma mark 图片设置
/**LOGO图片*/
@property (nonatomic,strong) UIImage *logoImg;
/**LOGO图片宽度*/
@property (nonatomic,assign) CGFloat logoWidth;
/**LOGO图片高度*/
@property (nonatomic,assign) CGFloat logoHeight;
/**LOGO图片偏移量*/
@property (nonatomic,assign) CGFloat logoOffsetY;
/**LOGO图片隐藏*/
@property (nonatomic,assign) BOOL logoHidden;

#pragma mark 登录按钮
/**登录按钮文本*/
@property (nonatomic,strong) NSString *logBtnText;
/**登录按钮Y偏移量*/
@property (nonatomic,assign) CGFloat logBtnOffsetY;
/**登录按钮文本颜色*/
@property (nonatomic,strong) UIColor *logBtnTextColor;
/**登录按钮背景图片添加到数组(顺序如下)
 @[激活状态的图片,失效状态的图片,高亮状态的图片]
 */
@property (nonatomic,strong) NSArray *logBtnImgs;

#pragma mark 号码框设置
/**手机号码字体颜色*/
@property (nonatomic,strong) UIColor *numberColor;
/**手机号码字体大小*/
@property (nonatomic,assign) CGFloat numberSize;
/**隐藏切换账号按钮*/
@property (nonatomic,assign) BOOL swithAccHidden;
/**切换账号字体颜色*/
@property (nonatomic,strong) UIColor *swithAccTextColor;
/**设置切换账号相对于标题栏下边缘y偏移*/
@property (nonatomic,assign) CGFloat switchOffsetY;
/**号码栏Y偏移量*/
@property (nonatomic,assign) CGFloat numFieldOffsetY;

#pragma mark 隐私条款
/**复选框未选中时图片*/
@property (nonatomic,strong) UIImage *uncheckedImg;
/**复选框选中时图片*/
@property (nonatomic,strong) UIImage *checkedImg;
/**隐私条款一:数组（务必按顺序）
 @[条款名称,条款链接]
 */
@property (nonatomic,strong) NSArray *appPrivacyOne;
/**隐私条款二:数组（务必按顺序）
 @[条款名称,条款链接]
 */
@property (nonatomic,strong) NSArray *appPrivacyTwo;
/**隐私条款名称颜色
 @[基础文字颜色,条款颜色]
 */
@property (nonatomic,strong) NSArray *appPrivacyColor;
/**隐私条款Y偏移量(注:此属性为与屏幕底部的距离)*/
@property (nonatomic,assign) CGFloat privacyOffsetY;
/**隐私条款check框默认状态 默认:NO */
@property (nonatomic,assign) BOOL privacyState;

#pragma mark 底部标识Title
/**slogan偏移量Y*/
@property (nonatomic,assign) CGFloat sloganOffsetY;
/**slogan文字颜色*/
@property (nonatomic,strong) UIColor *sloganTextColor;

@end
