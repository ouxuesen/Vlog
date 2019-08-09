//
//  CanvasView.h
//  Created by sluin on 15/7/1.
//  Copyright (c) 2015年 SunLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanvasView : UIView
//头部贴图
@property (nonatomic,strong) UIImage *  headMap;
@property (nonatomic,assign)CGFloat currentProgress ;
@property (nonatomic,assign,readonly)CGFloat animationDuration;
-(void)setEverframe;
@end
