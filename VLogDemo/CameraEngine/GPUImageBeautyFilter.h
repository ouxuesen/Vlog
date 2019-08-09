//
//  GPUImageBeautyFilter.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/11.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBeautyFilter : GPUImageFilter

/** 美颜程度 */
@property (nonatomic, assign) CGFloat beautyLevel;
/** 美白程度 */
@property (nonatomic, assign) CGFloat brightLevel;
/** 色调强度 */
@property (nonatomic, assign) CGFloat toneLevel;

@end

NS_ASSUME_NONNULL_END
