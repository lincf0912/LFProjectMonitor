# LFProjectMonitor

简单嵌入项目并监听，方便移除或关闭监听。不影响项目结构与代码。
* 监听UI Controller
	1. 是否被持有（关闭后没有被释放）
	2. 当前显示的Controller类名（便于接触了解项目）
* 监听UI的点击事件
	1. 具体的点击坐标、点击状态、被点击的类名、点击触发的方法
* 监听UI响应的卡顿（真机测试）
	1. 假定连续3次超时90ms认为卡顿(也包含了单次超时90ms)
* 监听方法响应时间（真机64位测试）
	1. 拦截objc_msgSend的before与after之间的耗时
	
监听被开启后会在控制台输出，同时也会记录在Documents/ProjectMonitor目录下。
	

##How To Use

创建任意一个文件，重写+load方法，内容如下：

````
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
````