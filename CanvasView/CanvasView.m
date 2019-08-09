//
//  CanvasView.m
//  Created by sluin on 15/7/1.
//  Copyright (c) 2015年 SunLin. All rights reserved.
//

#import "CanvasView.h"
#import <Lottie/Lottie.h>
#import "AlphabetAnimationLayer.h"
#import "TEstViewAnimation.h"

@interface CanvasView ()

@property (strong, nonatomic) LOTAnimationView *animationView;
@property (nonatomic,strong) AlphabetAnimationLayer *animationLayer;
@property (nonatomic, assign) BOOL first;
@end

@implementation CanvasView{
//    CGContextRef context ;
    CGFloat time;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationView = [LOTAnimationView animationNamed:@"clap"];
        self.animationView.loopAnimation = YES;
        self.animationView.frame = frame;
        [self addSubview:self.animationView];
        
//         self.animationLayer.frame = CGRectMake(0, 0, frame.size.width, 80);
//             [self.animationLayer setupAlphaberAnimationLayer];
//        UIView *contentView= [[UIView alloc]initWithFrame:CGRectMake(0, 300, frame.size.width, 80)];
//        [contentView.layer addSublayer:self.animationLayer];
//
//        [self addSubview:contentView];
       
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.animationView = [LOTAnimationView animationNamed:@"clap"];
        self.animationView.loopAnimation = YES;
        [self addSubview:self.animationView];
        [self.animationLayer setupAlphaberAnimationLayer];
        [self.layer addSublayer:self.animationLayer];
//        _animationLayer.frame = CGRectMake(0, 300, frame.size.width, 80);
    }
    return self;
}

-(void)setEverframe
{
    if (time>0.0&&time <[self.animationLayer animationDuration]) {
        time = time+1.0/24;
        [self.animationLayer setAnimationProgress:time/[self.animationLayer animationDuration]];
        [self.animationLayer  layoutIfNeeded];
    }else{
        time = 0.01;
        NSLog(@"end animation");
    }
}

-(void)setCurrentProgress:(CGFloat)currentProgress
{
    if (!_first) {
       [self.animationLayer alphabetAnimation_pointMove:CGPointMake(0, 0) moveTo:CGPointMake(self.animationLayer.bounds.size.width, self.animationLayer.bounds.size.height-point_w/2) moveRadius:10];
        _first= YES;
    }

    self.animationView.animationProgress = currentProgress;
}
-(CGFloat)animationDuration
{
    return self.animationView.animationDuration;
}
- (AlphabetAnimationLayer *)animationLayer {
    if (!_animationLayer) {
        _animationLayer = [[AlphabetAnimationLayer alloc] init];
        
        _animationLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    return _animationLayer;
}
//- (void)layoutSubviews
//{
//     [self.animationLayer alphabetAnimation_pointBreathWithOffset_x:100];
//}

#pragma ---mark

@end
