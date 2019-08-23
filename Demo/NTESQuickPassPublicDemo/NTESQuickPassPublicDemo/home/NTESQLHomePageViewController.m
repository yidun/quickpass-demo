//
//  NTESQLHomePageViewController.m
//  NTESQuickPassPublicDemo
//
//  Created by Ke Xu on 2019/1/31.
//  Copyright © 2019 Xu Ke. All rights reserved.
//

#import "NTESQLHomePageViewController.h"
#import <Masonry.h>
#import "NTESQPDemoDefines.h"
#import "NTESQLLoginViewController.h"
#import "NTESQPHomePageViewController.h"
#import <NTESQuickPass/NTESQuickPass.h>
#import "NTESQPLoginSuccessViewController.h"
#import "NTESDemoHttpRequest.h"

@interface  NTESQLHomePageViewController() <UINavigationBarDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIButton *registerButton;

@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UIButton *exchangeButton;

@property (copy, nonatomic) NSString *token;

@property (copy, nonatomic) NSString *accessToken;

@property (nonatomic, strong) NTESQLLoginViewController *loginViewController;

@end

@implementation NTESQLHomePageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self registerQuickLogin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self customInitSubViews];
}

#pragma mark - 一键登录
- (void)registerQuickLogin {
    BOOL shouldQL = [[NTESQuickLoginManager sharedInstance] shouldQuickLogin];
    if (shouldQL) {
        [[NTESQuickLoginManager sharedInstance] registerWithBusinessID:QL_BUSINESSID timeout:3*1000 configURL:nil extData:nil completion:^(NSDictionary * _Nullable params, BOOL success) {
            if (success) {
                self.token = [params objectForKey:@"token"];
            } else {
                NSLog(@"precheck失败");
            }
        }];
    }
}

- (void)doRegister
{
    [self getPhoneNumberWithText:registerTitle];
}

- (void)doLogin
{
    [self getPhoneNumberWithText:loginTitle];
}

- (void)getPhoneNumberWithText:(NSString *)title
{
    self.loginViewController = [[NTESQLLoginViewController alloc] init];
    self.loginViewController.themeTitle = title;
    self.loginViewController.token = self.token;
    
    if ([[NTESQuickLoginManager sharedInstance] getCarrier] == 1) {
        // 电信
        [self.navigationController pushViewController:self.loginViewController animated:YES];
        [self.loginViewController getPhoneNumber];
    } else if ([[NTESQuickLoginManager sharedInstance] getCarrier] == 2) {
        // 移动
        [[NTESQuickLoginManager sharedInstance] getPhoneNumberCompletion:^(NSDictionary * _Nonnull resultDic) {
            NSNumber *boolNum = [resultDic objectForKey:@"success"];
            BOOL success = [boolNum boolValue];
            if (success) {
                [self setCMCustomUI];
                [self authorizeCMLoginWithText:title];
            } else {
                [self.navigationController pushViewController:self.loginViewController animated:YES];
                [self.loginViewController updateView];
            }
        }];
    } else {
        // 联通
        [[NTESQuickLoginManager sharedInstance] getPhoneNumberCompletion:^(NSDictionary * _Nonnull resultDic) {
            NSNumber *boolNum = [resultDic objectForKey:@"success"];
            BOOL success = [boolNum boolValue];
            if (success) {
                [self setCUCustomUI];
                [self authorizeCULoginWithText:title];
            } else {
                [self.navigationController pushViewController:self.loginViewController animated:YES];
                [self.loginViewController updateView];
            }
        }];
    }
}

- (void)authorizeCMLoginWithText:(NSString *)title
{
    [[NTESQuickLoginManager sharedInstance] authorizeLoginViewController:self result:^(NSDictionary * _Nonnull resultDic) {
        NSNumber *boolNum = [resultDic objectForKey:@"success"];
        BOOL success = [boolNum boolValue];
        if (success) {
            self.accessToken = [resultDic objectForKey:@"accessToken"];
            [self startCheckWithText:title];
        } else {
            NSString *resultCode = [resultDic objectForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"200020"]) {
                NSLog(@"取消登录");
            }
            if ([resultCode isEqualToString:@"200060"]) {
                NSLog(@"切换登录方式");
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController pushViewController:self.loginViewController animated:YES];
                [self.loginViewController updateView];
            }
        }
    }];
}

- (void)authorizeCULoginWithText:(NSString *)title
{
    [[NTESQuickLoginManager sharedInstance] authorizeLoginViewController:self result:^(NSDictionary * _Nonnull resultDic) {
        NSNumber *boolNum = [resultDic objectForKey:@"success"];
        BOOL success = [boolNum boolValue];
        if (success) {
            self.accessToken = [resultDic objectForKey:@"accessToken"];
            [self startCheckWithText:title];
        } else {
            NSString *resultCode = [resultDic objectForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"10104"]) {
                NSLog(@"取消登录");
            }
            if ([resultCode isEqualToString:@"10105"]) {
                NSLog(@"切换登录方式");
                [self.navigationController pushViewController:self.loginViewController animated:YES];
                [self.loginViewController updateView];
            }
        }
    }];
}

- (void)startCheckWithText:(NSString *)title
{
    NSDictionary *dict = @{
                           @"accessToken":self.accessToken?:@"",
                           @"token":self.token?:@"",
                           };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        return;
    }
    
    [NTESDemoHttpRequest startRequestWithURL:API_LOGIN_TOKEN_QLCHECK httpMethod:@"POST" requestData:jsonData finishBlock:^(NSData *data, NSError *error, NSInteger statusCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSNumber *code = [dict objectForKey:@"code"];
                if ([code integerValue] == 200) {
                    NSDictionary *data = [dict objectForKey:@"data"];
                    NSString *phoneNum = [data objectForKey:@"phone"];
                    if (phoneNum && phoneNum.length > 0) {
                        NTESQPLoginSuccessViewController *vc = [[NTESQPLoginSuccessViewController alloc] init];
                        vc.themeTitle = title;
                        vc.type = NTESQuickLoginType;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        [self.navigationController pushViewController:self.loginViewController animated:YES];
                        [self.loginViewController updateView];
                        [self.loginViewController showToastWithMsg:@"一键登录失败"];
                    }
                } else if ([code integerValue] == 1003){
                    [self.navigationController pushViewController:self.loginViewController animated:YES];
                    [self.loginViewController updateView];
                } else {
                    [self.navigationController pushViewController:self.loginViewController animated:YES];
                    [self.loginViewController updateView];
                    [self.loginViewController showToastWithMsg:[NSString stringWithFormat:@"错误，code=%@", code]];
                }
            } else {
                [self.navigationController pushViewController:self.loginViewController animated:YES];
                [self.loginViewController updateView];
                [self.loginViewController showToastWithMsg:[NSString stringWithFormat:@"服务器错误-%ld", (long)statusCode]];
            }
        });
    }];
}

- (void)setCUCustomUI
{
    NTESQuickLoginCUModel *CUModel = [[NTESQuickLoginCUModel alloc] init];
    CUModel.controllerType = NTESCUPresentController;
    CUModel.checkBoxValue= YES;
    
#ifdef TEST_MODE_QA
    CUModel.destroyCrollerBySelf = NO;
    CUModel.backgroundColor =[UIColor whiteColor];
    CUModel.isAutoRelease = YES;
    
    CUModel.navBottomLineHidden = YES;
    CUModel.navBarHidden = NO;
    CUModel.navTranslucent = NO;
    CUModel.navBgColor = UIColorFromHex(0x7846F1);
    CUModel.navText = @"易盾一键登录";
    CUModel.navTextColor = [UIColor whiteColor];
    CUModel.navReturnImg = [UIImage imageNamed:@"back-1"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0, 44, 44);
    [button setTitle:@"右键" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    CUModel.navControl = rightBarButtonItem;
    
    CUModel.topCustomHeight = 40;
    
    CUModel.logoImg = [UIImage imageNamed:@"logo1"];
    CUModel.logoWidth = 150;
    CUModel.logoHeight = 150;
    CUModel.logoOffsetY = 50;
    
    CUModel.appNameColor = [UIColor blackColor];
    CUModel.appNameHidden= NO;
    CUModel.appNameHidden = YES;
    
    CUModel.numberOffsetY = 20;
    CUModel.numberFont = [UIFont systemFontOfSize:26];
    
    CUModel.brandColor = UIColorFromHex(0x6551f6);
    CUModel.brandOffsetY = 25;
    
    CUModel.logBtnText = @"一键登录";
    CUModel.logBtnUsableBGColor = UIColorFromHex(0x6551f6);
    CUModel.logBtnUnusableBGColor = UIColorFromHex(0x60b1fe);
    
    CUModel.swithAccHidden=NO;
    CUModel.swithAccTextColor = UIColorFromHex(0x60b1fe);
    
    CUModel.appFPrivacyText = @"百度协议";
    CUModel.appFPrivacyUrl = @"http://www.baidu.com";
    CUModel.appSPrivacyText = @"QQ政策";
    CUModel.appSPrivacyUrl = @"http://qq.com";
    CUModel.privacyTextColor= UIColorFromHex(0x7846F1);
    CUModel.privacyColor= UIColorFromHex(0x60b1fe);
    CUModel.checkBoxHidden=NO;
    CUModel.checkBoxNormalImg = [UIImage imageNamed:@"checkBox"];
    CUModel.checkBoxCheckedImg = [UIImage imageNamed:@"checkedBox"];
    CUModel.loadingText= @"请稍后";
    
    
    CUModel.topCustomView = ^(UIView *topCustomView) {
        UILabel *label = [[UILabel alloc]init];
        [label setFrame:CGRectMake(0, 5, topCustomView.frame.size.width - 10 * 2, 40)];
        [label setBackgroundColor:[UIColor brownColor]];
        [label setText:@"自定义添加 1"];
        [topCustomView addSubview:label];
    };
    CUModel.bottomCustomView = ^(UIView *bottomCustomViews) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(10, 10, bottomCustomViews.frame.size.width - 10 * 2, 40)];
        [button setBackgroundColor:[UIColor grayColor]];
        [button setTitle:@"自定义添加 2" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testTouch) forControlEvents:UIControlEventTouchUpInside];
        CALayer *layer = [button layer];
        [layer setCornerRadius:10.0];
        
        UILabel *label = [[UILabel alloc]init];
        [label setFrame:CGRectMake(10, 10 + 40 + 10, bottomCustomViews.frame.size.width - 10 * 2, 40)];
        [label setBackgroundColor:[UIColor brownColor]];
        [label setText:@"自定义添加 3"];
        [bottomCustomViews addSubview:button];
        [bottomCustomViews addSubview:label];
    };
#endif
    
    [[NTESQuickLoginManager sharedInstance] setupCUModel:CUModel];
}

- (void)setCMCustomUI
{
    NTESQuickLoginCMModel *CMModel = [[NTESQuickLoginCMModel alloc] init];
    CMModel.privacyState = YES;
    
#ifdef TEST_MODE_QA
    CMModel.authViewBlock = ^(UIView *customView) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 400, 80)];
        [btn setTitle:@"自定义按钮" forState:(UIControlStateNormal)];
        [btn setTitleColor:UIColorFromHex(0x60b1fe) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickCustomBtn) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:btn];
    };
    CMModel.authPageBackgroundImage = [UIImage imageNamed:@"bg2"];
    
    CMModel.navColor = UIColorFromHex(0x7846F1);
    CMModel.barStyle = 1;
    CMModel.navText = [[NSAttributedString alloc]initWithString:@"易盾一键登录" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    CMModel.navReturnImg = [UIImage imageNamed:@"back-1"];
    CMModel.navHidden = NO;
    CMModel.navControl = [[UIBarButtonItem alloc]initWithTitle:@"右键" style:(UIBarButtonItemStyleDone) target:self action:@selector(clickRightBtn)];
    
    CMModel.logoImg = [UIImage imageNamed:@"logo1"];
    CMModel.logoWidth = 150;
    CMModel.logoHeight = 150;
    CMModel.logoOffsetY = 40;
    CMModel.logoHidden = NO;
    
    UIImage *norMal = [UIImage imageNamed:@"bg1"];
    UIImage *invalied = [UIImage imageNamed:@"bg1"];
    UIImage *highted = [UIImage imageNamed:@"bg1"];
    CMModel.logBtnImgs = @[norMal,invalied,highted];
    CMModel.logBtnText = @"一键登录";
    CMModel.logBtnTextColor = [UIColor whiteColor];
    CMModel.logBtnOffsetY = 260+50;
    
    CMModel.numberSize = 30;
    CMModel.numberColor = [UIColor blackColor];
    CMModel.numFieldOffsetY = 260;
    
    CMModel.swithAccTextColor = UIColorFromHex(0x60b1fe);
    CMModel.swithAccHidden = NO;
    CMModel.switchOffsetY = 260+100;
    
    CMModel.appPrivacyOne = @[@"百度协议",@"https://www.baidu.com"];
    CMModel.appPrivacyTwo = @[@"QQ政策",@"http://qq.com"];
    CMModel.appPrivacyColor = @[UIColorFromHex(0x7846F1), UIColorFromHex(0x60b1fe)];
    CMModel.checkedImg = [UIImage imageNamed:@"checkedBox"];
    CMModel.uncheckedImg = [UIImage imageNamed:@"checkBox"];
    CMModel.privacyOffsetY = 100;
    
    CMModel.sloganTextColor = UIColorFromHex(0x6551f6);
    CMModel.sloganOffsetY =  210;
#endif
    
    [[NTESQuickLoginManager sharedInstance] setupCMModel:CMModel];
}

- (void)testTouch{
    NSLog(@"test touch.");
}

- (void)clickRightBtn
{
    NSLog(@"点击了右键");
}

- (void)clickCustomBtn
{
    NSLog(@"点击了自定义按钮");
}

- (void)customInitSubViews
{
    [self __initBackgroundView];
    [self __initButton];
    [self __initBottomView];
}

- (void)__initBackgroundView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"pic_yjdl"];
        [self.view addSubview:_backgroundImageView];
        [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(@(354*KHeightScale));
        }];
        
        UIImageView *logoImageView = [[UIImageView alloc] init];
        logoImageView.image = [UIImage imageNamed:@"ico_logo_bar_white"];
        [_backgroundImageView addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(64);
            make.left.equalTo(self.view).offset(20);
            make.width.equalTo(@(30*KHeightScale));
            make.height.equalTo(@(30*KHeightScale));
        }];
        
        UILabel *homePageTitleLable = [[UILabel alloc] init];
        homePageTitleLable.text = homePageTitle;
        homePageTitleLable.font = [UIFont systemFontOfSize:28.0f*KHeightScale];
        homePageTitleLable.textColor = UIColorFromHex(0xffffff);
        [_backgroundImageView addSubview:homePageTitleLable];
        [homePageTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(logoImageView.mas_bottom).offset(26*KHeightScale);
            make.left.equalTo(self.view).offset(24);
        }];
        
        UILabel *quickPassTitleLable = [[UILabel alloc] init];
        quickPassTitleLable.text = quickLoginTitle;
        quickPassTitleLable.font = [UIFont systemFontOfSize:24.0f*KHeightScale];
        quickPassTitleLable.textColor = UIColorFromHex(0xffffff);
        [_backgroundImageView addSubview:quickPassTitleLable];
        [quickPassTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(homePageTitleLable.mas_bottom).offset(4*KHeightScale);
            make.left.equalTo(self.view).offset(24);
        }];
    }
}

- (void)__initButton
{
    if (!_exchangeButton) {
        _exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exchangeButton.backgroundColor = [UIColor clearColor];
        [_exchangeButton addTarget:self action:@selector(doExchange) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exchangeButton];
        [_exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.equalTo(@(198.5*KWidthScale));
            make.bottom.equalTo(self.backgroundImageView).offset(-17*KHeightScale);
            make.height.equalTo(@(20*KHeightScale));
        }];
        
        UILabel *exchangeLabel = [[UILabel alloc] init];
        exchangeLabel.text = changeToQuickPass;
        exchangeLabel.font = [UIFont systemFontOfSize:14.0f*KWidthScale];
        exchangeLabel.textColor = UIColorFromHex(0xffffff);
        [_exchangeButton addSubview:exchangeLabel];
        [exchangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.exchangeButton);
            make.centerY.equalTo(self.exchangeButton);
        }];
        
        UIImageView *rightImageView = [[UIImageView alloc] init];
        rightImageView.image = [UIImage imageNamed:@"ico_arrow_yjdl"];
        [_exchangeButton addSubview:rightImageView];
        [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.exchangeButton);
            make.left.equalTo(exchangeLabel.mas_right).offset(4*KWidthScale);
            make.width.equalTo(@(14*KWidthScale));
            make.height.equalTo(@(14*KWidthScale));
        }];
    }
    
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:loginTitle forState:UIControlStateNormal];
        [_loginButton setTitle:loginTitle forState:UIControlStateHighlighted];
        [_loginButton setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateNormal];
        [_loginButton setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateHighlighted];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:15.0f*KHeightScale];
        _loginButton.layer.cornerRadius = 44.0*KHeightScale/2;
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_loginButton];
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundImageView.mas_bottom).offset(90*KHeightScale);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@(44*KHeightScale));
            make.width.equalTo(@(307*KWidthScale));
        }];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 307*KWidthScale, 44*KHeightScale);
        gradientLayer.colors = @[(id)UIColorFromHex(0xAC5FF9).CGColor, (id)UIColorFromHex(0x7846F1).CGColor];
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        [_loginButton.layer insertSublayer:gradientLayer atIndex:0];
    }
    
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setTitle:registerTitle forState:UIControlStateNormal];
        [_registerButton setTitle:registerTitle forState:UIControlStateHighlighted];
        [_registerButton setTitleColor:UIColorFromHex(0x7C49F2) forState:UIControlStateNormal];
        [_registerButton setTitleColor:UIColorFromHex(0x7C49F2) forState:UIControlStateHighlighted];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:15.0f*KHeightScale];
        _registerButton.layer.cornerRadius = 44.0*KHeightScale/2;
        _registerButton.layer.masksToBounds = YES;
        _registerButton.layer.borderColor = (UIColorFromHex(0x7C49F2)).CGColor;
        _registerButton.layer.borderWidth = 1;
        [_registerButton addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_registerButton];
        [_registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginButton.mas_bottom).offset(30*KHeightScale);
            make.centerX.equalTo(self.view);
            make.height.equalTo(@(44*KHeightScale));
            make.width.equalTo(@(307*KWidthScale));
        }];
    }
}

- (void)__initBottomView
{
    UILabel *bottomCopyRightLabel = [[UILabel alloc] init];
    bottomCopyRightLabel.text = bottomCopyRightText;
    bottomCopyRightLabel.font = [UIFont systemFontOfSize:12.0*KHeightScale];
    bottomCopyRightLabel.textColor = UIColorFromHex(0x999999);
    [self.view addSubview:bottomCopyRightLabel];
    CGFloat bottomWhiteHeight = IS_IPHONE_X ? -44 : -20;
    [bottomCopyRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(bottomWhiteHeight);
    }];
}

- (void)doExchange
{
    NTESQPHomePageViewController *vc = [[NTESQPHomePageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
