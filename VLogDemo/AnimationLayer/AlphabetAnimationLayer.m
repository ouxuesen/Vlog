//
//  AlphabetAnimationLayer.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/12.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "AlphabetAnimationLayer.h"


#define AnimationView_w    CGRectGetWidth(self.view.bounds)
#define AnimationView_h    CGRectGetHeight(self.view.bounds)

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationType_Down = 0,
    AnimationType_pointBreath,
    AnimationType_pointJump,
    AnimationType_pointMove,
};
@interface AlphabetAnimationLayer ()<CAAnimationDelegate>

/** pointLayer */
@property (nonatomic,strong) CALayer *pointLayer;
@property (nonatomic,assign) AnimationType animationType;
@end

@implementation AlphabetAnimationLayer

- (void)layoutSublayers {
    [super layoutSublayers];
//    self.pointLayer.frame = CGRectMake(screen_w/2 - point_w/2, screen_h/2 - point_w/2, point_w, point_w);
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}
- (void)setupAlphaberAnimationLayer {
    self.pointLayer.backgroundColor = [UIColor yellowColor].CGColor;
    self.pointLayer.cornerRadius = point_w/2;
    self.pointLayer.masksToBounds = YES;
    [self addSublayer:self.pointLayer];
}

- (void)alphabetAnimation_pointDownWithOffset_x:(CGFloat)Offset_x {
     self.pointLayer.frame = CGRectMake(Offset_x, 0, point_w, point_w);
     [self.pointLayer removeAllAnimations];
    self.animationType = AnimationType_Down;
    CABasicAnimation *pointDown = [self pointDown:self.pointLayer.position moveTo:CGPointMake(self.pointLayer.position.x, self.pointLayer.position.y + 50)];
    CABasicAnimation *pointDownAutoreverses = [self pointDownReverse:CGPointMake(self.pointLayer.position.x, self.pointLayer.position.y + 50) moveToPoint:CGPointMake(self.pointLayer.position.x, self.pointLayer.position.y + 35)];
    CABasicAnimation *pointDown_opacity = [self pointOpacity:1.0 toValue:0.f isAutoreverse:NO];
      pointDown_opacity.delegate = self;
    pointDown_opacity.beginTime = CACurrentMediaTime() + 1.2f;
    [self.pointLayer addAnimation:pointDown forKey:@"pointDown"];
    [self.pointLayer addAnimation:pointDownAutoreverses forKey:@"autoreverses"];
    [self.pointLayer addAnimation:pointDown_opacity forKey:@"opacity"];
  //时间 1.2+0.1
}

- (void)alphabetAnimation_pointBreathWithOffset_x:(CGFloat)Offset_x {
    self.pointLayer.frame = CGRectMake(Offset_x,self.bounds.size.height-point_w, point_w, point_w);
    [self.pointLayer removeAllAnimations];
    self.animationType = AnimationType_pointBreath;
    CABasicAnimation *pointDown_Scale = [self pointBreath:1.0 toValue:1.2f];
    CABasicAnimation *pointDown_opacity = [self pointOpacity:1.0 toValue:.5f isAutoreverse:YES];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[pointDown_opacity,pointDown_Scale];
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.duration = .2f;
    animationGroup.repeatCount = 3;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animationGroup.delegate = self;
    [self.pointLayer addAnimation:animationGroup forKey:@"scale"];
    //0.6s
}

- (void)alphabetAnimation_pointJumpWithOffset_x:(CGFloat)Offset_x{
    self.pointLayer.frame = CGRectMake(Offset_x, 0, point_w, point_w);
    
     [self.pointLayer removeAllAnimations];
     self.animationType = AnimationType_pointJump;
    CGFloat reboundHeight = point_w/2;
    CABasicAnimation *jump_down = [self pointJump:self.pointLayer.position toValue:CGPointMake(self.position.x, self.bounds.size.height+reboundHeight)];
    CABasicAnimation *jump_up = [self pointJump:CGPointMake(self.pointLayer.position.x, self.bounds.size.height+reboundHeight) toValue:CGPointMake(self.pointLayer.position.x, self.bounds.size.height-point_w)];
    CABasicAnimation *jump_opacity = [self pointOpacity:1.0 toValue:0 isAutoreverse:NO];
    
    jump_up.beginTime = CACurrentMediaTime() + .3f;
    jump_opacity.beginTime = CACurrentMediaTime() + .7f;
    jump_opacity.delegate = self;
    [self.pointLayer addAnimation:jump_down forKey:@"jump_down"];
    [self.pointLayer addAnimation:jump_up forKey:@"jump_up"];
    [self.pointLayer addAnimation:jump_opacity forKey:@"jump_opacity"];
    //time  = 1.0s
}

- (void)alphabetAnimation_pointMove:(CGPoint)startPoint moveTo:(CGPoint)endPoint moveRadius:(CGFloat)radius{
    self.pointLayer.frame = CGRectMake(0, 0, point_w, point_w);
     [self.pointLayer removeAllAnimations];
     self.animationType = AnimationType_pointMove;
    CAKeyframeAnimation *point_Move = [self pointMove:self.pointLayer.position toValue:endPoint moveRadius:radius];
    point_Move.delegate = self;
    [self.pointLayer addAnimation:point_Move forKey:@"move"];
    //time = 3.0;
}

//kCAMediaTimingFunctionLinear    快速开始然后匀速。
//kCAMediaTimingFunctionEaseIn   慢慢加速后突然停止。
//kCAMediaTimingFunctionEaseOut   全速开始后慢慢停止。
//kCAMediaTimingFunctionEaseInEaseOut  慢慢开始然后慢慢减速。

#pragma mark - Animation Methods
/// pointDown
- (CABasicAnimation *)pointDown:(CGPoint)originalPoint moveTo:(CGPoint)endPoint {
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    keyAnimation.duration = .5f;
    keyAnimation.fromValue = @(originalPoint.y);
    keyAnimation.toValue = @(endPoint.y);
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    return keyAnimation;
}

- (CABasicAnimation *)pointDownReverse:(CGPoint)originalPoint moveToPoint:(CGPoint)endPoint {
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    keyAnimation.beginTime = CACurrentMediaTime() + .5f;
    keyAnimation.duration = .15f;
    keyAnimation.fromValue = @(originalPoint.y);
    keyAnimation.toValue = @(endPoint.y);
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    keyAnimation.autoreverses = YES;
    keyAnimation.repeatCount = 3;
    return keyAnimation;
}

/// pointBreath
- (CABasicAnimation *)pointBreath:(CGFloat)original toValue:(CGFloat)end {
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    keyAnimation.duration = .1f;
    keyAnimation.fromValue = @(original);
    keyAnimation.toValue = @(end);
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyAnimation.autoreverses = YES;
    keyAnimation.repeatCount = 3;
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    return keyAnimation;
}

/// pointJump
- (CABasicAnimation *)pointJump:(CGPoint)originalPoint toValue:(CGPoint)endPoint {
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    keyAnimation.fromValue = @(originalPoint.y);
    keyAnimation.toValue = @(endPoint.y);
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyAnimation.duration = .5f;
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    return keyAnimation;
}

/// pointMove
- (UIBezierPath *)getPointPath:(CGPoint)startPoint endPoint:(CGPoint)endPoint moveRadius:(CGFloat)radius {
    
    UIBezierPath *path0 = [UIBezierPath bezierPath];
    [path0 moveToPoint:startPoint];
    [path0 addLineToPoint:CGPointMake(startPoint.x, endPoint.y - radius)];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(startPoint.x, endPoint.y - radius)];
    [bezierPath addArcWithCenter:CGPointMake(startPoint.x, endPoint.y) radius:radius startAngle:M_PI * 1.5 endAngle:0 clockwise:NO];
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(startPoint.x + radius, endPoint.y)];
    [path1 addLineToPoint:endPoint];
    
    [path0 appendPath:bezierPath];
    [path0 appendPath:path1];
    
    return path0;
}

- (CAKeyframeAnimation *)pointMove:(CGPoint)startPoint toValue:(CGPoint)endPoint moveRadius:(CGFloat)radius{
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyAnimation.duration = 3;
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    keyAnimation.path = [self getPointPath:startPoint endPoint:endPoint moveRadius:radius].CGPath;
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return keyAnimation;
}

/// pointDiss
- (CABasicAnimation *)pointOpacity:(CGFloat)original toValue:(CGFloat)end isAutoreverse:(BOOL)isAuto{
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    keyAnimation.duration = .1f;
    keyAnimation.fromValue = @(original);
    keyAnimation.toValue = @(end);
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    keyAnimation.autoreverses = isAuto;
    keyAnimation.repeatCount = isAuto ? 3 : 1;
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    return keyAnimation;
}

#pragma mark - LAZY
- (CALayer *)pointLayer {
    if (!_pointLayer) {
        _pointLayer = [CALayer layer];
        _pointLayer.speed = 0;
    }
    return _pointLayer;
}

-(CGFloat)animationDuration
{
//    return self.pointLayer.duration;
//    CFTimeInterval duration = 0.0;
//    for (CAAnimation*animation in [self currentAnimation]) {
//        if (duration<animation.duration*animation.repeatCount) {
//            duration = animation.duration*animation.repeatCount;
//        }
//    }
//    return 5;
    CGFloat duration = 0.0;
    switch (self.animationType) {
        case AnimationType_Down:
            duration = 1.3;
            break;
        case AnimationType_pointBreath:
             duration = 0.6;
            break;
        case AnimationType_pointJump:
            duration = 1;
            break;
        case AnimationType_pointMove:
            duration = 3.5;
            break;
        default:
            break;
    }
    return duration;
}
-(void)setAnimationProgress:(CGFloat)animationProgress
{
     self.pointLayer.timeOffset = animationProgress*[self animationDuration];
  NSLog(@"232 = %lf",self.pointLayer.timeOffset) ;
}
-(NSArray<CAAnimation*>*)currentAnimation
{
    NSMutableArray*mutableArray = [NSMutableArray new];
    for (NSString*animationKey in self.pointLayer.animationKeys) {
        CAAnimation*animation = [self.pointLayer animationForKey:animationKey];
        [mutableArray addObject:animation];
    }
    return mutableArray;
}
- (void)animationDidStart:(CAAnimation *)anim
{
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{

}
@end
