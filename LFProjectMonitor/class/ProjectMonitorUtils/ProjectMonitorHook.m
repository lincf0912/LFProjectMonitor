//
//  ProjectMonitorHook.m
//  MEMobileKit
//
//  Created by TsanFeng Lam on 2019/4/1.
//  Copyright © 2019 GZMiracle. All rights reserved.
//

#import "ProjectMonitorHook.h"
#import <objc/runtime.h>

@implementation ProjectMonitorHook

#pragma mark 替换方法
+ (void)hookClass:(Class)originalClass swizzledClass:(Class)swizzledClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    
    if (!originalMethod || !swizzledMethod) {
        return;
    }
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
    
    class_replaceMethod(originalClass,swizzledSelector,originalIMP,originalType);
    class_replaceMethod(originalClass,originalSelector,swizzledIMP,swizzledType);
}

@end
