//
//  MockForAWMaster.m
//  AWMaster_Tests
//
//  Created by Aiwei on 2020/4/30.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MockForAWMaster.h"
#import <AWMaster/AWMaster+Tools.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation MockMaster

@end

#pragma clang diagnostic pop
@implementation MockSlave_A

AWCompleteSingleton(singleton)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MockMaster registerSlave:self withProtocol:@protocol(MockProtocol_A)];
    });
}

+ (NSString *)moudelName
{
    return @"moudleA";
}
@end

@implementation MockSlave_B

@end

@implementation MockSlave_C

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MockMaster addAnnouncementReceiver:self];
    });
}

@end
