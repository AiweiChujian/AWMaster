//
//  MoudleBProtocol.h
//  AWMaster
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#ifndef MoudleBProtocol_h
#define MoudleBProtocol_h

@protocol MoudleBProtocol <NSObject>

@required
+ (void)moudleB_showMessage:(NSString *)message;

+ (void)moudleB_showAlertWithTitle:(NSString *)title message:(NSString *)message  confirmAction:(void (^)(void))confirm;

+ (void)moudleB_showImage:(UIImage *)image;


@optional
- (void)moudleB_showMessage:(NSString *)message;

@property (nonatomic, class, copy, readonly)NSString *moudleB_moudleName;

@end

#endif /* MoudleBProtocol_h */
