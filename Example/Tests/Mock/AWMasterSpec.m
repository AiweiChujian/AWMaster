//
//  AWMasterSpec.m
//  AWMaster
//
//  Created by Aiwei on 2020/4/30.
//  Copyright 2020 hellohezhili@gmail.com. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MockForAWMaster.h"

SPEC_BEGIN(AWMasterSpec)

describe(@"AWMaster", ^{
    context(@"Slave加载并完成注册后, Master和Slave的状态", ^{
        it(@"Slave_A被设计为完全单例", ^{
            [[[MockSlave_A new] should] equal:[[MockSlave_A alloc]init]];
        });
        
        it(@"只有Protocol_A在Slave_A的load中被注册", ^{
            [[[MockMaster instanceMethodDictionary] should] haveCountOf:3];
            [[[MockMaster classMethodDictionary] should] haveCountOf:3];
            [[[MockMaster moudelName] should] equal:@"moudleA"];
        });
        
        it(@"同时Slave_C也将自己注册为了公告接受者", ^{
            
        });
    });
});

SPEC_END
