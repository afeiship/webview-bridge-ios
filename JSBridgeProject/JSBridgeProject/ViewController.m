//
//  ViewController.m
//  JSBridgeProject
//
//  Created by 任斌 on 2018/7/12.
//  Copyright © 2018年 RB. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <WKWebViewJavascriptBridge.h>
@interface ViewController ()<WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) WKWebViewJavascriptBridge *webBridge;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self registerNaviFunction];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *localHtml = [NSString stringWithContentsOfFile:urlStr encoding:NSUTF8StringEncoding error:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadHTMLString:localHtml baseURL:fileURL];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self naviUseWebDemoFunc];
    });
}

#pragma mark - private func

/**
 注册本地方法 (webView调用本地的方法需要先注册，本地调用webView的方法，不能注册）
 */
- (void)registerNaviFunction {
    [self forWebViewUseDemoFunc];
}

#pragma mark - webViewUseNavi
- (void)forWebViewUseDemoFunc {
    [self.webBridge registerHandler:@"funcName" handler:^(id data, WVJBResponseCallback responseCallback) {
        //funcName 为webView触发本方法的标记字段
        //data 为webView传递过来的数据；  responseCallback 为本地传回webView数据
    }];
}


#pragma mark - naviUseWebView
- (void)naviUseWebDemoFunc {
    // 如果不需要参数，不需要回调，使用这个
    // [_webViewBridge callHandler:@"testJSFunction"];
    // 如果需要参数，不需要回调，使用这个
    // [_webViewBridge callHandler:@"testJSFunction" data:@"一个字符串"];
    // 如果既需要参数，又需要回调，使用这个
    [_webBridge callHandler:@"testJSFunction" data:@"传递给webView的参数" responseCallback:^(id responseData) {
        //funcName 为web中需要被调用的方法名
        //responseData webView传递回来的参数
        NSLog(@"%@", responseData);
    }];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alerc = [UIAlertController alertControllerWithTitle:message?:@"没说话" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1        = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alerc addAction:a1];
    [self presentViewController:alerc animated:YES completion:nil];
}

#pragma mark - getter setter
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController   = [WKUserContentController new];
        WKPreferences *prefe           = [WKPreferences new];
        prefe.javaScriptCanOpenWindowsAutomatically = YES;
        prefe.minimumFontSize          = 30;
        config.preferences             = prefe;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.UIDelegate = self;
    }
    return _webView;
}

- (WKWebViewJavascriptBridge *)webBridge {
    if (!_webBridge) {
        _webBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
        [_webBridge setWebViewDelegate:self];
    }
    return _webBridge;
}

@end
