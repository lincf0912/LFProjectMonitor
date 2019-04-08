//
//  MonitorUIStutter.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/13.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "MonitorUIStutter.h"
#import "ProjectMonitorLogger.h"

@interface MonitorUIStutter ()
{
    CFRunLoopObserverRef _observer;
    dispatch_semaphore_t _semaphore;
    CFRunLoopActivity _activity;
    NSInteger _countTime;
}
@end

@implementation MonitorUIStutter

- (void)execute
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /** 监听 */
        [self start];
    });
}

- (void)dealloc
{
    [self stop];
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    MonitorUIStutter *moniotr = (__bridge MonitorUIStutter*)info;
    
    moniotr->_activity = activity;
    
    dispatch_semaphore_t semaphore = moniotr->_semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)stop
{
    if (!_observer) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}

- (void)start
{
    if (_observer) return;
    
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                        kCFRunLoopAllActivities,
                                        YES,
                                        0,
                                        &runLoopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    // 创建信号
    _semaphore = dispatch_semaphore_create(0);
    
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES && self->_observer)
        {   
             // 假定连续3次超时90ms认为卡顿(当然也包含了单次超时90ms)
            long st = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, 90*NSEC_PER_MSEC));
            if (st != 0)
            {
                if (!self->_observer) {
                    self->_countTime = 0;
                    self->_semaphore = 0;
                    self->_activity = 0;
                    return;
                }
                if (self->_activity==kCFRunLoopBeforeSources || self->_activity==kCFRunLoopAfterWaiting)
                {
                    if (++self->_countTime < 3) {
                        continue;
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [ProjectMonitorLogger LogbacktraceOfThread];
                    });
                }
            }
            self->_countTime = 0;
        }
    });
}

@end
