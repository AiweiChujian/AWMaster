//
//  MySlave_A.h
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MyMaster.h"

NS_ASSUME_NONNULL_BEGIN

@interface MySlave_A : NSObject<MoudleAProtocol,AWAPPAnnouncement,MyAnnouncement>

@property (nonatomic, copy)NSString *moudleA_slaveName;

@end

NS_ASSUME_NONNULL_END
