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
static NSMutableArray <NSString *> *_selfInstanceSelectorList;
static NSMutableArray <NSString *> *_selfClassSelectorList;

#define AW_GENERAL_TYPES "v@:@"

@implementation AWMaster

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
    
    // (to do: 将以下调用异步派发给一个串行队列, ps:如果这样做,记得消息转发取值时也需要在同一个队列)
    // 注册实例方法
    [self awm_registerProtocol:protocol requiredMethod:YES instanceMethod:YES withClass:slave];
    [self awm_registerProtocol:protocol requiredMethod:NO instanceMethod:YES withClass:slave];
    
    // 注册类方法
    [self awm_registerProtocol:protocol requiredMethod:YES instanceMethod:NO withClass:slave];
    [self awm_registerProtocol:protocol requiredMethod:NO instanceMethod:NO withClass:slave];
    
}

+ (void)deregisterProtocol:(Protocol *)protocol
{
    // 注销实例方法
    [self awm_registerProtocol:protocol requiredMethod:YES instanceMethod:YES withClass:nil];
    [self awm_registerProtocol:protocol requiredMethod:NO instanceMethod:YES withClass:nil];
    
    // 注销类方法
    [self awm_registerProtocol:protocol requiredMethod:YES instanceMethod:NO withClass:nil];
    [self awm_registerProtocol:protocol requiredMethod:NO instanceMethod:NO withClass:nil];
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

        urlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSURL *url = [NSURL URLWithString:urlPath];
        NSCharacterSet *trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        NSString *selectorName = [url.path stringByTrimmingCharactersInSet:trimmingSet];
        NSString *paramString = [[url.query stringByRemovingPercentEncoding] stringByTrimmingCharactersInSet:trimmingSet];
        
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

+ (void)awm_registerProtocol:(Protocol *)protocol requiredMethod:(BOOL)isRequiredMethod instanceMethod:(BOOL)isInstanceMethod withClass:(Class)cls
{
    
    NSMutableDictionary *targetDictionary = isInstanceMethod?_instanceMethodDictonary:_classMethodDictonary;
    unsigned int methodCount = 0;
    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &methodCount);
    
    if (methodList) {
        for (int i = 0; i<methodCount; i++) {
            struct objc_method_description methodDes = methodList[i];
            NSString *key = NSStringFromSelector(methodDes.name);
            // cls为nil时即注销服务协议
            if (cls) {
                if ([self awm_masterRespondsSelector:methodDes.name instanceMethod:isInstanceMethod]) {
                    // slave中注册的方法,master中已实现
                    [self masterRespondsSelecotr:methodDes.name fromSlave:cls isInstanceMethod:isInstanceMethod];
                    continue;
                }
                
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
+ (BOOL)awm_masterRespondsSelector:(SEL)selector instanceMethod:(BOOL)isInstanceMethod
{
    if (isInstanceMethod) {
        if (!_selfInstanceSelectorList) {
            _selfInstanceSelectorList = [[NSMutableArray alloc]init];
        }
        if ([_selfInstanceSelectorList containsObject:NSStringFromSelector(selector)]) {
            return YES;
        }
        if ([self instancesRespondToSelector:selector]) {
            [_selfInstanceSelectorList addObject:NSStringFromSelector(selector)];
            return YES;
      }
    }
    else
    {
        if (!_selfClassSelectorList) {
              _selfClassSelectorList = [[NSMutableArray alloc]init];
          }
          if ([_selfClassSelectorList containsObject:NSStringFromSelector(selector)]) {
              return YES;
          }
          if ([self respondsToSelector:selector]) {
              [_selfClassSelectorList addObject:NSStringFromSelector(selector)];
              return YES;
        }
    }
    return NO;
}

#pragma mark forward selector

+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    Class slave = _classMethodDictonary[NSStringFromSelector(aSelector)];
    if (slave) {
        if ([self willForwardSelector:aSelector toSlave:slave isInstanceMethod:NO]) {
            return slave;
        }
        else
        {
            return [super forwardingTargetForSelector:aSelector];
        }
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
        if ([self.class willForwardSelector:aSelector toSlave:slave isInstanceMethod:YES]) {
            return [slave new];
        }
        else
        {
            return [super forwardingTargetForSelector:aSelector];
        }
    }
    else
    {
        [self.class unregisteredSelector:aSelector isInstanceMethod:YES];
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    return [NSMethodSignature signatureWithObjCTypes:AW_GENERAL_TYPES];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"unrecognized selector (-%@) sent to Master ",NSStringFromSelector(anInvocation.selector));
}
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    return [NSMethodSignature signatureWithObjCTypes:AW_GENERAL_TYPES];
}
+ (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"unrecognized selector (+%@) sent to Master ",NSStringFromSelector(anInvocation.selector));
}
#pragma mark protocol AWMaster

+ (BOOL)reregisterSeletor:(SEL)selector forSlave:(Class)slave previousSlave:(Class)previousSlave
{
    NSLog(@"⚠️ reregister seletor (%@), for slave (%@), previous slave (%@)",NSStringFromSelector(selector),NSStringFromClass(slave),NSStringFromClass(previousSlave));
    return YES;
}

+ (void)masterRespondsSelecotr:(SEL)selector fromSlave:(Class)slave isInstanceMethod:(BOOL)isInstanceMethod
{
    NSLog(@"⛔️ master implemented selecotr (%@), from salve (%@)",NSStringFromSelector(selector),NSStringFromClass(slave));
}

+ (BOOL)willForwardSelector:(SEL)selector toSlave:(Class)slave isInstanceMethod:(BOOL)isInstanceMethod
{
    NSLog(@"✅ will forward selecotr (%@%@) to salve (%@)",isInstanceMethod?@"-":@"+",NSStringFromSelector(selector),NSStringFromClass(slave));
    return YES;
}

+ (void)unregisteredSelector:(SEL)selector isInstanceMethod:(BOOL)isInstanceMethod
{
    NSLog(@"⚠️ sent unregistered selector (%@%@) ",isInstanceMethod?@"-":@"+",NSStringFromSelector(selector));
}

+ (BOOL)isSafeUrlPath:(NSString *)urlPath andIsInstanceMethod:(BOOL *)isInstanceMethod
{
    urlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    *isInstanceMethod = ([[url.host lowercaseString] isEqualToString:@"class"])?NO:YES;
    
    NSString *path = url.path;
    NSCharacterSet *trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *selectorName = [path stringByTrimmingCharactersInSet:trimmingSet];
    
    if (selectorName.length == 0) {
        return NO;
    }
    
    NSMutableCharacterSet *safeCharacterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [safeCharacterSet addCharactersInString:@"_:"];
    
    if ([selectorName rangeOfCharacterFromSet:[safeCharacterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    NSString *noArgSelectroName = [selectorName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    if ([selectorName hasPrefix:@":"]||[noArgSelectroName rangeOfString:@":"].location != NSNotFound) {
        return NO;
    }
    
    return YES;
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
    AW_AnnounceCurrentMethod(application);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application);
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    AW_AnnounceCurrentMethod(application);
}

@end

