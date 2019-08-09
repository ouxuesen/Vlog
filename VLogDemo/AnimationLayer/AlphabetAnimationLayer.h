//
//  AlphabetAnimationLayer.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/12.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static CGFloat point_w = 30.f;
@interface AlphabetAnimationLayer : CALayer

@property (nonatomic, assign) CGFloat animationProgress;
/// Read only of the duration in seconds of the animation at speed of 1
@property (nonatomic, readonly) CGFloat animationDuration;

/// setupLayer
- (void)setupAlphaberAnimationLayer;

/// 圆点落下
- (void)alphabetAnimation_pointDownWithOffset_x:(CGFloat)Offset_x ;
/// 圆点呼吸动画
- (void)alphabetAnimation_pointBreathWithOffset_x:(CGFloat)Offset_x;
/// 圆点跳动 jumpDistance --> 跳动距离 height --> 反弹高度
- (void)alphabetAnimation_pointJumpWithOffset_x:(CGFloat)Offset_x;
/// 圆点移动
- (void)alphabetAnimation_pointMove:(CGPoint)startPoint moveTo:(CGPoint)endPoint moveRadius:(CGFloat)radius;


@end

NS_ASSUME_NONNULL_END
