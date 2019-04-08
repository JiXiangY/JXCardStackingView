//
//  CardView.m
//
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import "TestADCardView.h"

@implementation TestADCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        {
            UIImageView *img = [[UIImageView alloc]init];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.backgroundColor = [UIColor purpleColor];
            _cardImg = img;

            [self addSubview:img];
        }
        
        {
            UIButton *btn = [[UIButton alloc]init];
            [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundColor:[UIColor clearColor]];
            
            _cardBtn = btn;
            [self addSubview:btn];
            
            UILabel *label = [[UILabel alloc]initWithFrame:btn.frame];
            label.font = [UIFont boldSystemFontOfSize:40];
            label.textAlignment = NSTextAlignmentCenter;
            self.label = label;
            [self addSubview:label];
            
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _cardImg.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _cardBtn.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _label.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)updateViewWithData:(NSString *)imageUrl {
    [_cardImg setImage:[UIImage imageNamed:imageUrl]];
}

- (void)action {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

@end
