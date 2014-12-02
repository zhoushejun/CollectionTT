//
//  TTMainViewController.h
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTCollectionViewReorderableLayout.h"

#ifdef Custom_Layout
@interface TTMainViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, TTCollectionViewDelegateReorderableLayout, TTCollectionViewReorderableLayoutDataSource>
#else
@interface TTMainViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

#endif

@property (nonatomic, strong) UICollectionView *myCollectionView;

@end
