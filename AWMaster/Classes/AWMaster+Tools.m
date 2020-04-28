//
//  AWMaster+Tools.m
//  AWMaster
//
//  Created by Aiwei on 2020/4/26.
//

#import "AWMaster+Tools.h"

@implementation AWMaster (Tools)

+ (NSDictionary *)announceInstanceMethod:(BOOL)isInstanceMethod selector:(SEL)selector,...
{
    NSMethodSignature *methodSignature = nil;
    if (isInstanceMethod) {
        methodSignature = [self instanceMethodSignatureForSelector:selector];
    }
    else
    {
        methodSignature = [self methodSignatureForSelector:selector];
    }
    va_list argList;
    va_start(argList, selector);
    NSArray *classArray = [self receiverArray];
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    for (Class cls in classArray) {
        id target = nil;
        if (isInstanceMethod && [cls instancesRespondToSelector:selector]) {
            target = [cls new];
        }
        else if (!isInstanceMethod && [cls respondsToSelector:selector])
        {
            target = cls;
        }
        else
        {
            continue;
        }
        va_list copyList;
        va_copy(copyList, argList);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:target];
        [invocation setSelector:selector];
        id result = [self p_announceInvocation:invocation withArgList:copyList];
        resultDic[NSStringFromClass(cls)] = result;
        va_end(copyList);
    }
    va_end(argList);
    return resultDic;
}
+ (id)p_announceInvocation:(NSInvocation *)anInvocation withArgList:(va_list)argList
{
    NSMethodSignature *methodSignature = anInvocation.methodSignature;
    for (int i = 2; i<methodSignature.numberOfArguments; i++) {
        const char *argType = [methodSignature getArgumentTypeAtIndex:i];
        
        if (strncmp(argType,"{", 1) == 0) {
            NSCharacterSet *trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
            NSString *typeString = [[NSString stringWithUTF8String:argType] stringByTrimmingCharactersInSet:trimmingSet];
            if (typeString.length == 0) {
                continue;
            }
#define AW_SET_STRUCT_CASE(_type) \
            else if ([typeString hasPrefix:@#_type]) {\
                _type temp = va_arg(argList, _type);\
                [anInvocation setArgument:&temp atIndex:i];\
            }
            AW_SET_STRUCT_CASE(CGRect)
            AW_SET_STRUCT_CASE(CGSize)
            AW_SET_STRUCT_CASE(CGPoint)
            AW_SET_STRUCT_CASE(CGVector)
            AW_SET_STRUCT_CASE(CGAffineTransform)
            AW_SET_STRUCT_CASE(UIEdgeInsets)
            AW_SET_STRUCT_CASE(UIOffset)
            
        }
#define AW_SET_ARG_CASE(_type) \
        else if (strcmp(argType, @encode(_type)) == 0) {\
            _type temp = va_arg(argList, _type);\
            [anInvocation setArgument:&temp atIndex:i];\
        }
        
#define AW_SET_ARG_CASE_AND_P(_type) \
        else if (strcmp(argType, @encode(_type)) == 0) {\
            _type temp = va_arg(argList, _type);\
            [anInvocation setArgument:&temp atIndex:i];\
        }\
        else if (strcmp(argType, @encode(_type *)) == 0) {\
            _type* temp = va_arg(argList, _type*);\
            [anInvocation setArgument:&temp atIndex:i];\
        }
#define AW_SET_ARG_CASE_INT(_type) \
        else if (strcmp(argType, @encode(_type)) == 0) {\
            _type temp = va_arg(argList, int);\
            [anInvocation setArgument:&temp atIndex:i];\
        }\
        else if (strcmp(argType, @encode(_type *)) == 0) {\
            _type* temp = va_arg(argList, _type*);\
            [anInvocation setArgument:&temp atIndex:i];\
        }
        
#define AW_SET_ARG_CASE_DOUBLE(_type) \
        else if (strcmp(argType, @encode(_type)) == 0) {\
            _type temp = va_arg(argList, double);\
            [anInvocation setArgument:&temp atIndex:i];\
        }\
        else if (strcmp(argType, @encode(_type *)) == 0) {\
            _type* temp = va_arg(argList, _type*);\
            [anInvocation setArgument:&temp atIndex:i];\
        }
        
        AW_SET_ARG_CASE_INT(char)
        AW_SET_ARG_CASE_AND_P(int)
        AW_SET_ARG_CASE_INT(short)
        AW_SET_ARG_CASE_AND_P(long)
        AW_SET_ARG_CASE_AND_P(long long)
        AW_SET_ARG_CASE_AND_P(unsigned int)
        AW_SET_ARG_CASE_INT(unsigned short)
        AW_SET_ARG_CASE_AND_P(unsigned long)
        AW_SET_ARG_CASE_AND_P(unsigned long long)
        AW_SET_ARG_CASE_DOUBLE(float)
        AW_SET_ARG_CASE_DOUBLE(double)
        AW_SET_ARG_CASE_INT(BOOL)
        AW_SET_ARG_CASE(Class)
        AW_SET_ARG_CASE(SEL)
        AW_SET_ARG_CASE(id)

    }
    
    [anInvocation invoke];
    
    const char *returnType = [methodSignature methodReturnType];
    if (strcmp(returnType, @encode(void)) == 0) {
        return nil;
    }
    else if (strcmp(returnType, @encode(id)) == 0||(strcmp(returnType, @encode(Class)) == 0)) {
        void *result;
        [anInvocation getReturnValue:&result];
        if (result == NULL) {
            return nil;
        }
        id returnValue;
        BOOL isClassMethod = object_isClass(anInvocation.target) ;
        NSString *selName = NSStringFromSelector(anInvocation.selector);
        if (isClassMethod &&([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] || [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"])) {
            returnValue = (__bridge_transfer id)result;
        }else{
            returnValue = (__bridge id)result;
        }
        return returnValue;
    }
    else if (strncmp(returnType,"{", 1) == 0)
        {
            NSCharacterSet *trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
            NSString *typeString = [[NSString stringWithUTF8String:returnType] stringByTrimmingCharactersInSet:trimmingSet];
            if (typeString.length == 0) {
                return nil;
            }
    #define AW_GET_STRUCT_CASE(_type, _methodName) \
            else if ([typeString hasPrefix:@#_type]) {\
                _type result;\
                [anInvocation getReturnValue:&result];\
                return [NSValue _methodName:result];\
            }
            AW_GET_STRUCT_CASE(CGRect, valueWithCGRect)
            AW_GET_STRUCT_CASE(CGSize, valueWithCGSize)
            AW_GET_STRUCT_CASE(CGPoint, valueWithCGPoint)
            AW_GET_STRUCT_CASE(CGVector, valueWithCGVector)
            AW_GET_STRUCT_CASE(CGAffineTransform, valueWithCGAffineTransform)
            AW_GET_STRUCT_CASE(UIEdgeInsets, valueWithUIEdgeInsets)
            AW_GET_STRUCT_CASE(UIOffset, valueWithUIOffset)
        }
    
#define AW_GET_RETURN_CASE(_type) \
    else if (strcmp(returnType, @encode(_type)) == 0) {\
        _type result;\
        [anInvocation getReturnValue:&result];\
        return @(result);\
    }\
    else if (strcmp(returnType, @encode(_type *)) == 0) {\
        _type *result = NULL;\
        [anInvocation getReturnValue:&result];\
        return @(*result);\
    }
    AW_GET_RETURN_CASE(int)
    AW_GET_RETURN_CASE(short)
    AW_GET_RETURN_CASE(long)
    AW_GET_RETURN_CASE(long long)
    AW_GET_RETURN_CASE(unsigned int)
    AW_GET_RETURN_CASE(unsigned short)
    AW_GET_RETURN_CASE(unsigned long)
    AW_GET_RETURN_CASE(unsigned long long)
    AW_GET_RETURN_CASE(float)
    AW_GET_RETURN_CASE(double)
    AW_GET_RETURN_CASE(BOOL)
    else if (strcmp(returnType, @encode(SEL)) == 0){
        SEL result;
        [anInvocation getReturnValue:&result];
        return [NSString stringWithUTF8String:sel_getName(result)];
    }
    else if (strcmp(returnType, @encode(char)) == 0){
        char result;
        [anInvocation getReturnValue:&result];
        return [NSString stringWithUTF8String:&result];
    }
    else if (strcmp(returnType, @encode(char *)) == 0){
        char* result;
        [anInvocation getReturnValue:&result];
        return [NSString stringWithUTF8String:result];
    }
    return nil;
}

+ (UIViewController *)topViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UINavigationController *navigationController = (UINavigationController *)[self topViewController];
    
    if ([navigationController isKindOfClass:[UINavigationController class]] == NO) {
        if ([navigationController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabbarController = (UITabBarController *)navigationController;
            navigationController = tabbarController.selectedViewController;
            if ([navigationController isKindOfClass:[UINavigationController class]] == NO) {
                navigationController = tabbarController.selectedViewController.navigationController;
            }
        } else {
            navigationController = navigationController.navigationController;
        }
    }
    
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        [navigationController pushViewController:viewController animated:animated];
    }
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion
{
    UIViewController *viewController = [self topViewController];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        viewController = navigationController.topViewController;
    }
    
    if (viewController) {
        [viewController presentViewController:viewControllerToPresent animated:animated completion:completion];
    }
}

@end
