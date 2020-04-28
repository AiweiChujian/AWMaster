//
//  AWMaster.m
//  AWMaster
//
//  Created by Aiwei on 2020/4/23.
//

#import "AWMaster.h"
#import <objc/runtime.h>
#import "AWMaster+Tools.h"

static NSMutableDictionary <NSString *, Class> *_instanceMethodDictonary;
static NSMutableDictionary <NSString *, Class> *_classMethodDictonary;
static NSMutableArray <Class> *_receiverArray;

#define AW_GENERAL_CTYPES "v@:@"

@implementation AWMaster

AWCompleteSingleton(master)

+(NSDictionary<NSString *,Class> *)instanceMethodDictionary
{
    return [NSDictionary dictionaryWithDictionary:_instanceMethodDictonary];
}

+ (NSDictionary<NSString *,Class> *)classMethodDictionary
{
    return [NSDictionary dictionaryWithDictionary:_classMethodDictonary];
}

+ (NSArray<Class> *)receiverArray
{
    return [NSArray arrayWithArray:_receiverArray];
}

#pragma mark - 公开接口

+ (void)registerSlave:(Class)slave withProtocol:(Protocol *)protocol;
{
    [self addAnnouncementReceiver:slave];
    
    if (!_instanceMethodDictonary) {
        _instanceMethodDictonary = [[NSMutableDictionary alloc]init];
    }
    if (!_classMethodDictonary) {
        _classMethodDictonary = [[NSMutableDictionary alloc]init];
    }
    
    // 注册实例方法
    [self p_registerProtocol:protocol requiredMethod:YES instanceMethod:YES withClass:slave];
    [self p_registerProtocol:protocol requiredMethod:NO instanceMethod:YES withClass:slave];
    
    // 注册类方法
    [self p_registerProtocol:protocol requiredMethod:YES instanceMethod:NO withClass:slave];
    [self p_registerProtocol:protocol requiredMethod:NO instanceMethod:NO withClass:slave];
    
}

+ (void)deregisterProtocol:(Protocol *)protocol
{
    // 注销实例方法
    [self p_registerProtocol:protocol requiredMethod:YES instanceMethod:YES withClass:nil];
    [self p_registerProtocol:protocol requiredMethod:NO instanceMethod:YES withClass:nil];
    
    // 注销类方法
    [self p_registerProtocol:protocol requiredMethod:YES instanceMethod:NO withClass:nil];
    [self p_registerProtocol:protocol requiredMethod:NO instanceMethod:NO withClass:nil];
}

+ (void)addAnnouncementReceiver:(Class)receiver
{
    if (!_receiverArray) {
        _receiverArray = [[NSMutableArray alloc]init];
    }
    
    if (![_receiverArray containsObject:receiver]) {
        [_receiverArray addObject:receiver];
    }
}

+ (void)removeAnnouncementReceiver:(Class)receiver
{
    [_receiverArray removeObject:receiver];
}

+ (id)openServiceWithUrlPath:(NSString *)urlPath
{
    BOOL isInstanceMethod = NO;
    if ([self isSafeUrlPath:urlPath andIsInstanceMethod:&isInstanceMethod]) {
        
        NSCharacterSet *trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        NSURL *url = [NSURL URLWithString:urlPath];
        NSString *selectorName = [url.path stringByTrimmingCharactersInSet:trimmingSet];
        NSString *paramString = [url.query stringByTrimmingCharactersInSet:trimmingSet];
        
        id object = paramString; // 参数是字符串
        if ([paramString containsString:@"&"]) {
            NSArray <NSString *> *paramArray = [paramString componentsSeparatedByString:@"&"];
            object = paramArray; // 参数是数组
            if([paramArray.firstObject containsString:@"="])
            {
                NSMutableDictionary *paramDicionary = [[NSMutableDictionary alloc] init];
                object = paramDicionary; // 参数是字典
                for (NSString *param in paramArray) {
                    NSArray *elts = [param componentsSeparatedByString:@"="];
                    [paramDicionary setObject:[elts lastObject] forKey:[elts firstObject]];
                }
            }
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id target = isInstanceMethod?[self new]:self;
        return [target performSelector:NSSelectorFromString(selectorName) withObject:object];
#pragma clang diagnostic pop
    }
    return nil;
}
#pragma mark 私有方法

+ (void)p_registerProtocol:(Protocol *)protocol requiredMethod:(BOOL)isRequiredMethod instanceMethod:(BOOL)isInstanceMethod withClass:(Class)cls
{
#warning to do 验证方法名是否和Master的方法同名
    
    NSMutableDictionary *targetDictionary = isInstanceMethod?_instanceMethodDictonary:_classMethodDictonary;
    unsigned int methodCount = 0;
    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &methodCount);
    
    if (methodList) {
        for (int i = 0; i<methodCount; i++) {
            struct objc_method_description methodDes = methodList[i];
            NSString *key = NSStringFromSelector(methodDes.name);
            if (cls) { // cls为nil时即注销服务协议
                Class previousClass = targetDictionary[key];
                if (previousClass && ![self reregisterSeletor:methodDes.name forSlave:cls previousSlave:previousClass]) {
                    continue;
                }
            }
            targetDictionary[key] = cls;
        }
        free(methodList);
    }
}


#pragma mark forward selector

+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    Class slave = _classMethodDictonary[NSStringFromSelector(aSelector)];
    if (slave) {
        return slave;
    }
    else
    {
        [self unregisteredSelector:aSelector isInstanceMethod:NO];
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    Class slave = _instanceMethodDictonary[NSStringFromSelector(aSelector)];
    if (slave) {
        return [slave new];
    }
    else
    {
        [self.class unregisteredSelector:aSelector isInstanceMethod:YES];
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes:AW_GENERAL_CTYPES];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"unrecognized selector (-%@) sent to Master ",NSStringFromSelector(anInvocation.selector));
}
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes:AW_GENERAL_CTYPES];
}
+ (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"unrecognized selector (+%@) sent to Master ",NSStringFromSelector(anInvocation.selector));
}
#pragma mark protocol AWMaster

+ (BOOL)reregisterSeletor:(SEL)selector forSlave:(Class)slave previousSlave:(Class)previousSlave
{
    NSLog(@"⚠️ reregister seletor (%@), for class (%@), previous class (%@)",NSStringFromSelector(selector),NSStringFromClass(slave),NSStringFromClass(previousSlave));
    return YES;
}

+ (void)unregisteredSelector:(SEL)selector isInstanceMethod:(BOOL)isInstanceMethod
{
    NSLog(@"⚠️ sent unregistered selector (%@%@) ",isInstanceMethod?@"-":@"+",NSStringFromSelector(selector));
}

+ (BOOL)isSafeUrlPath:(NSString *)urlPath andIsInstanceMethod:(BOOL *)isInstanceMethod
{
    NSURL *url = [NSURL URLWithString:urlPath];
    *isInstanceMethod = ([[url.scheme lowercaseString] isEqualToString:@"class"])?NO:YES;
    
    return urlPath.length?YES:NO;
}

#pragma AWAPPAnnouncement
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc]init];
    for (Class cls in _receiverArray) {
        if ([cls instancesRespondToSelector:_cmd]) {
            BOOL finished = [[cls new] application:application didFinishLaunchingWithOptions:launchOptions];
            results[NSStringFromClass(cls)] = @(finished);
        }
    }
    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application)
}

@end

