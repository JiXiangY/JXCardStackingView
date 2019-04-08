//
//  SouFunCardStackView.m
//
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//  功用 : 堆叠卡片视图

#import "JXYCardStackView.h"


@interface JXYCardStackView ()<UIGestureRecognizerDelegate>
{
    CGFloat  _bToSScale;                           /// 1 - 小/大 大图缩小时使用的比例
    CGFloat  _sToBScale;                           /// 大/小 - 1 小图放大时使用比例
    CGFloat  _alphaPercent;                        /// 透明度差值
    CGPoint  _startPanPoint;                       /// 当前手势起点坐标
}

@property (nonatomic, strong) UIPanGestureRecognizer  * cardPan;            ///拖动手势
@property (nonatomic, strong) NSMutableArray <JXYCardModel * > * cardModels;///卡片属性数组
@property (nonatomic, strong) NSMutableArray <JXYBaseCardView * > * cards;  ///卡片数组
@end

@implementation JXYCardStackView
NSInteger getCurrentIndex(NSInteger currentIndex,NSInteger max);
//初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _bToSScale = 0.05;
        _sToBScale = 1/(1-_bToSScale) - 1;
    }
    return self;
}
#pragma mark - 创建视图

- (void)loadCardViewWithDataCount:(NSInteger)dataCount showCardsNumber:(NSInteger)showCardsNumber {
    self.showCardsNumber = showCardsNumber;
    if (0 == dataCount) {
        NSLog(@"卡片数据源为0");
        return;
    }
    if (self.showCardsNumber == 0) {
        NSLog(@"未设置显示卡片数，将使用默认值：4");
        self.showCardsNumber = 4;
    }
    self.dataCount = dataCount;
    self.realCardNumber = self.showCardsNumber + 2;
    [self createCardViewsToShow];
}

//第一次加载视图
- (void)createCardViewsToShow {
    if (self.dataSource == nil || ![self.dataSource respondsToSelector:@selector(loadCardViewWithIndex:)]) {
        return;
    }
    //视图添加手势
    [self addGestureRecognizer:self.cardPan];
    
    for (int i = 0; i <self.realCardNumber; i++) {
        NSInteger index = 0;
        if (i == 0){
            index = _dataCount - 1;
        }else{
            index  = getCurrentIndex((NSInteger)i-1,_dataCount);
        }
        JXYBaseCardView * cardView = [self.dataSource loadCardViewWithIndex:index];
        cardView.frame = self.cardModels[i].frame;
        cardView.transform = CGAffineTransformMakeScale( self.cardModels[i].currentScale,  self.cardModels[i].currentScale);
        cardView.center = self.cardModels[i].center;
        cardView.alpha = self.cardModels[i].alpha;
        cardView.layer.cornerRadius = self.cardCornerRadius;
        cardView.index = index;
        cardView.layer.masksToBounds = YES;
        cardView.backgroundColor = [UIColor clearColor];
        [self addSubview:cardView];
        if (i != 0) {
            //插到前一个后面
            [self insertSubview:cardView belowSubview:[self.cards lastObject]];
        }
        [self.cards addObject:cardView];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardStackViewCurrentIndex:)]) {
        [self.delegate cardStackViewCurrentIndex:[self.cards objectAtIndex:1].index];
    }
}

//创建一个屏幕外的View
- (void)addNewCardToFirst
{
    JXYBaseCardView * otherView = [self.cards firstObject];
    NSInteger index = otherView.index-1>=0?otherView.index-1:self.dataCount-1;
    JXYBaseCardView * cardView = [self.dataSource loadCardViewWithIndex:index];
    cardView.frame = [self.cardModels firstObject].frame;
    cardView.layer.cornerRadius = self.cardCornerRadius;
    cardView.layer.masksToBounds = YES;
    cardView.backgroundColor = [UIColor clearColor];
    cardView.index = index;
    [self addSubview:cardView];
    [self.cards insertObject:cardView atIndex:0];
}
// 在最后新增一个卡片 隐藏的
- (void)addNewCardToLast
{
    // 取最后一个的坐标
    NSInteger lastIndex = [[self.cards lastObject] index];
    NSInteger newCardIndex = getCurrentIndex(lastIndex+1, self.dataCount);
    JXYBaseCardView *cardView = [self.dataSource loadCardViewWithIndex:newCardIndex];
    cardView.index = newCardIndex;
    cardView.frame  = [self.cardModels lastObject].frame;
    cardView.transform  = CGAffineTransformMakeScale( [self.cardModels lastObject].currentScale,  [self.cardModels lastObject].currentScale);;
    cardView.center = [self.cardModels lastObject].center;
    cardView.alpha  = [self.cardModels lastObject].alpha;
    cardView.layer.cornerRadius = self.cardCornerRadius;
    cardView.layer.masksToBounds = YES;
    [self addSubview:cardView];
    if (cardView != nil) {
        [self.cards addObject:cardView];
        //把视图层级放数组到最后
        [self insertSubview:cardView belowSubview:[self.cards objectAtIndex:self.cards.count - 2]];
    }
}

//获取创建view在数据源的位置
NSInteger getCurrentIndex(NSInteger currentIndex,NSInteger max)
{
    if (currentIndex >= max) {
        currentIndex = currentIndex - max;
        getCurrentIndex(currentIndex,max);
    }
    return currentIndex;
}

#pragma mark - 拖动 + 动画
- (void)panHandle:(UIPanGestureRecognizer *)pan
{
    //速度
    CGPoint velocity = [pan velocityInView:[UIApplication sharedApplication].keyWindow];
    //手势当前坐标
    CGPoint currentPanPoint = [pan locationInView:self];
    //偏移比例 (view的最大移动距离/手势的最大移动距离)
    CGFloat moveScale = CGRectGetMaxX(self.topViewFrame)/self.frame.size.width;
    //    NSLog(@"\n坐标:%@\n偏移量:%@",NSStringFromCGPoint([pan locationInView:self]),NSStringFromCGPoint([pan translationInView:self]));
    // 开始拖动
    if (pan.state == UIGestureRecognizerStateBegan) {
        //获取手势起点坐标
        _startPanPoint = currentPanPoint;
        return;
    }
    
    // 拖动中
    {
        //当前手势坐标
        if ( currentPanPoint.x - _startPanPoint.x <= 0) {
            // 获取顶部视图
            JXYBaseCardView * cardView = [self.cards objectAtIndex:1];
            //偏移量
            CGPoint transLcation = [pan translationInView:self];
            // 视图跟随手势移动
            CGFloat newCenterX = cardView.center.x + transLcation.x*moveScale;
            cardView.center = CGPointMake(newCenterX, cardView.center.y);
            // 计算偏移系数
            CGFloat XOffPercent = (CGRectGetMaxX(cardView.frame)-CGRectGetMaxX(_topViewFrame))/CGRectGetMaxX(_topViewFrame);
            [pan setTranslation:CGPointZero inView:self];
            // 给其余底部视图添加缩放动画
            [self leftAnimationBlowViewWithXOffPercent:-XOffPercent];
        }else{
            //设置隐藏的视图
            JXYBaseCardView * cardView = [self.cards firstObject];
            CGPoint transLcation = [pan translationInView:self];
            CGFloat newCenterX = cardView.center.x + transLcation.x*moveScale;
            cardView.center = CGPointMake(newCenterX, cardView.center.y);
            [pan setTranslation:CGPointZero inView:cardView];
            CGFloat XOffPercent = (CGRectGetMaxX(cardView.frame)-0.0)/CGRectGetMaxX(_topViewFrame);
            [self rightAnimationBlowViewWithXOffPercent:-XOffPercent];
        }
    }
    
    // 拖动结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        //从右向左滑
        if ( currentPanPoint.x - _startPanPoint.x <= 0) {
            // 获取顶部视图
            JXYBaseCardView * cardView = [self.cards firstObject];
            // 移除拖动视图逻辑
            // 加速度 小于 1100points/second
            if (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 1100.0) {
                // 移动区域半径大于半个视图
                if ((sqrt(pow(self.cardModels[1].center.x-cardView.center.x,2) + pow(self.cardModels[1].center.y-cardView.center.y,2))) > self.topViewFrame.size.width/3) {
                    [self panGestureToLiftStateEndedWithIsRemove:YES withTime:0.5];
                }//移动距离小 不移除，回到初始位置
                else {

                    [self panGestureToLiftStateEndedWithIsRemove:NO withTime:0.5];
                }
            }else {
                NSTimeInterval time = CGRectGetMaxX(cardView.frame)/velocity.x;
                // 移除，以手势速度飞出
                [self panGestureToLiftStateEndedWithIsRemove:YES withTime:time];
            }
        }//从左向右滑
        else{
            JXYBaseCardView * cardView = [self.cards firstObject];
            if (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 1100.0) {
                // 移动区域半径大于半个视图
                if (CGRectGetMaxX(cardView.frame)-0.0 > self.topViewFrame.size.width/2) {
                    [self panGestureToRightStateEndedWithIsRemove:YES withTime:0.5];
                }else {
                    [self panGestureToRightStateEndedWithIsRemove:NO withTime:0.5];
                }
            }else {
                //以手势速度处理
                NSTimeInterval time = CGRectGetMaxX(cardView.frame)/velocity.x;
                [self panGestureToRightStateEndedWithIsRemove:YES withTime:time];
            }
        }
    }
}

// 视图上的卡片 偏移缩放 从右向左
- (void)rightAnimationBlowViewWithXOffPercent:(CGFloat)XOffPercent
{
    
    for (int i = 1; i <= _showCardsNumber ; i++) {
        JXYBaseCardView * otherView = self.cards[i];
        // 透明度
        otherView.alpha = self.cardModels[i].alpha  + _alphaPercent*XOffPercent;
        // 中心
        CGPoint point = CGPointMake(self.cardModels[i].center.x - self.offsetX*XOffPercent,self.cardModels[i].center.y);
        otherView.center  = point;
        JXYCardModel *model = self.cardModels[i];
        // 缩放大小
        otherView.transform = CGAffineTransformMakeScale(model.currentScale + XOffPercent * _sToBScale,model.currentScale + XOffPercent * _sToBScale);
    }
}
// 视图上的卡片 偏移缩放 从左向右
- (void)leftAnimationBlowViewWithXOffPercent:(CGFloat)XOffPercent
{
    for (int i = 2; i < _realCardNumber ; i++) {
        JXYBaseCardView * otherView = self.cards[i];
        // 透明度
        otherView.alpha = self.cardModels[i].alpha  + _alphaPercent*XOffPercent;
        // 中心
        CGPoint point = CGPointMake(self.cardModels[i].center.x - self.offsetX*XOffPercent,self.cardModels[i].center.y);
        otherView.center  = point;
        JXYCardModel *model = self.cardModels[i];
        // 缩放大小
        otherView.transform = CGAffineTransformMakeScale(model.currentScale + XOffPercent * _sToBScale,model.currentScale + XOffPercent * _sToBScale);
    }
}


#pragma mark  拖动结束 动画+视图
///结束 从左向右
- (void)panGestureToRightStateEndedWithIsRemove:(BOOL)isRemove withTime:(NSTimeInterval)time
{
    if (isRemove == YES) {
        [[self.cards lastObject]removeFromSuperview];
        [self.cards removeLastObject];//把数组中的最后的view先移除
        [self addNewCardToFirst];
    }
    //停用手势
    [self removeGestureRecognizer:self.cardPan];
    //动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:time animations:^{
        for (int i = 0; i < self.cards.count ; i++) {
            JXYCardModel *model = weakSelf.cardModels[i];
            JXYBaseCardView * otherView = weakSelf.cards[i];
            otherView.alpha = model.alpha;
            otherView.center  = model.center;
            otherView.transform = CGAffineTransformMakeScale(model.currentScale,model.currentScale);
        }
    }completion:^(BOOL finished) {
        //启用手势
        [self addGestureRecognizer:self.cardPan];
        //校对位置等
        for (int i = 0; i < self.cards.count ; i++) {
            JXYCardModel *model = weakSelf.cardModels[i];
            JXYBaseCardView * otherView = weakSelf.cards[i];
            otherView.alpha = model.alpha;
            otherView.center  = model.center;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardStackViewCurrentIndex:)]) {
            [self.delegate cardStackViewCurrentIndex:[self.cards objectAtIndex:1].index];
        }
    }];
}

///结束 从右向左
- (void)panGestureToLiftStateEndedWithIsRemove:(BOOL)isRemove withTime:(NSTimeInterval)time
{
    if (isRemove == YES) {
        JXYBaseCardView * hiddenView = [self.cards firstObject];
        [hiddenView removeFromSuperview];
        [self.cards removeObjectAtIndex:0];//把数组中的view先移除
    }
    //停用手势
    [self removeGestureRecognizer:self.cardPan];
    //动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:time animations:^{
        for (int i = 0; i < self.cards.count ; i++) {
            JXYCardModel *model = weakSelf.cardModels[i];
            JXYBaseCardView * otherView = weakSelf.cards[i];
            otherView.alpha = model.alpha;
            otherView.center  = model.center;
            otherView.transform = CGAffineTransformMakeScale(model.currentScale,model.currentScale);
        }
    }completion:^(BOOL finished) {
        //启用手势
        [self addGestureRecognizer:self.cardPan];
        //校对位置等
        for (int i = 0; i < self.cards.count ; i++) {
            JXYCardModel *model = weakSelf.cardModels[i];
            JXYBaseCardView * otherView = weakSelf.cards[i];
            otherView.alpha = model.alpha;
            otherView.center  = model.center;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardStackViewCurrentIndex:)]) {
            [self.delegate cardStackViewCurrentIndex:[self.cards objectAtIndex:1].index];
        }
        //在最后新增一个view
        if (isRemove == YES) {
            [self addNewCardToLast];
        }
    }];
}

#pragma mark - Getter / Setter

@synthesize cards = _cards;
- (NSMutableArray *)cards {
    if (!_cards) {
        _cards = [[NSMutableArray alloc]init];
    }
    return _cards;
}

- (void)setShowCardsNumber:(NSInteger)showCardsNumber {
    _showCardsNumber = (showCardsNumber > 0)?showCardsNumber:4;
    [self cardModels];
}

- (CGFloat)offsetX {
    if (_offsetX == 0.0) {
        return 20.0;
    }
    return _offsetX;
}

/**
 初始化 cardModel的数据
 */
- (NSMutableArray *)cardModels
{
    if (_cardModels == nil || _cardModels.count == 0 || _cardModels.count != self.showCardsNumber ) {
        _cardModels = [[NSMutableArray alloc]init];
        float interval = 1.0/self.showCardsNumber;
        _alphaPercent = interval;
        /*
         尺寸坐标 No.0是隐藏在视图外的 bounds,alpha,currentScale和 No.1一致 N0.2及之后依次减小
         */
        for (int i = 0; i < self.realCardNumber; i++) {
            NSInteger index = i - 1;
            JXYCardModel *cardModel = [[JXYCardModel alloc]init];
            if (i == 0) {
                CGPoint point = CGPointMake(-_topViewFrame.size.width/2, _topViewFrame.origin.y+_topViewFrame.size.height/2);
                cardModel.center = point;
                cardModel.frame = CGRectMake(-_topViewFrame.size.width, _topViewFrame.origin.y, _topViewFrame.size.width, _topViewFrame.size.height);
                cardModel.alpha = 1 ;
                cardModel.currentScale = 1;
            }else{
                CGPoint point = CGPointMake(_topViewFrame.origin.x+_topViewFrame.size.width/2+_offsetX*index, _topViewFrame.origin.y+_topViewFrame.size.height/2+_offsetY*index);
                cardModel.center = point;
                cardModel.frame = _topViewFrame;
                cardModel.alpha = 1 - interval*index;
                cardModel.currentScale = 1 - _bToSScale*index;
            }
            [_cardModels addObject:cardModel];
        }
    }
    return _cardModels;
}

- (UIPanGestureRecognizer *)cardPan {
    if (!_cardPan) {
        _cardPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
        _cardPan.delegate = self;
    }
    return _cardPan;
}

#pragma mark - 手势冲突
// 是否允许触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
    if(fabs(translation.y) > fabs(translation.x)){
        return NO;//竖向滑动不处理
    }else{
        return YES;
    }
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
        UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
        if (scrollView.contentOffset.y == 0 ) {
            return NO;//防止横向滑动
        }
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
        if(fabs(translation.x) > fabs(translation.y)){
            return NO;//防止竖向同时滑动
        }else{
            return YES;
        }
    }else {
        return YES;
    }
}


@end
