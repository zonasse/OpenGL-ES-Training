//
//  FilterBarCell.m
//  GLSL滤镜处理
//
//  Created by 钟奇龙 on 2019/11/27.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "FilterBarCell.h"

@interface FilterBarCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation FilterBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectInset(self.label.frame, 10, 10);
}

- (void)commonInit {
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont boldSystemFontOfSize:15];
    self.label.layer.masksToBounds = YES;
    self.label.layer.cornerRadius = 15;
    [self addSubview:self.label];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.label.backgroundColor = isSelected ? [UIColor blackColor] : [UIColor clearColor];
    self.label.textColor = isSelected ? [UIColor whiteColor] : [UIColor blackColor];
}

@end
