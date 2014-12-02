//
//  TTCollectionViewLayout.m
//  CollectionTT
//
//  Created by zhoushejun on 14-11-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//


#import "TTCollectionViewLayout.h"

@interface TTCollectionViewLayout()

@property (nonatomic, assign) NSInteger numberOfCells;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat sectionSpacing;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, strong) NSArray *oldArray;
@property (nonatomic, strong) NSMutableArray *largeCellSizeArray;
@property (nonatomic, strong) NSMutableArray *smallCellSizeArray;

@end

@implementation TTCollectionViewLayout

#pragma mark - Over ride flow layout methods

- (void)prepareLayout
{
    [super prepareLayout];
    
    //delegate
    self.delegate = (id<TTCollectionViewDelegateLayout>)self.collectionView.delegate;
    //collection view size
    _collectionViewSize = self.collectionView.bounds.size;
    //some values
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionSpacing = 0;
    _insets = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        _sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
}

- (CGFloat)contentHeight
{
    CGFloat contentHeight = 0;
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    CGSize collectionViewSize = self.collectionView.bounds.size;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    CGFloat sectionSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    CGFloat itemSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    CGFloat lineSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    
    contentHeight += insets.top + insets.bottom + sectionSpacing * (numberOfSections - 1);
    
    CGFloat lastSmallCellHeight = 0;
    for (NSInteger i = 0; i < numberOfSections; i++) {
        NSInteger numberOfLines = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / 3.0f);
        
        CGFloat largeCellSideLength = (2.0f * (collectionViewSize.width - insets.left - insets.right) - itemSpacing) / 3.0f;
        CGFloat smallCellSideLength = (largeCellSideLength - itemSpacing) / 2.0f;
        CGSize largeCellSize = CGSizeMake(largeCellSideLength, largeCellSideLength);
        CGSize smallCellSize = CGSizeMake(smallCellSideLength, smallCellSideLength);
        if ([self.delegate respondsToSelector:@selector(collectionView:sizeForLargeItemsInSection:)]) {
            if (!CGSizeEqualToSize([self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:i], TTCollectionViewLayoutStyleSquare)) {
                largeCellSize = [self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:i];
                smallCellSize = CGSizeMake(collectionViewSize.width - largeCellSize.width - itemSpacing - insets.left - insets.right, (largeCellSize.height / 2.0f) - (itemSpacing / 2.0f));
            }
        }
        lastSmallCellHeight = smallCellSize.height;
        CGFloat largeCellHeight = largeCellSize.height;
        CGFloat lineHeight = numberOfLines * (largeCellHeight + lineSpacing) - lineSpacing;
        contentHeight += lineHeight;
    }
    
    NSInteger numberOfItemsInLastSection = [self.collectionView numberOfItemsInSection:numberOfSections -1];
    if ((numberOfItemsInLastSection - 1) % 3 == 0 && (numberOfItemsInLastSection - 1) % 6 != 0) {
        contentHeight -= lastSmallCellHeight + itemSpacing;
    }
    
    return contentHeight / 2;
}

- (id<TTCollectionViewDelegateLayout>)delegate
{
    return (id<TTCollectionViewDelegateLayout>)self.collectionView.delegate;
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = CGSizeMake(_collectionViewSize.width, 0);
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfLines = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / 3.0f);
        CGFloat lineHeight = numberOfLines * ([_largeCellSizeArray[i] CGSizeValue].height + _lineSpacing) - _lineSpacing;
        contentSize.height += lineHeight;
    }
    contentSize.height += _insets.top + _insets.bottom + _sectionSpacing * (self.collectionView.numberOfSections - 1);
    NSInteger numberOfItemsInLastSection = [self.collectionView numberOfItemsInSection:self.collectionView.numberOfSections - 1];
    if ((numberOfItemsInLastSection - 1) % 3 == 0 && (numberOfItemsInLastSection - 1) % 6 != 0) {
        contentSize.height -= [_smallCellSizeArray[self.collectionView.numberOfSections - 1] CGSizeValue].height + _itemSpacing;
    }
    contentSize.height =contentSize.height / 2 + _largeCellSize.height;
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    BOOL shouldUpdate = [self shouldUpdateAttributesArray];
    if (CGRectEqualToRect(_oldRect, rect) && !shouldUpdate) {
        return _oldArray;
    }
    _oldRect = rect;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfCellsInSection = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfCellsInSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    _oldArray = attributesArray;
    return  attributesArray;
}

//needs override
- (BOOL)shouldUpdateAttributesArray
{
    return NO;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //cellSize
    CGFloat largeCellSideLength = (2.0f * (_collectionViewSize.width - _insets.left - _insets.right) - _itemSpacing) / 2.5f;
    CGFloat smallCellSideLength = (largeCellSideLength - _itemSpacing) / 2.0f;
    _largeCellSize = CGSizeMake(largeCellSideLength, largeCellSideLength);
    _smallCellSize = CGSizeMake(smallCellSideLength, smallCellSideLength);
    if ([self.delegate respondsToSelector:@selector(collectionView:sizeForLargeItemsInSection:)]) {
        if (!CGSizeEqualToSize([self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section], TTCollectionViewLayoutStyleSquare)) {
            _largeCellSize = [self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section];
            _smallCellSize = CGSizeMake(_collectionViewSize.width - _largeCellSize.width - _itemSpacing - _insets.left - _insets.right, (_largeCellSize.height / 2.0f) - (_itemSpacing / 2.0f));
        }
    }
    if (!_largeCellSizeArray) {
        _largeCellSizeArray = [NSMutableArray array];
    }
    if (!_smallCellSizeArray) {
        _smallCellSizeArray = [NSMutableArray array];
    }
    _largeCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_largeCellSize];
    _smallCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_smallCellSize];
    
    //section height
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i <= indexPath.section - 1; i++) {
        NSInteger cellsCount = [self.collectionView numberOfItemsInSection:i];
        CGFloat largeCellHeight = [_largeCellSizeArray[i] CGSizeValue].height;
        CGFloat smallCellHeight = [_smallCellSizeArray[i] CGSizeValue].height;
        NSInteger lines = ceil((CGFloat)cellsCount / 3.0f);
        sectionHeight += lines * (_lineSpacing + largeCellHeight) + _sectionSpacing;
        if ((cellsCount - 1) % 3 == 0 && (cellsCount - 1) % 6 != 0) {
            sectionHeight -= smallCellHeight + _itemSpacing;
        }
    }
    if (sectionHeight > 0) {
        sectionHeight -= _lineSpacing;
    }
    _largeCellSize = _smallCellSize;
    NSInteger line = indexPath.item / 3;
    CGFloat lineSpaceForIndexPath = _lineSpacing * line;
    CGFloat lineOriginY = _largeCellSize.height * line + sectionHeight + lineSpaceForIndexPath + _insets.top;
    
    if (indexPath.item % 3 == 0) {
        attribute.frame = CGRectMake(_insets.left + 25, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else if (indexPath.item % 3 == 1) {
        attribute.frame = CGRectMake(_collectionViewSize.width - _insets.left -  _largeCellSize.width - 25, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else {
        attribute.frame = CGRectMake((_collectionViewSize.width -  _largeCellSize.width)/ 2 - _insets.left, lineOriginY + _insets.top + _largeCellSize.width / 2, _largeCellSize.width, _largeCellSize.height);
    }
    return attribute;
}

@end
