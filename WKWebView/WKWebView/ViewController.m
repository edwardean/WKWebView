//
//  ViewController.m
//  WKWebView
//
//  Created by lihang on 2017/10/28.
//  Copyright © 2017年 Sankuai. All rights reserved.
//

#import "ViewController.h"

@import WebKit;
@interface ViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
#if 0
    [self syncEvaluatingJavaScriptFromString:@""];
#else
    //main thread blocked
    dispatch_async(dispatch_get_main_queue(), ^{
        [self syncEvaluatingJavaScriptFromString:@""];
    });
#endif
}

- (NSString *)syncEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *res = nil;
    
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    [self.webView evaluateJavaScript:script completionHandler:^(NSString *result, NSError *error){
        res = result;
        dispatch_semaphore_signal(waitSemaphore);
    }];
    
    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    return res;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
