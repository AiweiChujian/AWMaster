//
//  MoudleAProtocol.h
//  AWMaster
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#ifndef MoudleAProtocol_h
#define MoudleAProtocol_h


@protocol MoudleAProtocol <NSObject>

@required
+ (UIImage *)moudleA_imageWithImageName:(NSString *)imageName;
@property (nonatomic, copy)NSString *moudleA_slaveName;

@optional
- (UIImage *)moudleA_imageWithDomain:(NSString *)domain andSerial:(NSInteger)serial;

@end


#endif /* MoudleAProtocol_h */
