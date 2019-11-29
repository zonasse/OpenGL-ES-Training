//
//  FilterBarCell.h
//  GLSL滤镜处理
//
//  Created by 钟奇龙 on 2019/11/27.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBarCell : UICollectionViewCell

@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
