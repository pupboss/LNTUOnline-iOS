//
//  NoticeViewController.m
//  eduadmin
//
//  Created by Li Jie on 14/12/31.
//  Copyright (c) 2014年 PUPBOSS. All rights reserved.
//

#import "NoticeViewController.h"
#import "Common.h"
#import "MBProgressHUD+LJ.h"

@interface NoticeViewController () <UIWebViewDelegate>

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:NOTICEURL];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:req];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [MBProgressHUD showError:@"点击右上角用 Safari 访问"];
}


- (IBAction)goToSafari:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NOTICEURL]];
}

@end
