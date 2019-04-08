//
//  MonitorBase.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "MonitorBase.h"

@implementation MonitorBase

- (void)execute
{
    /** 子类实现 */
}

+ (NSString *)monitorPath
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"ProjectMonitor"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

@end
