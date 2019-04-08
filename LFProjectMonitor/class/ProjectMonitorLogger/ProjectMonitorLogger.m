//
//  ProjectMonitorLogger.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "ProjectMonitorLogger.h"
#import "SMCallStack.h"
#import "MonitorBase.h"

@interface NSString (pm_writeToFile)

- (void)pm_writeToFile:(NSString *)string;

@end

@implementation NSString (pm_writeToFile)

- (void)pm_writeToFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        [self writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        
        [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
        
        NSData* stringData  = [self dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle writeData:stringData]; //追加写入数据
        
        [fileHandle closeFile];
    }
}

@end


@implementation ProjectMonitorLogger

+ (NSString *)monitorFilePathWithType:(int)type
{
    NSString *m_path = [MonitorBase monitorPath];
    NSString *m_name = nil;
    switch (type) {
        case 1:
            m_name = @"UIDestroy.txt";
            break;
        case 2:
            m_name = @"UITouch.txt";
            break;
        case 3:
            m_name = @"UIStutter.txt";
            break;
    }
    if (m_name.length) {
        return [m_path stringByAppendingPathComponent:m_name];
    }
    return nil;
}

+ (void)objDealloc:(id)obj
{
    NSString *s = [NSString stringWithFormat:@"\n‼️%s %s监测到 %@ -> 重新执行dealloc ⭕️", __DATE__, __TIME__, obj];
    [s pm_writeToFile:[self monitorFilePathWithType:1]];
    NSLog(@"%@", s);
}

+ (void)objNotDealloc:(id)obj
{
    NSString *s = [NSString stringWithFormat:@"\n‼️%s %s监测到 %@ -> 可能没有执行dealloc ❌", __DATE__, __TIME__, obj];
    [s pm_writeToFile:[self monitorFilePathWithType:1]];
    NSLog(@"%@", s);
}

+ (void)objWillAppear:(UIViewController *)vc
{
    NSString *obj = nil;
    if ([vc.navigationController.viewControllers containsObject:vc]) {
        obj = [NSString stringWithFormat:@"\n%@当前堆栈UI:\n%@", vc.navigationController, vc.navigationController.viewControllers];
    } else if (![vc isKindOfClass:[UINavigationController class]]) {
        NSLog(@"\n当前UI:\n%@", @[vc]);
        obj = [NSString stringWithFormat:@"\n当前UI:\n%@", @[vc]];
    }
    
    if (obj) {
        NSString *s = [NSString stringWithFormat:@"\n%s %s %@", __DATE__, __TIME__, obj];
        [s pm_writeToFile:[self monitorFilePathWithType:1]];
        NSLog(@"%@", s);
    }
}

/** =========Touchs========= */


+ (NSString *)getTouchState:(UITouch *)touch
{
    NSString *state = nil;
    switch (touch.phase) {
        case UITouchPhaseBegan:
            state = @"(开始)";
            break;
        case UITouchPhaseMoved:
            state = @"(移动)";
            break;
        case UITouchPhaseEnded:
            state = @"(结束)";
            break;
        case UITouchPhaseCancelled:
            state = @"(取消)";
            break;
        case UITouchPhaseStationary:
            state = @"(固定)";
            break;
    }
    return state;
}


+ (NSDate *)mm_localeDate
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];

    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];

    NSDate *localeDate = [[NSDate date] dateByAddingTimeInterval: interval];

    return localeDate;
}


+ (void)LogForTouch:(UITouch *)touch
{
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"‼️%s %s 监听点击事件->", __DATE__, __TIME__];
    UIView *view = touch.view;
    if (view == nil) {
        view = touch.gestureRecognizers.firstObject.view;
    }
    UIViewController *viewController = [self findViewControllerFromView:view];
    [mStr appendFormat:@"%@ -> %@(%@)", NSStringFromClass([viewController class]), NSStringFromClass([touch.gestureRecognizers.firstObject.view class]), NSStringFromCGPoint([touch locationInView:touch.window])];
    [mStr appendFormat:@"在%@被点击，", [ProjectMonitorLogger mm_localeDate]];
    [mStr appendString:@"点击状态"];
    [mStr appendString:[self getTouchState:touch]];
    if (touch.gestureRecognizers.count) {
        for (UIGestureRecognizer *gest in touch.gestureRecognizers) {
            if (![NSStringFromClass([gest class]) hasPrefix:@"_"]) {
                [mStr appendFormat:@"\n%@", [gest description]];
            }
        }
    }
    [mStr pm_writeToFile:[self monitorFilePathWithType:2]];
    printf("%s\n", [mStr UTF8String]);
}

+ (UIViewController*)findViewControllerFromView:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

+ (void)LogForAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"‼️%s %s 监听点击事件传递->", __DATE__, __TIME__];
    [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull touch, BOOL * _Nonnull stop) {
        [mStr appendFormat:@"%@", NSStringFromClass([touch.view class])];
        [mStr appendString:@"点击状态"];
        [mStr appendString:[self getTouchState:touch]];
        [mStr appendString:@" ->"];
    }];
    [mStr appendFormat:@" %@ -> %@ 调用 %@ 方法", NSStringFromClass([sender class]), NSStringFromClass([target class]), NSStringFromSelector(action)];
    [mStr pm_writeToFile:[self monitorFilePathWithType:2]];
    printf("%s\n", [mStr UTF8String]);
}

/** =========Stutter======== */

+ (void)LogbacktraceOfThread
{
    NSString *s = [NSString stringWithFormat:@"⁉️%s %s 监听卡顿->调用堆栈->%@", __DATE__, __TIME__, [SMCallStack callStackWithType:SMCallStackTypeMain]];
    [s pm_writeToFile:[self monitorFilePathWithType:3]];
    printf("%s\n", [s UTF8String]);
}

@end
