//
//  SMCallTrace.h
//  HomePageTest
//
//  Created by DaiMing on 2017/7/8.
//  Copyright © 2017年 DiDi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    __unsafe_unretained Class cls;
    SEL sel;
    double time; // ms
    int depth;
} smCallTraceRecord;

@interface SMCallTrace : NSObject
+ (void)start; //开始记录
+ (void)startWithMaxDepth:(int)depth;
+ (void)startWithMinCost:(double)ms;
+ (void)startWithMaxDepth:(int)depth minCost:(double)ms;
+ (void)stop; //停止记录
+ (void)load:(void (^)(smCallTraceRecord *record))callBack; //打印记录

@end
