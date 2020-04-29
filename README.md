# AWMaster

[![CI Status](https://img.shields.io/travis/oovsxx@163.com/AWMaster.svg?style=flat)](https://travis-ci.org/oovsxx@163.com/AWMaster)
[![Version](https://img.shields.io/cocoapods/v/AWMaster.svg?style=flat)](https://cocoapods.org/pods/AWMaster)
[![License](https://img.shields.io/cocoapods/l/AWMaster.svg?style=flat)](https://cocoapods.org/pods/AWMaster)
[![Platform](https://img.shields.io/cocoapods/p/AWMaster.svg?style=flat)](https://cocoapods.org/pods/AWMaster)

## Description

AWMaster是组件化架构中的中间件，核心是消息转发和面向接口编程。组件可以直接通过Master调用方法来获取服务，调用时支持任意公共类型参数的传递，同时也提供通过urlPath进行服务调用，提供相关接口来对异常调用做集中处理，还提供公告功能来将消息转发给所有想要接收的组件。

## Installation

AWMaster支持通过 [CocoaPods](https://cocoapods.org) 安装：

```ruby
pod 'AWMaster'
```

## Usage

### 组件服务

AWMaster使用Master-Slave的主从结构，使用时创建一个继承自AWMaster的子类作为中间件，在提供服务的组件中创建一个Slave类，然后制定一份服务协议（Protocol），让中间件Master和Slave都遵循这份协议：

```objc
// MoudleAProtocol.h
@protocol MoudleAProtocol <NSObject>
+ (UIImage *)moudleA_imageWithImageName:(NSString *)imageName;
@end

// MyMaster_A.h
@interface MyMaster : AWMaster
<
    MoudleAProtocol
>
@end

// MySlave_A.h
@interface MySlave_A : NSObject<MoudleAProtocol>

@end

```
然后可以在Slave的load方法中注册Slave为协议的执行者：

```objc
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MyMaster registerSlave:self withProtocol:@protocol(MoudleAProtocol)];
    });
}
```
最后，在Slave中实现服务协议的内容，当其他组件需要调用服务时，通过Master即可调用服务协议中的方法，Master内部会将方法转发给提供服务的Slave：

```objc
UIImage *image = [MyMaster moudleA_imageWithImageName:@"preview_1.png"];
```

### 远程调用

AWMaster中可以通过`urlPath`来调用服务以满足一些远程调用的需求，`urlPath`的格式为`scheme://[methodType]/[selector]?[params]`，例如以上的调用也可以这样进行：

```objc
UIImage *image = [MyMaster openServiceWithUrlPath:@"image://class/moudleA_imageWithImageName:?preview_1.png"];
```

### 公告通知

在组件化架构中，有的时候可能需要将一条消息通知给其它多个组件，AWMaster提供了公告（Announcement）功能，公告也是协议，和服务协议不同的是，它需要在中间件中群发给`receiverArray`中的Slave。AWMater中实现了对APP生命周期相关的几个方法的分发，**在中间件中**可以选择遍历`receiverArray`来分发公告：

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc]init];
    for (Class cls in [self.class receiverArray]) {
        if ([cls instancesRespondToSelector:_cmd]) {
            BOOL finished = [[cls new] application:application didFinishLaunchingWithOptions:launchOptions];
            results[NSStringFromClass(cls)] = @(finished);
        }
    }
    return YES;
}
```

也可以使用`AWMaster+Tools`中封装的宏`AW_AnnounceCurrentMethod(...)`来将消息转发给所有需要接收的Slave：

```objc
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}
```

## Demo

`repo`中包含一个demo, 运行demo之前，需要先执行`pod install`。

## License

AWMaster 支持 MIT 许可协议，详情见 LICENSE 文件。
