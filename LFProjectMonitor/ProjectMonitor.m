//
//  ProjectMonitor.m
//  MEMobile
//
//  Created by LamTsanFeng on 2017/1/12.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "ProjectMonitor.h"

#import "MonitorManager.h"

#import "MonitorBase.h"
#import "MonitorUIDestroy.h"
#import "MonitorUITouch.h"
#import "MonitorUIStutter.h"
#import "MonitorMethodTimeCost.h"

@interface ProjectMonitor ()

@end

@implementation ProjectMonitor

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        /** 创建管理器 */
        MonitorManager *manager = [MonitorManager new];
        
        /** 创建监听模式 */
        
        /** UI销毁 */
        MonitorBase *muid = [MonitorUIDestroy new];
        [manager addMonitor:muid];
        
        /** 屏幕点击 */
        MonitorBase *muit = [MonitorUITouch new];
        [manager addMonitor:muit];

        /** 卡顿 */
        MonitorBase *muis = [MonitorUIStutter new];
        [manager addMonitor:muis];
        
        /** 方法耗时监控，必须真机64位 */
        MonitorBase *mumtc = [MonitorMethodTimeCost new];
        [manager addMonitor:mumtc];
        
        /** 执行组合模式 */
        [manager execute];
    });
}
@end
