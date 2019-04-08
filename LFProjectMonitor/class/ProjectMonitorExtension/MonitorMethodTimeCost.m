//
//  MonitorMethodTimeCost.m
//  MEMobileKit
//
//  Created by TsanFeng Lam on 2019/4/1.
//  Copyright © 2019 GZMiracle. All rights reserved.
//

#import "MonitorMethodTimeCost.h"
#import "ProjectMonitorHook.h"
#import "SMCallTrace.h"
#import <objc/runtime.h>
#include <stdio.h>
#include <string.h>

void write_data_to_file(const char *path, char *str)
{
    FILE *fd = fopen(path, "a+");
    if (fd == NULL)
    {
        printf("fd is NULL and open file fail\n");
        return;
    }
    printf("fd != NULL\n");
    if (str && str[0] != 0)
    {
        fwrite(str, strlen(str), 1, fd);
        char *next = "\n";
        fwrite(next, strlen(next), 1, fd);
    }
    fclose(fd);
}

char * m_time(void){
    time_t now = time (NULL);
    return ctime(&now);
}


@implementation MonitorMethodTimeCost

- (void)execute
{
    NSString *m_path = [MonitorBase monitorPath];
    NSString *m_name = @"TimeCost.txt";
    const char *path = [[m_path stringByAppendingPathComponent:m_name] UTF8String];
    
    [SMCallTrace startWithMaxDepth:0];
    
    /** 由于start了之后会监听所有object-c的方法(objc_msgSend)拦截，所以load的回调不能使用object-c的方法。否则会崩溃。 */
    [SMCallTrace load:^(smCallTraceRecord *record) {
        char c[1024];
        sprintf(c,"⏳%s监听耗时->level:%2d|%6.2fms|%s[%s %s]\n", m_time(), (int)record->depth, record->time * 1000, (class_isMetaClass(record->cls) ? "+" : "-"), class_getName(record->cls), sel_getName(record->sel));
        printf("%s", c);
        
        write_data_to_file(path, c);
        
    }];
}

@end
