//
//  MonitorUIDestroy.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "MonitorUIDestroy.h"
#import <objc/runtime.h>
#import "ProjectMonitorHook.h"

static const char * MonitorUIDisplayKey = "MonitorUIDisplayKey";
static const char * MonitorUIDestroyKey = "MonitorUIDestroyKey";

@implementation MonitorUIDestroy


- (void)dealloc
{
    [MonitorUIDestroy setMapTable:nil];
    [MonitorUIDestroy setHashTable:nil];
}

+ (NSMapTable *)mapTable{
    NSMapTable *mapTable = objc_getAssociatedObject(self, MonitorUIDisplayKey);
    if (mapTable == nil) {
        mapTable = [NSMapTable strongToWeakObjectsMapTable];
    }
    return mapTable;
}

+ (void)setMapTable:(NSMapTable *)mapTalbe
{
    objc_setAssociatedObject(self, MonitorUIDisplayKey, mapTalbe, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSHashTable *)hashTable{
    NSHashTable *hashTable = objc_getAssociatedObject(self, MonitorUIDestroyKey);
    if (hashTable == nil) {
        hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return hashTable;
}

+ (void)setHashTable:(NSHashTable *)hashTable
{
    objc_setAssociatedObject(self, MonitorUIDestroyKey, hashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)setObject:(id)viewController
{
    NSMapTable *mapTable = [MonitorUIDestroy mapTable];
    [mapTable setObject:viewController forKey:[NSStringFromClass([viewController class]) stringByAppendingFormat:@"%p", viewController]];
    [MonitorUIDestroy setMapTable:mapTable];
}

+ (void)removeObject:(id)viewController
{
    NSMapTable *mapTable = [MonitorUIDestroy mapTable];
    [mapTable removeObjectForKey:[NSStringFromClass([viewController class]) stringByAppendingFormat:@"%p", viewController]];
    [MonitorUIDestroy setMapTable:mapTable];
}

+ (void)markObject:(id)viewController
{
    NSMapTable *mapTable = [MonitorUIDestroy mapTable];
    /** 没有进入setObject的VC 忽略标记 */
    if ([mapTable objectForKey:[NSStringFromClass([viewController class]) stringByAppendingFormat:@"%p", viewController]]) {
        [mapTable setObject:viewController forKey:[NSString stringWithFormat:@"%p", viewController]];
        [MonitorUIDestroy setMapTable:mapTable];
    }
}

+ (void)removeMarkObject:(id)viewController
{
    NSMapTable *mapTable = [MonitorUIDestroy mapTable];
    [mapTable removeObjectForKey:[NSString stringWithFormat:@"%p", viewController]];
    [MonitorUIDestroy setMapTable:mapTable];
}

+ (void)doDidDisappear:(id)viewController
{
    __weak id weak_viewController = viewController;
    /** 1秒时间销毁UI */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weak_viewController == nil) return ;
        NSMapTable *mapTable = [MonitorUIDestroy mapTable];
        id obj = [mapTable objectForKey:[NSString stringWithFormat:@"%p", weak_viewController]];
        if (obj) {
            [MonitorUIDestroy removeObject:weak_viewController];
            [MonitorUIDestroy removeMarkObject:weak_viewController];
            NSHashTable *hashTable = [MonitorUIDestroy hashTable];
            [hashTable addObject:[NSString stringWithFormat:@"%p", weak_viewController]];
            [MonitorUIDestroy setHashTable:hashTable];
            [ProjectMonitorLogger objNotDealloc:weak_viewController];
        }
    });
}

+ (void)doDealloc:(id)viewController
{
    NSHashTable *hashTable = [MonitorUIDestroy hashTable];
    BOOL isContain = [hashTable containsObject:[NSString stringWithFormat:@"%p", viewController]];
    if (isContain) {
        [hashTable removeObject:[NSString stringWithFormat:@"%p", viewController]];
        [MonitorUIDestroy setHashTable:hashTable];
        [ProjectMonitorLogger objDealloc:viewController];
    }
}


- (void)execute
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /** 监听UINavigationController */
        [ProjectMonitorHook hookClass:[UINavigationController class] swizzledClass:[self class] originalSelector:@selector(setViewControllers:animated:) swizzledSelector:@selector(MUID_setViewControllers:animated:)];
        
        [ProjectMonitorHook hookClass:[UINavigationController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(pushViewController:animated:)
                     swizzledSelector:@selector(MUID_pushViewController:animated:)];
        
        [ProjectMonitorHook hookClass:[UINavigationController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(popViewControllerAnimated:)
                     swizzledSelector:@selector(MUID_popViewControllerAnimated:)];
        
        [ProjectMonitorHook hookClass:[UINavigationController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(popToRootViewControllerAnimated:)
                     swizzledSelector:@selector(MUID_popToRootViewControllerAnimated:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(presentViewController:animated:completion:)
                     swizzledSelector:@selector(MUID_presentViewController:animated:completion:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(dismissViewControllerAnimated:completion:)
                     swizzledSelector:@selector(MUID_dismissViewControllerAnimated:completion:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(viewDidAppear:)
                     swizzledSelector:@selector(MUID_viewDidAppear:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(viewDidDisappear:)
                     swizzledSelector:@selector(MUID_viewDidDisappear:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(addChildViewController:)
                     swizzledSelector:@selector(MUID_addChildViewController:)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:@selector(removeFromParentViewController)
                     swizzledSelector:@selector(MUID_removeFromParentViewController)];
        
        [ProjectMonitorHook hookClass:[UIViewController class]
                        swizzledClass:[self class]
                     originalSelector:NSSelectorFromString(@"dealloc")
                     swizzledSelector:@selector(MUID_dealloc)];
    });
}

- (void)MUID_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [MonitorUIDestroy setObject:obj];
    }];
    [self MUID_setViewControllers:viewControllers animated:animated];
}

- (void)MUID_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [MonitorUIDestroy setObject:viewController];
    [self MUID_pushViewController:viewController animated:animated];
}

- (UIViewController *)MUID_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *viewController = [self MUID_popViewControllerAnimated:animated];
    [MonitorUIDestroy markObject:viewController];
    return viewController;
}

- (nullable NSArray<__kindof UIViewController *> *)MUID_popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray<__kindof UIViewController *> *viewControllers = [self MUID_popToRootViewControllerAnimated:animated];
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [MonitorUIDestroy markObject:obj];
    }];
    return viewControllers;
}

- (void)MUID_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    if ([viewControllerToPresent isKindOfClass:[UIViewController class]]) {
        [MonitorUIDestroy setObject:viewControllerToPresent];
    }
    [self MUID_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)MUID_dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion
{
    if ([(UIViewController *)self presentedViewController]) {
        if ([[(UIViewController *)self presentedViewController] navigationController]) {
            NSArray<__kindof UIViewController *> *viewControllers = [[[(UIViewController *)self presentedViewController] navigationController] viewControllers];
            [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [MonitorUIDestroy markObject:obj];
            }];
        } else {
            [MonitorUIDestroy markObject:[(UIViewController *)self presentedViewController]];
        }
    }
    
    if ([(UIViewController *)self presentingViewController]) {
        if ([(UIViewController *)self navigationController]) {
            NSArray<__kindof UIViewController *> *viewControllers = [[(UIViewController *)self navigationController] viewControllers];
            [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [MonitorUIDestroy markObject:obj];
            }];
        } else {
            [MonitorUIDestroy markObject:(UIViewController *)self];
        }
    }
    
    [self MUID_dismissViewControllerAnimated:flag completion:completion];
}

- (void)MUID_viewDidAppear:(BOOL)animated
{
    [MonitorUIDestroy removeMarkObject:self];
    UIViewController *vc = (UIViewController *)self;
    [ProjectMonitorLogger objWillAppear:vc];
    [self MUID_viewDidAppear:animated];
}

- (void)MUID_viewDidDisappear:(BOOL)animated
{
    [MonitorUIDestroy doDidDisappear:self];
    [self MUID_viewDidDisappear:animated];
}

- (void)MUID_addChildViewController:(UIViewController *)childController
{
    [MonitorUIDestroy setObject:childController];
    [self MUID_addChildViewController:childController];
}

- (void)MUID_removeFromParentViewController
{
    NSHashTable *hashTable = [MonitorUIDestroy hashTable];
    BOOL isContain = [hashTable containsObject:[NSString stringWithFormat:@"%p", self]];
    if (isContain) {
        [MonitorUIDestroy markObject:self];
        [MonitorUIDestroy doDidDisappear:self];
    }
    [self MUID_removeFromParentViewController];
}

- (void)MUID_dealloc
{
    [MonitorUIDestroy doDealloc:self];
    [self MUID_dealloc];
}

@end
