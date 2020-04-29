//
//  AWMaster+Tools.h
//  AWMaster
//
//  Created by Aiwei on 2020/4/26.
//

#import "AWMaster.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#define AW_AnnounceCurrentMethod(...) [object_isClass(self)?self:self.class announceInstanceMethod:(object_isClass(self)?NO:YES) selector:_cmd,__VA_ARGS__];

NS_ASSUME_NONNULL_BEGIN

@interface AWMaster (Tools)

+ (NSDictionary *)announceInstanceMethod:(BOOL)isInstanceMethod selector:(SEL)selector,...;


/// 以下方法copy自CTMediator<https://github.com/casatwy/CTMediator>
+ (UIViewController * _Nullable)topViewController;

+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^ _Nullable )(void))completion;

@end

NS_ASSUME_NONNULL_END
