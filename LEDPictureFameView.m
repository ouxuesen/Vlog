//
//  LEDPictureFameView.m
//  VLogDemo
//
//  Created by ou xuesen on 2019/6/26.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "LEDPictureFameView.h"
#import "UIView+AutoLayout.h"

@interface LEDPictureFameView ()
@property (nonatomic,assign) NSInteger frameRate;

@property (nonatomic,strong) UIImageView* wordImageView;//单词图片
@property (nonatomic,strong) UIImageView* mainImageView;//密封动画
@property (nonatomic, nonatomic) NSArray* mainImages;
@property (nonatomic, assign) NSInteger mainIndex;
@property (nonatomic,strong) UIImageView* letterAnimationView;//落下动画
@property (nonatomic, nonatomic) NSArray* letterImages;
@property (nonatomic, assign) NSInteger letterIndex;
@property (nonatomic,strong) UIImageView* titileAnimationView;//title 动画
@property (nonatomic, nonatomic) NSArray* titileImages;
@property (nonatomic, assign) NSInteger titileIndex;
@property (nonatomic,strong) UIImageView* wordAnimationView;//
@property (nonatomic, nonatomic)NSArray* wordImages;
@property (nonatomic, assign) NSInteger wordIndex;
@end

@implementation LEDPictureFameView

- (instancetype)init
{
    self = [super init];
    if (self) {
       
        [self loadView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

-(void)loadView
{
     self.frameRate = 15;
    [self addSubview:self.mainImageView];
    [self ledAuto:self.mainImageView WithInsets:UIEdgeInsetsZero];
    [self addSubview:self.titileAnimationView];
    [self ledAuto:self.titileAnimationView WithInsets:UIEdgeInsetsZero];
    [self addSubview:self.letterAnimationView];
    [self ledAuto:self.letterAnimationView WithInsets:UIEdgeInsetsZero];
    [self addSubview:self.wordAnimationView];
    [self ledAuto:self.wordAnimationView WithInsets:UIEdgeInsetsZero];
    [self addSubview:self.wordImageView];
    [self ledAuto:self.wordImageView WithInsets:UIEdgeInsetsZero];
}
-(void)ledAuto:(UIView*)subview WithInsets:(UIEdgeInsets)insets
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [subview autoPinEdgesToSuperviewEdgesWithInsets:insets];
}
-(UIImageView *)wordImageView
{
    if (!_wordImageView) {
        _wordImageView = [[UIImageView alloc] init];
    }
    return _wordImageView;
}
-(UIImageView *)mainImageView
{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] init];
    }
    return _mainImageView;
}
-(UIImageView *)letterAnimationView
{
    if (!_letterAnimationView) {
        _letterAnimationView = [[UIImageView alloc] init];
    }
    return _letterAnimationView;
}
-(UIImageView *)titileAnimationView
{
    if (!_titileAnimationView) {
        _titileAnimationView = [[UIImageView alloc] init];
    }
    return _titileAnimationView;
}
-(UIImageView *)wordAnimationView
{
    if (!_wordAnimationView) {
        _wordAnimationView = [[UIImageView alloc] init];
    }
    return _wordAnimationView;
}

-(void)startMianAnimation
{
    self.mainImages = [self getMainImages];
}
-(CGFloat)startLetterAnimationView
{
    self.letterImages = [self getLetterImages];
    return self.letterImages.count*1.0/self.frameRate;
}
-(CGFloat)startTitileAnimationView
{
    self.titileImages = [self getTitleImages];
    return self.letterImages.count*1.0/self.frameRate;
}
-(CGFloat)startWordAnimationView
{
    self.wordImages = [self getWordImages];
    return self.wordImages.count*1.0/self.frameRate;
}
-(CGFloat)showWoridImageWithSinglesyllable:(NSString*)singlesyllable
{
    self.wordImageView.image = [UIImage imageNamed:singlesyllable];
    CGFloat duration = [self startLetterAnimationView];
    return duration;
}
-(CGFloat)showWoridImageWithWord:(NSString*)word
{
    self.wordImageView.image = [UIImage imageNamed:word];
    CGFloat duration = [self startWordAnimationView];
    return duration;
}

-(NSArray<UIImage*>*)getMainImages
{
    NSMutableArray*tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i< 76; i++) {
        UIImage*image = [UIImage imageNamed:[NSString stringWithFormat:@"Main_%05d",i]];
        if (image) {
            [tempArray addObject:image];
        }
    }
    return tempArray;
}
-(NSArray<UIImage*>*)getLetterImages
{
    NSMutableArray*tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 54; i< 68; i++) {
        UIImage*image = [UIImage imageNamed:[NSString stringWithFormat:@"Letter_%05d",i]];
        if (image) {
            [tempArray addObject:image];
        }
    }
    return tempArray;
}
-(NSArray<UIImage*>*)getTitleImages
{
    NSMutableArray*tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i< 16; i++) {
        UIImage*image = [UIImage imageNamed:[NSString stringWithFormat:@"Title_%05d",i]];
        if (image) {
            [tempArray addObject:image];
        }
    }
    return tempArray;
}

-(NSArray<UIImage*>*)getWordImages
{
    NSMutableArray*tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 33; i< 53; i++) {
        UIImage*image = [UIImage imageNamed:[NSString stringWithFormat:@"Word_%05d",i]];
        if (image) {
            [tempArray addObject:image];
        }
    }
    return tempArray;
}
//每帧图片
-(void)refeshEverframe
{
    if (self.mainImages) {
        
        if (self.mainImages.count>self.mainIndex) {
            self.mainImageView.image = self.mainImages[self.mainIndex];
            self.mainIndex++;
        }else{
            self.mainIndex = 0;
            self.mainImageView.image = self.mainImages[self.mainIndex];
        }
    }
    
    if (self.titileImages) {
        if (self.titileImages.count>self.titileIndex) {
            self.titileAnimationView.image = self.titileImages[self.titileIndex];
            self.titileIndex ++;
        }else{
            self.titileIndex = 0;
            self.titileImages = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.titileAnimationView.image = nil;
            });
        }
    }
    
    if (self.letterImages) {
        if (self.letterImages.count>self.letterIndex) {
            self.letterAnimationView.image = self.letterImages[self.letterIndex];
            self.letterIndex ++;
        }else{
            self.letterIndex = 0;
            self.letterImages = nil;
            self.letterAnimationView.image = nil;
            self.wordImageView.image = nil;
        }
    }
    
    if (self.wordImages) {
        if (self.wordImages.count>self.wordIndex) {
            self.wordAnimationView.image = self.wordImages[self.wordIndex];
            self.wordIndex ++;
        }else{
            self.wordIndex = 0;
            self.wordImages = nil;
            self.wordAnimationView.image =nil;
            self.wordImageView.image = nil;
        }
    }
}
@end
