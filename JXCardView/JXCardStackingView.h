//
//  JXCardStackingView.h
//  JXCardView
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXCardViewProtcol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol JXCardStackingViewDelegate <NSObject>

@optional
- (void)jxCardStackingViewCurrentIndex:(NSInteger)index;

@end
@interface JXCardStackingView : UIView
@property (nonatomic,strong,readonly,nonnull) NSMutableArray <JXCardViewProtcol> * datas;   // 数据

@property (nonatomic) CGFloat cardCornerRadius;                                             // 圆角

@property (nonatomic) CGFloat    offsetX;                                                   // 展示卡片的横坐标偏移量
@property (nonatomic) CGFloat    offsetY;                                                   // 展示卡片的纵坐标偏移量
@property (nonatomic) CGRect topViewFrame;//第一个图的frame
@property (nonatomic,weak) id<JXCardStackingViewDelegate> delegate;

/**
 初始化方法
 
 @param frame 位置
 @param showCardsNumber 显示的卡片数
 @return SouFunCardStackView's object
 */
- (instancetype)initWithFrame:(CGRect)frame
              showCardsNumber:(NSInteger)showCardsNumber;

- (void)loadCardViewWithData:(NSMutableArray <JXCardViewProtcol> *)datas;

@end

NS_ASSUME_NONNULL_END
