//
//  TTTool.m
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "TTTool.h"
#import <UIKit/UIKit.h>

int bg_tag = 999999990;

@implementation TTTool
//创建一个复层显示在屏幕上
+ (void)addALaryerOnWindow:(NSString *)string{
    [self removeALaryerOnWindow];
//    CGSize titleBrandSizeForHeight = [string sizeWithFont:[UIFont systemFontOfSize:15]];
    CGSize titleBrandSizeForHeight = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]}];
    int h = 2*titleBrandSizeForHeight.height;
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 40 - titleBrandSizeForHeight.width)/2, SCREEN_HEIGHT-h-50,40 + titleBrandSizeForHeight.width, h)];
    [bg setBackgroundColor:[UIColor blackColor]];
    bg.tag = bg_tag;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40 + titleBrandSizeForHeight.width,h)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = string;
    lab.font = [UIFont systemFontOfSize:12];
    [lab setTextColor:[UIColor whiteColor]];
    [lab setBackgroundColor:[UIColor clearColor]];
    lab.numberOfLines = 0;
    [bg addSubview:lab];
    
    bg.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    bg.alpha = 1.0;
    [UIView commitAnimations];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:bg];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeALaryerOnWindow) userInfo:nil repeats:NO];
}

+ (void)removeALaryerOnWindow{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *bg = [window viewWithTag:bg_tag];
    if (bg != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(hidenBG)];
        bg.alpha = 0.0;
        [UIView commitAnimations];
    }
}

+ (void)hidenBG{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *bg = [window viewWithTag:bg_tag];
    if (bg != nil) {
        [bg removeFromSuperview];
        bg = nil;
    }
}
@end
