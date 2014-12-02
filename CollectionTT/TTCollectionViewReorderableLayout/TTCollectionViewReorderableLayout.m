//
//  TTCollectionViewReorderableLayout.m
//  CollectionTT
//
//  Created by zhoushejun on 14-11-23.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//


#import "TTCollectionViewReorderableLayout.h"

typedef NS_ENUM(NSInteger, TTScrollDirction) {
    TTScrollDirctionNone,
    TTScrollDirctionUp,
    TTScrollDirctionDown
};


@interface UIImageView (TTCollectionViewReorderableLayout)

- (void)setCellCopiedImage:(UICollectionViewCell *)cell;

@end

@implementation UIImageView (TTCollectionViewReorderableLayout)

- (void)setCellCopiedImage:(UICollectionViewCell *)cell {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 4.0f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = image;
}

@end


@interface TTCollectionViewReorderableLayout()

@property (nonatomic, strong) UIView *cellFakeView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) TTScrollDirction scrollDirection;
@property (nonatomic, strong) NSIndexPath *reorderingCellIndexPath;
@property (nonatomic, assign) CGPoint reorderingCellCenter;
@property (nonatomic, assign) CGPoint cellFakeViewCenter;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic, assign) UIEdgeInsets scrollTrigerEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets scrollTrigePadding;
@property (nonatomic, assign) BOOL setUped;
@property (nonatomic, assign) BOOL needsUpdateLayout;

@end

@implementation TTCollectionViewReorderableLayout

#pragma mark - Override methods

- (id<TTCollectionViewDelegateReorderableLayout>)delegate
{
    return (id<TTCollectionViewDelegateReorderableLayout>)self.collectionView.delegate;
}

- (id<TTCollectionViewReorderableLayoutDataSource>)datasource
{
    return (id<TTCollectionViewReorderableLayoutDataSource>)self.collectionView.dataSource;
}

- (void)prepareLayout
{
    [super prepareLayout];
    //gesture
    [self setUpCollectionViewGesture];
    //scroll triger insets
    _scrollTrigerEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
    if ([self.delegate respondsToSelector:@selector(autoScrollTrigerEdgeInsets:)]) {
        _scrollTrigerEdgeInsets = [self.delegate autoScrollTrigerEdgeInsets:self.collectionView];
    }
    //scroll triger padding
    _scrollTrigePadding = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.delegate respondsToSelector:@selector(autoScrollTrigerPadding:)]) {
        _scrollTrigePadding = [self.delegate autoScrollTrigerPadding:self.collectionView];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (attribute.representedElementCategory == UICollectionElementCategoryCell) {
        if ([attribute.indexPath isEqual:_reorderingCellIndexPath]) {
            CGFloat alpha = 0;
            if ([self.delegate respondsToSelector:@selector(reorderingItemAlpha:)]) {
                alpha = [self.delegate reorderingItemAlpha:self.collectionView];
                if (alpha >= 1.0f) {
                    alpha = 1.0f;
                }else if (alpha <= 0) {
                    alpha = 0;
                }
            }
            attribute.alpha = alpha;
        }
    }
    return attribute;
}

- (BOOL)shouldUpdateAttributesArray
{
    if (_needsUpdateLayout) {
        _needsUpdateLayout = NO;
        return YES;
    }else {
        return NO;
    }
}


#pragma mark - Methods

- (void)setUpCollectionViewGesture
{
    if (!_setUped) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture]; }}
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}

- (void)setUpDisplayLink
{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

-  (void)invalidateDisplayLink
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)autoScroll
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGSize contentSize = self.collectionView.contentSize;
    CGSize boundsSize = self.collectionView.bounds.size;
    CGFloat increment = 0;
    
    if (self.scrollDirection == TTScrollDirctionDown) {
        CGFloat percentage = (((CGRectGetMaxY(_cellFakeView.frame) - contentOffset.y) - (boundsSize.height - _scrollTrigerEdgeInsets.bottom - _scrollTrigePadding.bottom)) / _scrollTrigerEdgeInsets.bottom);
        increment = 10 * percentage;
        if (increment >= 10.0f) {
            increment = 10.0f;
        }
    }else if (self.scrollDirection == TTScrollDirctionUp) {
        CGFloat percentage = (1.0f - ((CGRectGetMinY(_cellFakeView.frame) - contentOffset.y - _scrollTrigePadding.top) / _scrollTrigerEdgeInsets.top));
        increment = -10.0f * percentage;
        if (increment <= -10.0f) {
            increment = -10.0f;
        }
    }
    
    if (contentOffset.y + increment <= -contentInset.top) {
        [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat diff = -contentInset.top - contentOffset.y;
            self.collectionView.contentOffset = CGPointMake(contentOffset.x, -contentInset.top);
            _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + diff);
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        } completion:nil];
        [self invalidateDisplayLink];
        return;
    }else if (contentOffset.y + increment >= contentSize.height - boundsSize.height - contentInset.bottom) {
        [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat diff = contentSize.height - boundsSize.height - contentInset.bottom - contentOffset.y;
            self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentSize.height - boundsSize.height - contentInset.bottom);
            _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + diff);
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        } completion:nil];
        [self invalidateDisplayLink];
        return;
    }
    
    [self.collectionView performBatchUpdates:^{
        _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + increment);
        _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + increment);
    } completion:nil];
    [self moveItemIfNeeded];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //indexPath
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            //can move
            if ([self.datasource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
                if (![self.datasource collectionView:self.collectionView canMoveItemAtIndexPath:indexPath]) {
                    return;
                }
            }
            //will begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
            }
            _needsUpdateLayout = YES;
            //indexPath
            _reorderingCellIndexPath = indexPath;
            //scrolls top off
            self.collectionView.scrollsToTop = NO;
            //cell fake view
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            _cellFakeView = [[UIView alloc] initWithFrame:cell.frame];
            _cellFakeView.layer.shadowColor = [UIColor blackColor].CGColor;
            _cellFakeView.layer.shadowOffset = CGSizeMake(0, 0);
            _cellFakeView.layer.shadowOpacity = 0.5f;
            _cellFakeView.layer.shadowRadius = 3.0f;
            UIImageView *cellFakeImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            cellFakeImageView.contentMode = UIViewContentModeScaleAspectFill;
            [cellFakeImageView setCellCopiedImage:cell];
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
            cellFakeImageView.transform = transform;
            [self.collectionView addSubview:_cellFakeView];
            [_cellFakeView addSubview:cellFakeImageView];
            //set center
            _reorderingCellCenter = cell.center;
            _cellFakeViewCenter = _cellFakeView.center;
            [self invalidateLayout];
            //animation
            CGRect fakeViewRect = CGRectMake(cell.center.x - (self.smallCellSize.width / 2.0f), cell.center.y - (self.smallCellSize.height / 2.0f), self.smallCellSize.width, self.smallCellSize.height);
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _cellFakeView.center = cell.center;
                _cellFakeView.frame = fakeViewRect;
            } completion:^(BOOL finished) {
            }];
            //did begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self didBeginDraggingItemAtIndexPath:indexPath];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            NSIndexPath *currentCellIndexPath = _reorderingCellIndexPath;
            //will end dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentCellIndexPath];
            }
            _needsUpdateLayout = YES;
            //scrolls top on
            self.collectionView.scrollsToTop = YES;
            //disable auto scroll
            [self invalidateDisplayLink];
            //remove fake view
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:currentCellIndexPath];
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _cellFakeView.frame = attributes.frame;
            } completion:^(BOOL finished) {
                [_cellFakeView removeFromSuperview];
                _cellFakeView = nil;
                _reorderingCellIndexPath = nil;
                _reorderingCellCenter = CGPointZero;
                _cellFakeViewCenter = CGPointZero;
                [self invalidateLayout];
                if (finished) {
                    //did end dragging
                    if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
                        [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:currentCellIndexPath];
                    }
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            //translation
            _panTranslation = [pan translationInView:self.collectionView];
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            //move layout
            [self moveItemIfNeeded];
            //scroll
            if (CGRectGetMaxY(_cellFakeView.frame) >= self.collectionView.contentOffset.y + (self.collectionView.bounds.size.height - _scrollTrigerEdgeInsets.bottom -_scrollTrigePadding.bottom)) {
                if (ceilf(self.collectionView.contentOffset.y) < self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
                    self.scrollDirection = TTScrollDirctionDown;
                    [self setUpDisplayLink];
                }
            }else if (CGRectGetMinY(_cellFakeView.frame) <= self.collectionView.contentOffset.y + _scrollTrigerEdgeInsets.top + _scrollTrigePadding.top) {
                if (self.collectionView.contentOffset.y > -self.collectionView.contentInset.top) {
                    self.scrollDirection = TTScrollDirctionUp;
                    [self setUpDisplayLink];
                }
            }else {
                self.scrollDirection = TTScrollDirctionNone;
                [self invalidateDisplayLink];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self invalidateDisplayLink];
            break;
            
        default:
            break;
    }
}

- (void)moveItemIfNeeded
{
    NSIndexPath *atIndexPath = _reorderingCellIndexPath;
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    
    if (toIndexPath == nil || [atIndexPath isEqual:toIndexPath]) {
        return;
    }
    //can move
    if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)]) {
        if (![self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath canMoveToIndexPath:toIndexPath]) {
            return;
        }
    }
    
    //will move
    if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
        [self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath willMoveToIndexPath:toIndexPath];
    }
    
    _needsUpdateLayout = YES;
    //move
    [self.collectionView performBatchUpdates:^{
        //update cell indexPath
        _reorderingCellIndexPath = toIndexPath;
        [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
        //did move
        if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
            [self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath didMoveToIndexPath:toIndexPath];
        }
    } completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state != 0 && _longPressGesture.state != 5) {
            if ([_longPressGesture isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if ([_panGesture isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }
    return YES;
}

@end
