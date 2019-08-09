//
//  TEstViewAnimation.m
//  VLogDemo
//
//  Created by ou xuesen on 2019/6/24.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "TEstViewAnimation.h"

@interface TEstViewAnimation ()
@property(strong, nonatomic) UIImageView *plane;
@property (nonatomic,strong) CABasicAnimation* opAnim;
@end
@implementation TEstViewAnimation

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    if (self) {
        CGRect imageFrame = CGRectMake(0, 0, frame.size.width, frame.size.height); //创建Image View对象plane
        self.plane = [[UIImageView alloc] initWithFrame:imageFrame];
        //设置plane的图片属性
        self.plane.image = [UIImage imageNamed:@"img_2.png"]; //设置plane视图上的层opacity属性
        self.plane.layer.opacity = 0.25;
        //添加plane到当前视图
        [self addSubview:self.plane];
        [self movePlane];
    }
    return self;
}

- (void)movePlane {
    //创建opacity动画
    CABasicAnimation *opAnim = [CABasicAnimation animationWithKeyPath:@"opacity"]; //设置动画持续时间
    opAnim.duration = 3.0;
    //设置opacity开始值
    opAnim.fromValue = @0.25;
    //数值为0.25的NSNumber对象
    //设置opacity结束值
    opAnim.toValue= @1.0;
    //数值为1.0的SNumber对象
    //设置累计上次值
    opAnim.cumulative = YES;
    //设置动画重复2次
    opAnim.repeatCount = 10;
    //设置动画结束时候处理方式
    opAnim.fillMode = kCAFillModeForwards;
    //设置动画结束时是否停止
    opAnim.removedOnCompletion = NO;
    //添加动画到层
    [self.plane.layer addAnimation:opAnim forKey:@"animateOpacity"];
    //创建平移仿射变换
    CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(200, 300); //创建平移动画
    CABasicAnimation *moveAnim = [CABasicAnimation animationWithKeyPath:@"transform"]; moveAnim.duration = 6.0;
    //设置结束位置
    moveAnim.toValue= [NSValue valueWithCATransform3D: CATransform3DMakeAffineTransform(moveTransform)];
    moveAnim.fillMode = kCAFillModeForwards;
    moveAnim.removedOnCompletion = NO;
    moveAnim.repeatCount = 10;
    [self.plane.layer addAnimation:moveAnim forKey:@"animateTransform"];
    self.plane.layer.speed = 0;
    self.opAnim = opAnim;
}
-(void)setAnimationProgress:(CGFloat)animationProgress
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.plane.layer.timeOffset = animationProgress;
    self.opAnim.fromValue = @(animationProgress);
    [self setNeedsDisplay];
    [CATransaction commit];
    
//    self.plane.layer.timeOffset = animationProgress;
}
@end
