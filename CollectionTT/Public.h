//
//  Public.h
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @name DEBUG 模式下打印日志和当前行数 */
// @{
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content--->>> \n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define NSLogCurrentFunction fprintf(stderr,"\nfuction:%s", __FUNCTION__);
#else
#define NSLog(FORMAT, ...) nil
#endif
// @}end of DEBUG 模式下打印日志和当前行数

/** @name 获取屏幕 宽度、高度 */
// @{
/** @attention 勿删 */
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// @}end of 获取屏幕 宽度、高度

/** @name version */
// @{
#define CurrentDevice [UIDevice currentDevice]
#define CurrentSystemVersion [CurrentDevice systemVersion]
#define IOS_VERSION [CurrentSystemVersion floatValue]
// @}end of version

/** @name 状态栏 高度 */
// @{
#define STATUSBAR_HEIGHT (IOS_VERSION < 7.0?20:0)
// @}end of 状态栏 高度

@interface Public : NSObject

@end
