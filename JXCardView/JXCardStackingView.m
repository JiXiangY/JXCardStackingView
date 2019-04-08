//
//  JXCardStackingView.m
//  JXCardView
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import "JXCardStackingView.h"
@interface JXCardStackingView (){
    
    __strong SouFunBaseCardView * tempView;
    float sizePercent;                                                  // 顶部卡片拖动中，底部卡片缩放系数
}

@property (nonatomic,strong,readonly) NSMutableArray * alphaArray;      // 可视卡片透明度数组
@property (nonatomic,strong) UIPanGestureRecognizer  * cardPan;         ///> 拖动
@property (nonatomic) NSInteger  showCardsNumber;                       // 展示的卡片数
@property (nonatomic) NSInteger  currentIndex;                          // 当前index
@property (nonatomic) CGPoint    oldCenter;
@property (nonatomic) NSInteger  cardCount;                             // 卡片总量

@end
@implementation JXCardStackingView

- (instancetype)initWithFrame:(CGRect)frame
              showCardsNumber:(NSInteger)showCardsNumber {
    
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        sizePercent = 0.05;
        self.showCardsNumber = showCardsNumber;
    }
    return self;
}

#pragma mark - 手势 
- (void)panHandle:(UIPanGestureRecognizer *)pan {
    
    // 获取顶部视图
    SouFunBaseCardView * cardView = self.cards[self.currentIndex];
    
    CGPoint velocity = [pan velocityInView:[UIApplication sharedApplication].keyWindow];
    
    // 开始拖动
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 缓存卡片最初的位置信息
        self.oldCenter = cardView.center;
    }
    
    // 拖动中
    {
        // 给顶部视图添加动画
        CGPoint transLcation = [pan translationInView:cardView];
        // 视图跟随手势移动
        CGFloat newCenterX = cardView.center.x + transLcation.x;
        if (newCenterX > self.oldCenter.x) {
            newCenterX = self.oldCenter.x;
        }
        cardView.center = CGPointMake(newCenterX, cardView.center.y);
        // 计算偏移系数
        CGFloat XOffPercent = (cardView.center.x - self.center.x)/(self.center.x);
        CGFloat XOff = (cardView.center.x - self.center.x);
        cardView.transform = CGAffineTransformMakeTranslation(XOff, 0);
        [pan setTranslation:CGPointZero inView:cardView];
        // 给其余底部视图添加缩放动画
        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];
    }
    
    // 拖动结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        // 移除拖动视图逻辑
        // 加速度 小于 1100points/second
        if (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 1100.0) {
            
            // 移动区域半径大于120pt
            if ((sqrt(pow(self.oldCenter.x-cardView.center.x,2) + pow(self.oldCenter.y-cardView.center.y,2))) > 120) {
                
                // 移除，自然垂落
                [UIView animateWithDuration:0.6 animations:^{
                    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
                    CGRect rect = [cardView convertRect:cardView.bounds toView:window];
                    cardView.center = CGPointMake(cardView.center.x, cardView.center.y+(kScreenHeight-rect.origin.y+50));
                }];
                [self animationBlowViewWithXOffPercent:1];
                [self performSelector:@selector(cardRemove:) withObject:cardView afterDelay:0.5];
                
            }else {
                
                __weak typeof(self) weakSelf = self;
                // 不移除，回到初始位置
                [UIView animateWithDuration:0.5 animations:^{
                    cardView.center = weakSelf.oldCenter;
                    cardView.transform = CGAffineTransformMakeRotation(0);
                    [self animationBlowViewWithXOffPercent:0];
                }];
            }
        }else {
            
            // 移除，以手势速度飞出
            [UIView animateWithDuration:0.5 animations:^{
                cardView.center = velocity;
            }];
            [self animationBlowViewWithXOffPercent:1];
            [self performSelector:@selector(cardRemove:) withObject:cardView afterDelay:0.25];
        }
    }
}
- (void)cardRemove:(SouFunBaseCardView *)card {
    
    if (card) {
        [card removeGestureRecognizer:self.cardPan];
        [card removeFromSuperview];
        
    }
    
    self.currentIndex --;
    if ((NSInteger)self.currentIndex < 0) {
        self.currentIndex = self.cardCount - 1;
    }
    
    [self addPanGestureWithView:self.cards[self.currentIndex]];
    [self addNewCard];
}


#pragma mark - 加载数据

- (void)loadCardViewWithData:(NSMutableArray<SouFunBaseCardView *> *)cards {
    
    if (nil == cards) {
        NSLog(@"卡片数据源为nil");
        return;
    }
    
    if (self.showCardsNumber == 0) {
        NSLog(@"未设置显示卡片数，将使用默认值：4");
        self.showCardsNumber = 4;
    }
    
    if (cards) {
        NSLog(@"重新设置数据源，移除旧视图");
        if (self.subviews.count > 0) {
            for (UIView *subV in self.subviews) {
                if ([subV isKindOfClass:[SouFunBaseCardView class]] ||
                    [subV.layer.name isEqualToString:tabCardNoDataString]) {
                    [subV removeFromSuperview];
                }
            }
        }
    }
    
    _cards = cards;
    self.cardCount = cards.count;
    [self addCardViewsToShow];
}






@end
