//
//  TTCollectionViewLayout.h
//  CollectionTT
//
//  Created by zhoushejun on 14-11-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TTCollectionViewLayoutStyleSquare CGSizeZero

@protocol TTCollectionViewDelegateLayout <UICollectionViewDelegateFlowLayout>

@optional

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section; //Default to automaticaly grow square !
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView;

@end

@protocol TTCollectionViewLayoutDatasource <UICollectionViewDataSource>

@end

@interface TTCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) id<TTCollectionViewDelegateLayout> delegate;
@property (nonatomic, assign) id<TTCollectionViewLayoutDatasource> datasource;
@property (nonatomic, assign, readonly) CGSize largeCellSize;
@property (nonatomic, assign, readonly) CGSize smallCellSize;

- (BOOL)shouldUpdateAttributesArray; //needs override
- (CGFloat)contentHeight;

@end
