//
//  CourseLable.m
//  eduadmin
//
//  Created by Li Jie on 9/7/15.
//  Copyright (c) 2015 PUPBOSS. All rights reserved.
//

#import "CourseLable.h"

@implementation CourseLable

- (void)setText:(NSString *)text {
    
    [super setText:text];
    if ([[[text componentsSeparatedByString:@"\n"] lastObject] isEqualToString:@"未开课"]) {
        
        self.textColor = [UIColor purpleColor];
    }
}

@end
