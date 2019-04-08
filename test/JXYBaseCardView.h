//
//  SouFunBaseCardView.h
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//基类
@interface JXYBaseCardView : UIView
@property (nonatomic,assign) NSInteger index; //当前视图相对于dataSource的位置

@end


@interface JXYCardModel : NSObject
@property (nonatomic) CGRect  frame;       ///标准大小 非实际大小
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) CGFloat currentScale;///缩放比例
@end
NS_ASSUME_NONNULL_END
