//
//  MockForAWMaster.h
//  AWMaster_Tests
//
//  Created by Aiwei on 2020/4/30.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import <AWMaster/AWMaster.h>
#import <UIKit/UIKit.h>

@protocol MockAnnouncement <NSObject>

@optional

- (NSString *)instanceReplyWithCGRect:(CGFloat)rect;

@required
+ (CGAffineTransform)classReplyTransform;

@end

@protocol MockProtocol_A <NSObject>

@required

@property (nonatomic, class, copy)NSString *moudelName;

- (void)sayHelloMaster;

@optional

@property (nonatomic, copy)NSString *slaveName;

+ (void)sayHelloMaster;

@end

@protocol MockProtocol_B <NSObject>



@end

@interface MockMaster : AWMaster
<
    MockProtocol_A,
    MockProtocol_B,
    MockAnnouncement
>

@end

@interface MockSlave_A : NSObject<MockProtocol_A>

@end

@interface MockSlave_B : NSObject

@end

@interface MockSlave_C : NSObject

@end

