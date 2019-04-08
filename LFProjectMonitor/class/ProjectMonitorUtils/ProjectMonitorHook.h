//
//  ProjectMonitorHook.h
//  MEMobileKit
//
//  Created by TsanFeng Lam on 2019/4/1.
//  Copyright © 2019 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectMonitorHook : NSObject

+ (void)hookClass:(Class)originalClass swizzledClass:(Class)swizzledClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
