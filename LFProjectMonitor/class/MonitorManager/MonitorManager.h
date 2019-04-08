//
//  MonitorManager.h
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectMonitorProtocol.h"

@interface MonitorManager : NSObject

- (void)addMonitor:(id <ProjectMonitorProtocol>)monitor;

- (void)execute;
@end
