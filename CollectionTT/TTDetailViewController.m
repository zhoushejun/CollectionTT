//
//  TTDetailViewController.m
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "TTDetailViewController.h"

@interface TTDetailViewController ()

@end

@implementation TTDetailViewController
@synthesize strImageName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Detail";
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strImageName]];
    imgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:imgView];
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

@end
