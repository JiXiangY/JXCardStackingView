//
//  SouFunCardStackView.h
//  
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXYBaseCardView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol JXYCardStackViewDataSource <NSObject>
//加载视图
- (JXYBaseCardView *)loadCardViewWithIndex:(NSInteger)index;

@end

@protocol JXYCardStackViewDelegate <NSObject>
//当前展示的视图
@optional
- (void)cardStackViewCurrentIndex:(NSInteger)index;

@end

@interface JXYCardStackView : UIView

@property (nonatomic) NSInteger  dataCount;                                /// 数据源总量
@property (nonatomic) NSInteger  showCardsNumber;                          /// 展示的卡片数
/**
 0 1 2 3....n n+1 (0 和 n+1 是看不到的) 比实际多 2
 */
@property (nonatomic) NSInteger  realCardNumber;                           /// 实际卡片数
@property (nonatomic) CGFloat cardCornerRadius;                            /// 圆角
@property (nonatomic) CGFloat offsetX;                                     /// 展示卡片的横坐标偏移量
@property (nonatomic) CGFloat offsetY;                                     /// 展示卡片的纵坐标偏移量
@property (nonatomic) CGRect  topViewFrame;                                /// 顶图frame(标准图的大小位置)
@property (nonatomic,weak) id<JXYCardStackViewDelegate> delegate;       /// 点击代理
@property (nonatomic,weak) id<JXYCardStackViewDataSource> dataSource;   /// 数据代理 展示卡片上的view
/**
 初始化方法
 @param frame 位置
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 加载视图
 @param dataCount 数据个数
 @param showCardsNumber 显示个数
 */
- (void)loadCardViewWithDataCount:(NSInteger)dataCount showCardsNumber:(NSInteger)showCardsNumber;

@end





NS_ASSUME_NONNULL_END
