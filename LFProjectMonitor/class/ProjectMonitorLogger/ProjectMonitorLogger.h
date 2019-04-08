//
//  ProjectMonitorLogger.h
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectMonitorLogger : NSObject

+ (void)objDealloc:(id)obj;
+ (void)objNotDealloc:(id)obj;
+ (void)objWillAppear:(UIViewController *)vc;

/** =========Touchs========= */

+ (void)LogForTouch:(UITouch *)touch;
+ (void)LogForAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;

/** =========Stutter======== */

+ (void)LogbacktraceOfThread;

@end
