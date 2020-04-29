//
//  MyMaster.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/25.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MyMaster.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation MyMaster

AWCompleteSingleton(myMaster)

+(id)replyForAsk:(NSString *)askString
{
    return AW_AnnounceCurrentMethod(askString);
}


@end

#pragma clang diagnostic pop
