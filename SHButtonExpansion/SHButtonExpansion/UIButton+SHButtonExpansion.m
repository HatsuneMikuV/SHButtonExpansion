//
//  UIButton+SHButtonExpansion.m
//  SHButtonExpansion
//
//  Created by angle on 2017/12/18.
//  Copyright © 2017年 angle. All rights reserved.
//

#import "UIButton+SHButtonExpansion.h"

#import <objc/runtime.h>

#pragma mark -
#pragma mark   ============================

#define defaultInterval (.5)  //默认时间间隔

@interface UIButton()
/**
 bool 类型 YES 不允许点击   NO 允许点击   设置是否执行点UI方法
 */
@property (nonatomic, assign) BOOL isIgnoreEvent;


/**
 背景色处理
 */
@property (nonatomic, strong) NSMutableDictionary *borderColors;
@property (nonatomic, strong) NSMutableDictionary *backgroundColors;

@end

@implementation UIButton (SHButtonExpansion)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(sendAction:to:forEvent:);
        SEL selB = @selector(mySendAction:to:forEvent:);
        Method methodA =   class_getInstanceMethod(self,selA);
        Method methodB = class_getInstanceMethod(self, selB);
        //将 methodB的实现 添加到系统方法中 也就是说 将 methodA方法指针添加成 方法methodB的  返回值表示是否添加成功
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        //添加成功了 说明 本类中不存在methodB 所以此时必须将方法b的实现指针换成方法A的，否则 b方法将没有实现。
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            //添加失败了 说明本类中 有methodB的实现，此时只需要将 methodA和methodB的IMP互换一下即可。
            method_exchangeImplementations(methodA, methodB);
        }
    });
}
- (NSTimeInterval)timeInterval{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
- (void)setTimeInterval:(NSTimeInterval)timeInterval{
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
//当我们按钮点击事件 sendAction 时  将会执行  mySendAction
- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    if (self.isIgnore) {
        //不需要被hook
        [self mySendAction:action to:target forEvent:event];
        return;
    }
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
        self.timeInterval =self.timeInterval == 0 ?defaultInterval:self.timeInterval;
        if (self.isIgnoreEvent){
            return;
        }else if (self.timeInterval > 0){
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
    }
    //此处 methodA和methodB方法IMP互换了，实际上执行 sendAction；所以不会死循环
    self.isIgnoreEvent = YES;
    [self mySendAction:action to:target forEvent:event];
}
//runtime 动态绑定 属性
- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent{
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isIgnoreEvent{
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setIsIgnore:(BOOL)isIgnore{
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnore), @(isIgnore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isIgnore{
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)resetState{
    [self setIsIgnoreEvent:NO];
}

@end

#pragma mark -
#pragma mark   ============================

@implementation UIButton (Expansion)

static char topEdgeKey;
static char leftEdgeKey;
static char bottomEdgeKey;
static char rightEdgeKey;
/**
 合成寻去方法
 */
- (void)setEnlargeEdge:(CGFloat)enlargeEdge{
    [self setEnlargeWithTop:enlargeEdge left:enlargeEdge bottom:enlargeEdge right:enlargeEdge];
}

- (CGFloat)enlargeEdge{
    return [(NSNumber *)objc_getAssociatedObject(self, &topEdgeKey) floatValue];
}
/**
 设置扩充边界
 */
- (void)setEnlargeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right{
    objc_setAssociatedObject(self, &topEdgeKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftEdgeKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomEdgeKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightEdgeKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
/**
 获得当前的响应rect

 @return return value description
 */
- (CGRect)enlargedRect{
    NSNumber *topEdge = objc_getAssociatedObject(self, &topEdgeKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &leftEdgeKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &rightEdgeKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomEdgeKey);
    if (topEdge && leftEdge && rightEdge && bottomEdge) {
        CGRect enlargedRect = CGRectMake(self.bounds.origin.x - leftEdge.floatValue, self.bounds.origin.y - topEdge.floatValue, self.frame.size.width + leftEdge.floatValue + rightEdge.floatValue, self.frame.size.height + topEdge.floatValue + bottomEdge.floatValue);
        return enlargedRect;
    }else{
        return self.bounds;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.alpha <= 0.01 || !self.userInteractionEnabled || self.hidden) {
        return nil;
    }
    CGRect enlargeRect = [self enlargedRect];
    
    if (CGRectEqualToRect(enlargeRect, self.bounds)) {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(enlargeRect, point) ? self : nil;
}

@end

#pragma mark -
#pragma mark   ============================

@implementation SHVideoTapButton

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesBeganWithPoint:currentP];
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesEndWithPoint:currentP];
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesMoveWithPoint:currentP];
}

//取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesCancelledWithPoint:currentP];
}

@end

#pragma mark -
#pragma mark   ============================
@implementation UIButton (BackGColor)

+ (void)load {
    //交换 setHighlighted:, setEnabled: 和 setSelected: 方法
    Class aClass = [self class];
    method_exchangeImplementations(class_getInstanceMethod(aClass, @selector(setHighlighted:)),
                                   class_getInstanceMethod(aClass, @selector(sl_setHighlighted:))
                                   );
    method_exchangeImplementations(class_getInstanceMethod(aClass, @selector(setEnabled:)),
                                   class_getInstanceMethod(aClass, @selector(sl_setEnabled:))
                                   );
    method_exchangeImplementations(class_getInstanceMethod(aClass, @selector(setSelected:)),
                                   class_getInstanceMethod(aClass, @selector(sl_setSelected:))
                                   );
}

#pragma mark - public method

- (void)setborderColor:(UIColor *)borderColor forState:(UIControlState)state {
    if (borderColor) {
        [self.borderColors setObject:borderColor forKey:@(state)];
        
        if (self.layer.borderWidth == 0) {
            self.layer.borderWidth = 1.0;
        }
    }
    if(self.state == state) {
        self.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (backgroundColor) {
        [self.backgroundColors setObject:backgroundColor forKey:@(state)];
    }
    if(self.state == state) {
        self.backgroundColor = backgroundColor;
    }
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [self.borderColors objectForKey:@(state)];
}

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [self.backgroundColors objectForKey:@(state)];
}

- (void)configBorderColors:(NSDictionary *)borderColors {
    self.borderColors = [borderColors mutableCopy];
    [self _update];
}

- (void)configBackgroundColors:(NSDictionary *)backgroundColors {
    self.backgroundColors = [backgroundColors mutableCopy];
    [self _update];
}

#pragma mark - override

- (void)sl_setSelected:(BOOL)selected {
    [self sl_setSelected:selected];
    
    [self _update];
}

- (void)sl_setEnabled:(BOOL)enabled {
    [self sl_setEnabled:enabled];
    
    [self _update];
}

- (void)sl_setHighlighted:(BOOL)highlighted {
    [self sl_setHighlighted:highlighted];
    
    [self _update];
}

#pragma mark - private method

- (void)_update {
    UIColor *backgroundColor = [self backgroundColorForState:self.state];
    UIColor *borderColor = [self borderColorForState:self.state];
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    } else {
        UIColor *normalColor = [self backgroundColorForState:UIControlStateNormal];
        if (normalColor) {
            self.backgroundColor = normalColor;
        }
    }
    
    if (borderColor) {
        self.layer.borderColor = borderColor.CGColor;
    } else {
        UIColor *normalColor = [self borderColorForState:UIControlStateNormal];
        if (normalColor) {
            self.layer.borderColor = normalColor.CGColor;
        }
    }
}

#pragma mark - setter and getter

//currentBorderColor
- (UIColor *)currentBorderColor {
    return [self borderColorForState:self.state];
}

//borderColors
- (void)setBorderColors:(NSMutableDictionary *)borderColors {
    objc_setAssociatedObject(self, @selector(borderColors), borderColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)borderColors {
    NSMutableDictionary *_borderColors = objc_getAssociatedObject(self, @selector(borderColors));
    
    if (!_borderColors) {
        _borderColors = [NSMutableDictionary new];
        self.borderColors = _borderColors;
    }
    return _borderColors;
}

//backgroundColors
- (void)setBackgroundColors:(NSMutableDictionary *)backgroundColors {
    objc_setAssociatedObject(self, @selector(backgroundColors), backgroundColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)backgroundColors {
    NSMutableDictionary *_backgroundColors = objc_getAssociatedObject(self, @selector(backgroundColors));
    if(!_backgroundColors) {
        _backgroundColors = [[NSMutableDictionary alloc] init];
        self.backgroundColors = _backgroundColors;
    }
    return _backgroundColors;
}


@end
