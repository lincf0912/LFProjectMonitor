Pod::Spec.new do |s|
s.name         = 'LFProjectMonitor'
s.version      = '0.0.1'
s.summary      = 'Monitor Project'
s.homepage     = 'https://github.com/lincf0912/LFProjectMonitor'
s.license      = 'MIT'
s.author       = { 'lincf0912' => 'dayflyking@163.com' }
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.source       = { :git => 'https://github.com/lincf0912/LFProjectMonitor.git', :tag => s.version, :submodules => true }
s.requires_arc = true
s.source_files = 'LFProjectMonitor/class/*.{h,m}'
s.public_header_files = 'LFProjectMonitor/class/ProjectMonitorExtension/*.h'

end
