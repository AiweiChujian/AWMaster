//
//  AWMaster.h
//  AWMaster
//
//  Created by Aiwei on 2020/4/23.
//

#import <Foundation/Foundation.h>

#define AWCompleteSingleton(_methodName) \
+ (instancetype) _methodName\
{\
    static id singleton;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        singleton = [[super allocWithZone:NULL]init];\
    });\
    return singleton;\
}\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    return [self _methodName];\
}\

NS_ASSUME_NONNULL_BEGIN

@protocol AWAPPAnnouncement <NSObject>

@optional
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end

@protocol AWMaster <NSObject>

@optional;

/// 处理同名方法的重复注册,
/// 返回YES将覆盖注册, 返回NO将忽略注册
+ (BOOL)reregisterSeletor:(SEL)selector forSlave:(Class)slave previousSlave:(Class)previousSlave;

/// 注册master中已经实现的方法(不允许的行为)
+ (void)masterImplementedSelecotr:(SEL)selector fromSlave:(Class)slave isInstanceMethod:(BOOL)isInstanceMethod;

/// 未注册的类/实例方法被调用
+ (void)unregisteredSelector:(SEL)selector isInstanceMethod:(BOOL)isInstanceMethod;

/// 通过urlPath调用服务时,验证urlPath
+ (BOOL)isSafeUrlPath:(NSString *)urlPath andIsInstanceMethod:(BOOL *)isInstanceMethod;

@end

@interface AWMaster : NSObject<AWMaster,AWAPPAnnouncement>

/// 实例方法与类的映射
@property (class, nonatomic, readonly)NSDictionary <NSString *, Class> *instanceMethodDictionary;

/// 类方法与类的映射
@property (class, nonatomic, readonly)NSDictionary <NSString *, Class> *classMethodDictionary;

/// Announcement接受者数组
@property (class, nonatomic, readonly)NSArray <Class> *receiverArray;

/// 单例,用于调用实例方法
+ (instancetype)master;

/// 注册服务
/// 注册服务时会将slave添加到receiverArray中(接收Announcement)
/// @param slave 服务提供者,需要创建为完全单例
/// @param protocol 服务协议
/// 可重写+ reregisterSeletor:forClass:previousClass:来处理同名方法的重复注册
+ (void)registerSlave:(Class)slave withProtocol:(Protocol *)protocol;

/// 注销服务
/// 注销服务时不会将slave从receiverArray中移除(仍接收Announcement)
/// @param protocol 服务协议
+ (void)deregisterProtocol:(Protocol *)protocol;

/// 添加Announcement接收者
/// @param receiver 接收者
+ (void)addAnnouncementReceiver:(Class)receiver;

/// 移除Announcement接受者
/// @param receiver 接收者
+ (void)removeAnnouncementReceiver:(Class)receiver;

/// 远程服务调用
/// @param urlPath    例: scheme://[methodType]/[selector]?[params] ,
/// methodType为 class 时调用类方法; 为其它值时将调用实例方法
/// 可重写+ isSafeUrlPath:andIsInstanceMethod:方法来对urlPath做验证
/// 可被远程调用的服务(selector)应当只有一个参数,类型为NSString,NSArray或NSDictionary
+ (id _Nullable)openServiceWithUrlPath:(NSString *)urlPath;

@end


NS_ASSUME_NONNULL_END
