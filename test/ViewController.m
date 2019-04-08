//
//  ViewController.m
//  
//
//  Created by 于吉祥 on 2019/2/15.
//  Copyright © 2019 soufun. All rights reserved.
//

#import "ViewController.h"

#import "JXYCardStackView.h"
#import "TestADCardView.h"

#import "TABDefine.h"

@interface ViewController ()<JXYCardStackViewDelegate,JXYCardStackViewDataSource>

@property (nonatomic,strong) JXYCardStackView * cardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 30, 30 )];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.center = CGPointMake(100, 500);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //横向
    [self horizontalView];
    
}

- (void)horizontalView{
    self.cardView = [[JXYCardStackView alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 220)];
    self.cardView.backgroundColor = [UIColor grayColor];
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
    self.cardView.offsetX = 16;
    self.cardView.topViewFrame = CGRectMake(20, 20, kScreenWidth-40-16, 180);
    [self.view addSubview:self.cardView];
    // 模拟请求数据
    [self performSelector:@selector(getData) withObject:nil afterDelay:3.0];
}

#pragma mark - Target Method

- (void)getData {
    [self.cardView loadCardViewWithDataCount:2 showCardsNumber:3];
}
#pragma mark - SouFunCardStackViewDataSource
- (JXYBaseCardView *)loadCardViewWithIndex:(NSInteger)index
{
    TestADCardView *view = [[TestADCardView alloc] init];
    view.label.text = [NSString stringWithFormat:@"%ld",index];
    [view updateViewWithData:[NSString stringWithFormat:@"im_messageList_noData_icon"]];
    view.clickBlock = ^{
        NSLog(@"点击了卡片");
    };
    return view;
}
#pragma mark - SouFunCardStackViewDelegate

- (void)cardStackViewCurrentIndex:(NSInteger)index {
    NSLog(@"当前处于卡片数组下标:%ld",(long)index);
}

@end
