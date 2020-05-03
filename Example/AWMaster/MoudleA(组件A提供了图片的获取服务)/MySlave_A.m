//
//  MySlave_A.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MySlave_A.h"

@implementation MySlave_A

// 如果需要使用对象方法来提供服务,那么Slave最好是完全单例
AWCompleteSingleton(slave)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MyMaster registerSlave:self withProtocol:@protocol(MoudleAProtocol)];
    });
}

+ (UIImage *)moudleA_imageWithImageName:(NSString *)imageName
{
    return [UIImage imageNamed:imageName];
}

- (UIImage *)moudleA_imageWithDomain:(NSString *)domain andSerial:(NSInteger)serial
{
    NSString *imageName = [NSString stringWithFormat:@"%@_%ld",domain,(long)serial];
    return [self.class moudleA_imageWithImageName:imageName];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    NSLog(@"[%@]收到公告(%@)",NSStringFromClass(self.class),NSStringFromSelector(_cmd));
    return YES;
}
+ (id)replyForAsk:(NSString *)askString
{
    return [NSString stringWithFormat:@"MoudleA收到Master公告(%@)",askString];
}
+ (CGAffineTransform)classAnnouncementReplyTransform;
{
    return CGAffineTransformMake(0, 0, 1, 1, 0xaaa, 0xaaa);
}
- (void)instanceAnnouncementWithMultiArg:(NSInteger)integer doublePointer:(double *)pointer CGRect:(CGRect)rect object:(NSArray *)array
{
    
}

@end

