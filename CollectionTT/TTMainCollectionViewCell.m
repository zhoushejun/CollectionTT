//
//  TTMainCollectionViewCell.m
//  CollectionTT
//
//  Created by shejun.zhou on 14-11-15.
//  Copyright (c) 2014年 shejun.zhou. All rights reserved.
//

#import "TTMainCollectionViewCell.h"

@implementation TTMainCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imgView.layer.cornerRadius = 10.0;
        imgView.layer.masksToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.imageView = imgView;
        [self addSubview:self.imageView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2, 1.414 * frame.size.width, 20)];
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor  whiteColor];
        lab.font = [UIFont systemFontOfSize:18.0];
        CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_4);
        lab.transform = transform;
        self.labelTitle = lab;
        [self addSubview:self.labelTitle];
    }
    return self;
}

@end
