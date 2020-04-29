//
//  MySlave_C.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MySlave_C.h"

@implementation MySlave_C
AWCompleteSingleton(slave)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MyMaster addAnnouncementReceiver:self];
    });
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    NSLog(@"[%@]收到公告(%@)",NSStringFromClass(self.class),NSStringFromSelector(_cmd));
    return YES;
}
+ (id)replyForAsk:(NSString *)askString
{
    return [NSString stringWithFormat:@"MoudleC收到Master公告(%@)",askString];
}
@end
