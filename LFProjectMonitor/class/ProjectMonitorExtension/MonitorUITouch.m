//
//  MonitorUITouch.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/13.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "MonitorUITouch.h"
#import "ProjectMonitorHook.h"

@implementation MonitorUITouch

- (void)execute
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /** 监听UIApplication */
        [ProjectMonitorHook hookClass:[UIApplication class]
                        swizzledClass:[self class]
                     originalSelector:@selector(sendEvent:)
                     swizzledSelector:@selector(MUIT_sendEvent:)];
        
        [ProjectMonitorHook hookClass:[UIApplication class]
                        swizzledClass:[self class]
                     originalSelector:@selector(sendAction:to:from:forEvent:)
                     swizzledSelector:@selector(MUIT_sendAction:to:from:forEvent:)];
        
    });
}

- (void)MUIT_sendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) { /** 屏幕触摸 */
        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
            [ProjectMonitorLogger LogForTouch:touch];
        }];
    }
    [self MUIT_sendEvent:event];
}

- (BOOL)MUIT_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event
{
    if ([NSStringFromSelector(action) isEqualToString:@"_sendAction:withEvent:"] == NO) {
        [ProjectMonitorLogger LogForAction:action to:target from:sender forEvent:event];
    }
    BOOL b = [self MUIT_sendAction:action to:target from:sender forEvent:event];
    return b;
}

@end
