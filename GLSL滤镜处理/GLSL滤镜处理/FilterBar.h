//
//  FilterBar.h
//  GLSL滤镜处理
//
//  Created by 钟奇龙 on 2019/11/27.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FilterBar;
@protocol FilterBarDelegate <NSObject>

- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSInteger)index;

@end

@interface FilterBar : UIView

@property (nonatomic,strong) NSArray<NSString *> *itemList;
@property (nonatomic,weak) id<FilterBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
