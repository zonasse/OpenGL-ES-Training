//
//  FilterBar.m
//  GLSL滤镜处理
//
//  Created by 钟奇龙 on 2019/11/27.
//  Copyright © 2019 zonasse.bupt. All rights reserved.
//

#import "FilterBar.h"
#import "FilterBarCell.h"

static NSString * const kFilterBarCellIdentifierID = @"FilterBarCell";

@interface FilterBar()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FilterBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    // 1. 设置collectionViewLayout
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    
    CGFloat itemWidth = 100;
    CGFloat itemHeight = CGRectGetHeight(self.frame);
    self.collectionViewLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 2.设置collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
    [self addSubview:self.collectionView];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[FilterBarCell class] forCellWithReuseIdentifier:kFilterBarCellIdentifierID];
    
}

- (void)setItemList:(NSArray<NSString *> *)itemList {
    _itemList = itemList;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_itemList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFilterBarCellIdentifierID forIndexPath:indexPath];
    cell.title = self.itemList[indexPath.row];
    cell.isSelected = indexPath.row == _currentIndex;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndex = indexPath.row;
    [_collectionView reloadData];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterBar:didScrollToIndex: )]) {
        [self.delegate filterBar:self didScrollToIndex:indexPath.row];
    }
}
@end
