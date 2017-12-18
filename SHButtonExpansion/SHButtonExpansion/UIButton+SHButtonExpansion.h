//
//  UIButton+SHButtonExpansion.h
//  SHButtonExpansion
//
//  Created by angle on 2017/12/18.
//  Copyright © 2017年 angle. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark -
#pragma mark   ==============防暴力点击+增加延迟处理==============
@interface UIButton (SHButtonExpansion)

/**
 设置点击时间间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/**
 用于设置单个按钮不需要被hook
 */
@property (nonatomic, assign) BOOL isIgnore;

@end

#pragma mark -
#pragma mark   ==============扩大按钮点击区域==============
@interface UIButton (Expansion)

/**
 上下左右均扩大范围
 */
@property (nonatomic, assign) CGFloat enlargeEdge;
/**
 设置扩充边界
 */
- (void)setEnlargeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

@end

#pragma mark -
#pragma mark   ==============根据状态设置背景色==============

@interface UIButton (BackGColor)

@property(nonatomic,readonly,strong) UIColor *currentBorderColor;

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void)setborderColor:(UIColor *)borderColor forState:(UIControlState)state;

- (UIColor *)borderColorForState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

- (void)configBorderColors:(NSDictionary *)borderColors;
- (void)configBackgroundColors:(NSDictionary *)backgroundColors;

@end


#pragma mark -
#pragma mark   ==============视频、音频播放手势处理==============
@protocol SHVideoTapButtonDelegate <NSObject>

/**
 * 开始触摸
 */
- (void)touchesBeganWithPoint:(CGPoint)point;

/**
 * 结束触摸
 */
- (void)touchesEndWithPoint:(CGPoint)point;

/**
 * 移动手指
 */
- (void)touchesMoveWithPoint:(CGPoint)point;
/**
 * 取消
 */
@optional
- (void)touchesCancelledWithPoint:(CGPoint)point;

@end

@interface SHVideoTapButton : UIButton

/**
 * 传递点击事件的代理
 */
@property (weak, nonatomic) id <SHVideoTapButtonDelegate> touchDelegate;

@end

