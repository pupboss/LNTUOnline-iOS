//
//  PushViewController.h
//  eduadmin
//
//  Created by Li Jie on 15/2/15.
//  Copyright (c) 2015年 PUPBOSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *footLabel;


@property (nonatomic, copy) NSString *recievedContent;
@property (nonatomic, copy) NSString *url;

@end
