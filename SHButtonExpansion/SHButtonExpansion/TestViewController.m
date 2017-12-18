//
//  TestViewController.m
//  SHButtonExpansion
//
//  Created by angle on 2017/12/18.
//  Copyright © 2017年 angle. All rights reserved.
//

#import "TestViewController.h"

#import "UIButton+SHButtonExpansion.h"

#define kWidth ([UIScreen mainScreen].bounds.size.width)
#define kHeight ([UIScreen mainScreen].bounds.size.height)


@interface TestViewController ()<SHVideoTapButtonDelegate>

@property (nonatomic, strong) UILabel *label;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(16, 150, kWidth - 32, 50)];
    _label.textColor = [UIColor orangeColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"显示点击";
    [self.view addSubview:_label];
    
    
    [self switchType];
}
#pragma mark -
#pragma mark   ==============type==============
- (void)switchType {
    switch (self.type) {
        case 0:
            [self testOne];
            break;
        case 1:
            [self testTwo];
            break;
        case 2:
            [self testThree];
            break;
        case 3:
            [self testFour];
            break;
        default:
            break;
    }
    
}
#pragma mark -
#pragma mark   ==============防暴力点击==============
- (void)testOne {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth * 0.5 - 75, 300, 150, 50)];
    btn.timeInterval = 5.f;
    
    [btn setTitle:@"防止暴力点击" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(oneClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
}
- (void)oneClick:(UIButton *)btn {
    btn.tag ++;
    self.label.text = [NSString stringWithFormat:@"被点击了---%ld",btn.tag];
    btn.selected = !btn.selected;
}
#pragma mark -
#pragma mark   ==============扩大点击区域==============
- (void)testTwo {
    CALayer *area = [[CALayer alloc] init];
    area.frame = CGRectMake(kWidth * 0.5 - 175, 200, 350, 250);
    area.backgroundColor = [UIColor cyanColor].CGColor;
    [self.view.layer addSublayer:area];
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth * 0.5 - 75, 300, 150, 50)];
    btn.enlargeEdge = 100;
    
    [btn setTitle:@"扩大点击区域" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(oneClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
}
#pragma mark -
#pragma mark   ==============状态更改背景色==============
- (void)testThree {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kWidth * 0.5 - 75, 300, 150, 50)];
    [btn setTitle:@"状态更改背景色" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(oneClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}
#pragma mark -
#pragma mark   ==============播放手势处理==============
- (void)testFour {
    
    SHVideoTapButton *btn = [[SHVideoTapButton alloc] initWithFrame:CGRectMake(0, 300, kWidth, kWidth * 9 / 16)];
    btn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    btn.touchDelegate = self;
    [self.view addSubview:btn];
    
}

/**
 * 开始触摸
 */
- (void)touchesBeganWithPoint:(CGPoint)point {
    self.label.text = [NSString stringWithFormat:@"开始触摸---%@",NSStringFromCGPoint(point)];
}

/**
 * 结束触摸
 */
- (void)touchesEndWithPoint:(CGPoint)point {
    self.label.text = [NSString stringWithFormat:@"结束触摸---%@",NSStringFromCGPoint(point)];
}

/**
 * 移动手指
 */
- (void)touchesMoveWithPoint:(CGPoint)point {
    self.label.text = [NSString stringWithFormat:@"移动手指---%@",NSStringFromCGPoint(point)];
}
/**
 * 取消
 */
- (void)touchesCancelledWithPoint:(CGPoint)point {
    NSLog(@"打电话主动取消");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
