//
//  CardView.h
//  
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TestADCardView.h"
#import "JXYBaseCardView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CardViewBlock)(void);

@interface TestADCardView : JXYBaseCardView

@property (nonatomic,strong) UIImageView * cardImg;
@property (nonatomic,strong) UIButton * cardBtn;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic) CardViewBlock clickBlock;

- (void)updateViewWithData:(NSString *)imageUrl;

@end

NS_ASSUME_NONNULL_END
