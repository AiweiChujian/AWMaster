//
//  MyMaster.h
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/25.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import <AWMaster/AWMaster.h>
#import "MoudleAProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyMaster : AWMaster
<
    MoudleAProtocol,
    ABCAnnouncement
>
@end

NS_ASSUME_NONNULL_END
