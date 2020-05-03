//
//  AWMasterSpec.m
//  AWMaster
//
//  Created by Aiwei on 2020/4/30.
//  Copyright 2020 hellohezhili@gmail.com. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MyMaster.h"
#import "MySlave_A.h"
#import "MySlave_B.h"
#import "MySlave_C.h"

/** MyAnnouncement<NSObject>
 *  @required
 *  + (CGAffineTransform)classAnnouncementReplyTransform;
 *  + (id)replyForAsk:(NSString *)askString;
 *  @optional
 *  - (void)instanceAnnouncementWithMultiArg:(NSInteger )integer doublePointer:(double *)pointer CGRect:(CGRect)rect object:(NSArray *)array;
**/

/** MoudleAProtocol <NSObject>
 *  @required
 *  + (UIImage *)moudleA_imageWithImageName:(NSString *)imageName;
 *  @property (nonatomic, copy)NSString *moudleA_slaveName;
 *  @optional
 *  - (UIImage *)moudleA_imageWithDomain:(NSString *)domain andSerial:(NSInteger)serial;
**/

/** MoudleBProtocol <NSObject>
 *  @required
 *  + (void)moudleB_showMessage:(NSString *)message;
 *  + (void)moudleB_showAlertWithTitle:(NSString *)title message:(NSString *)message  confirmAction:(void (^)(void))confirm;
 *  + (void)moudleB_showImage:(UIImage *)image;
 *  @optional
 *  - (void)moudleB_showMessage:(NSString *)message;
 *  @property (nonatomic, class, copy, readonly)NSString *moudleB_moudleName;
**/

/** MoudleDProtocol <NSObject>
 *  @optional
 *  + (NSString *)moudleD_summary;
**/

/// 在Slave的+load方法中某些注册已经完成
/// MySlave_A:
/// [MyMaster registerSlave:self withProtocol:@protocol(MoudleAProtocol)];
/// MySlave_B:
/// [MyMaster registerSlave:self withProtocol:@protocol(MoudleBProtocol)];
/// MySlave_C:
/// [MyMaster addAnnouncementReceiver:self];

SPEC_BEGIN(AWMasterSpec)

describe(@"AWMaster", ^{
    
    context(@"正常注册与正常调用的情况", ^{
        it(@"1. Master和Slave_A都是完全单例", ^{
            [[[MyMaster new] should] equal:[[MyMaster alloc]init]];
            [[[MySlave_A new] should] equal:[[MySlave_A alloc]init]];
        });
        
        it(@"2. 调用Slave_A的实例属性和Slave_B的类方法", ^{
            
            // @property (nonatomic, copy)NSString *moudleA_slaveName
            
            KWCaptureSpy *spyA = [[MySlave_A new] captureArgument:@selector(setMoudleA_slaveName:) atIndex:0];
            NSString *slaveA_name = @"slave_A";
            [MyMaster new].moudleA_slaveName = slaveA_name;
            [[spyA.argument should] equal:slaveA_name];
            [[[MyMaster new].moudleA_slaveName should] equal:slaveA_name];
            
            // @property (nonatomic, class, copy, readonly)NSString *moudleB_moudleName;
            NSString *moudleB_name = @"moudle_B";
            [[MySlave_B should] receive:@selector(moudleB_moudleName) andReturn:moudleB_name];
            [[[MyMaster moudleB_moudleName]should] equal:moudleB_name];
            
        });
        
        it(@"3. 远程调用Slave_A的类方法和Slave_B的实例方法", ^{
            
            // + (UIImage *)moudleA_imageWithImageName:(NSString *)imageName;

            NSString *imageName = @"picture";
            [[MySlave_A should] receive:@selector(moudleA_imageWithImageName:) withArguments:imageName];
            KWCaptureSpy *spyImage = [MySlave_A captureArgument:@selector(moudleA_imageWithImageName:) atIndex:0];
            [MyMaster openServiceWithUrlPath:@"kiwi://class/moudleA_imageWithImageName:?picture"];
            [[spyImage.argument should] equal:imageName];
            
            // - (void)moudleB_showMessage:(NSString *)message;
            MySlave_B *slaveB = [MySlave_B new];
            [[slaveB should] receive:@selector(moudleB_showMessage:)];
            KWCaptureSpy *spyB = [slaveB captureArgument:@selector(moudleB_showMessage:) atIndex:0];
            NSString *message = @"hello world";
            [MyMaster openServiceWithUrlPath:@"kiwi://instance/moudleB_showMessage:?hello world"];
            [[spyB.argument should] equal:message];
        });

        it(@"4. 通过Master分发两条通知", ^{
            NSInteger arg1 = 100;
            double p = 10000.0f;
            double *arg2 = &p;
            CGRect arg3 = CGRectMake(100, 100, 1000, 1000);
            NSArray *arg4 = @[@"hello"];
            [[[MySlave_A new] should] receive:@selector(instanceAnnouncementWithMultiArg:doublePointer:CGRect:object:) withArguments:theValue(arg1),theValue(arg2),theValue(arg3),arg4];
            [[MyMaster new]instanceAnnouncementWithMultiArg:arg1 doublePointer:arg2 CGRect:arg3 object:arg4];
            
            [[MySlave_A should] receive:@selector(classAnnouncementReplyTransform)];
            [[MySlave_C should] receive:@selector(classAnnouncementReplyTransform)];
            [MyMaster classAnnouncementReplyTransform];
        });
    });
    
    context(@"异常注册与异常调用的情况", ^{
        beforeEach(^{
            [MyMaster registerSlave:[MySlave_A class] withProtocol:@protocol(MoudleAProtocol)];
            [MyMaster registerSlave:[MySlave_B class] withProtocol:@protocol(MoudleBProtocol)];
            [MyMaster addAnnouncementReceiver:[MySlave_C class]];
        });
        it(@"1. 注册已经注册过的同名方法", ^{
            [[MyMaster should]receive:@selector(reregisterSeletor:forSlave:previousSlave:) andReturn:theValue(YES) withCount:4];
            [MyMaster registerSlave:[MySlave_B class] withProtocol:@protocol(MoudleAProtocol)];
            [[[MyMaster.instanceMethodDictionary objectForKey:NSStringFromSelector(@selector(moudleA_slaveName))] should] equal:[MySlave_B class]];

        });

        it(@"2. 注册Master已经实现的方法", ^{
            [[MyMaster should] receive:@selector(masterRespondsSelecotr:fromSlave:isInstanceMethod:) withCount:9];
            [MyMaster registerSlave:[MySlave_A class] withProtocol:@protocol(AWAPPAnnouncement)];
            [MyMaster registerSlave:[MySlave_A class] withProtocol:@protocol(MyAnnouncement)];
            [[MyMaster.classMethodDictionary.allKeys shouldNot] contain:NSStringFromSelector(@selector(classAnnouncementReplyTransform))];
        });

        pending_(@"3. 调用一个不合法的urlPath", ^{
            [[MyMaster should] receive:@selector(isSafeUrlPath:andIsInstanceMethod:) andReturn:theValue(NO)];
            [[[MySlave_A new] shouldNot]receive:@selector(moudleA_imageWithDomain:andSerial:)];
            [MyMaster openServiceWithUrlPath:@"kiwi://instance/moudleA_imageWithDomain:andSerial:?kiwi&1"];

        });
    });

    context(@"注销服务与注销接收公告的情况", ^{
        
        beforeEach(^{
            [MyMaster registerSlave:[MySlave_A class] withProtocol:@protocol(MoudleAProtocol)];
            [MyMaster registerSlave:[MySlave_B class] withProtocol:@protocol(MoudleBProtocol)];
            [MyMaster addAnnouncementReceiver:[MySlave_C class]];
        });
        it(@"1. 注销服务", ^{
            [MyMaster deregisterProtocol:@protocol(MoudleAProtocol)];
            [[[MySlave_A new] shouldNot]receive:@selector(setMoudleA_slaveName:)];
            [MyMaster new].moudleA_slaveName = @"slaveA";
            
            [MyMaster deregisterProtocol:@protocol(MoudleBProtocol)];
            [[MySlave_B shouldNot]receive:@selector(moudleB_showMessage:)];
            [MyMaster moudleB_showMessage:@"say hello!"];
            
        });
        it(@"2. 注销公告接收", ^{
            [MyMaster removeAnnouncementReceiver:[MySlave_A class]];
            [[MySlave_A shouldNot]receive:@selector(classAnnouncementReplyTransform)];
            [[MySlave_C should]receive:@selector(classAnnouncementReplyTransform)];
            [MyMaster classAnnouncementReplyTransform];

        });
        pending_(@"3. 注销服务与公告接收", ^{
            [MyMaster deregisterProtocol:@protocol(MoudleAProtocol)];
            [MyMaster removeAnnouncementReceiver:[MySlave_A class]];
            [[MySlave_A shouldNot]receive:@selector(moudleA_imageWithImageName:)];
            [[MySlave_A shouldNot]receive:@selector(replyForAsk:)];
            [MyMaster moudleA_imageWithImageName:@"testImage"];
            [MyMaster replyForAsk:@"kiwi ask"];
        });
    });
});

SPEC_END
