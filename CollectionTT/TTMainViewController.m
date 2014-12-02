//
//  TTMainViewController.m
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTMainCollectionViewCell.h"
#import "TTDetailViewController.h"


CGFloat spacing = 30.0f;

@interface TTMainViewController ()

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, assign) BOOL isLongPressGesture;

@end

@implementation TTMainViewController
@synthesize myCollectionView;
@synthesize isLongPressGesture;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Test";
    self.isLongPressGesture = NO;
    [self setupPhotosArray];

#ifdef Custom_Layout
        TTCollectionViewReorderableLayout *FlowLayout = [[TTCollectionViewReorderableLayout alloc] init];
#else
    UICollectionViewFlowLayout *FlowLayout = [[UICollectionViewFlowLayout alloc] init];
#endif
    
    UICollectionView *CollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:FlowLayout];
    [CollectionView registerClass:[TTMainCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    CollectionView.dataSource = self;
    CollectionView.delegate = self;
    CollectionView.backgroundColor = [UIColor clearColor];
    self.myCollectionView = CollectionView;
    [self.view addSubview:self.myCollectionView];
}

- (void)setupPhotosArray
{
    self.arrayData = [NSMutableArray array];
    for (NSInteger i = 1; i <= 20; i++) {
        NSString *photoName = [NSString stringWithFormat:@"cal.png"];
        if (i %2 == 0) {
            photoName = [NSString stringWithFormat:@"date.png"];
        }
        [self.arrayData addObject:photoName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.arrayData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TTMainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.imageView.frame = cell.bounds;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self.arrayData objectAtIndex:indexPath.row]]];
    cell.labelTitle.text = [NSString stringWithFormat:@"%i-%@", indexPath.row, [self.arrayData objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TTDetailViewController *DetailViewController = [[TTDetailViewController alloc] init];
    DetailViewController.strImageName = [NSString stringWithFormat:@"cal.png"];
    [self.navigationController pushViewController:DetailViewController animated:YES];
}

#ifdef Custom_Layout

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return spacing * 2;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return spacing;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return spacing * 2;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(spacing, 0, spacing, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    return TTCollectionViewLayoutStyleSquare; //same as default !
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.0f, 0, 50.0f, 0); //Sorry, horizontal scroll is not supported now.
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.0f, 0, 0, 0);
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    NSLogCurrentFunction;
    return 0.5f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.myCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath{
    [self.myCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:fromIndexPath, toIndexPath, nil]];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *strImage = [self.arrayData objectAtIndex:fromIndexPath.item];
    [self.arrayData replaceObjectAtIndex:fromIndexPath.item withObject:self.arrayData[toIndexPath.item]];
    [self.arrayData replaceObjectAtIndex:toIndexPath.item withObject:strImage];
    [self.myCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:fromIndexPath, toIndexPath, nil]];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#else

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(110, 110);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    return UIEdgeInsetsMake(25, 25, 25, 25);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 50.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 20.0;
}

#endif

@end
