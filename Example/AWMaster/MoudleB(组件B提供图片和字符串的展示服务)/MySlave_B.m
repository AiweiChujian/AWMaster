//
//  MySlave_B.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MySlave_B.h"
#import "MoudleBShowImageVC.h"

@implementation MySlave_B
AWCompleteSingleton(slave)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MyMaster registerSlave:self withProtocol:@protocol(MoudleBProtocol)];
    });
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    NSLog(@"[%@]收到公告(%@)",NSStringFromClass(self.class),NSStringFromSelector(_cmd));
    return YES;
}

+ (void)moudleB_showImage:(UIImage *)image
{
    MoudleBShowImageVC *vc = [[MoudleBShowImageVC alloc]initWithImage:image];
    [MyMaster presentViewController:vc animated:YES completion:nil];
}

+ (void)moudleB_showAlertWithTitle:(NSString *)title message:(NSString *)message  confirmAction:(void (^)(void))confirm
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (confirm) {
            confirm();
        }
    }];
    [vc addAction:action];
    [MyMaster presentViewController:vc animated:YES completion:nil];
}

- (void)moudleB_showMessage:(NSString *)message
{
    [self.class moudleB_showAlertWithTitle:@"Instance Method" message:message confirmAction:nil];
}

+ (void)moudleB_showMessage:(NSString *)message
{
    [self moudleB_showAlertWithTitle:@"Class Method" message:message confirmAction:nil];
}
@end
