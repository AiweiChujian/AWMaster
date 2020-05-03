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
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
@implementation MyMaster

AWCompleteSingleton(myMaster)

+(id)replyForAsk:(NSString *)askString
{
    return AW_AnnounceCurrentMethod(askString);
}

- (void)instanceAnnouncementWithMultiArg:(NSInteger)integer doublePointer:(double *)pointer CGRect:(CGRect)rect object:(NSArray *)array
{
    AW_AnnounceCurrentMethod(integer,pointer,rect,array);
}
+ (CGAffineTransform)classAnnouncementReplyTransform
{
    NSDictionary *results = AW_AnnounceCurrentMethod(nil);
    NSLog(@"results: %@",results);
    return CGAffineTransformMake(1, 0, 1, 0, 0x111, 0x111);
}


@end

#pragma clang diagnostic pop
