//
//  MonitorManager.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "MonitorManager.h"

@interface MonitorManager ()

@property (nonatomic, strong) NSMutableArray <id <ProjectMonitorProtocol>>*monitors;
@end

@implementation MonitorManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _monitors = [@[] mutableCopy];
    }
    return self;
}

- (void)addMonitor:(id <ProjectMonitorProtocol>)monitor
{
    [self.monitors addObject:monitor];
}

- (void)execute
{
    for (id <ProjectMonitorProtocol> obj in self.monitors) {
        [obj execute];
    }
}
@end
