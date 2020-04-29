//
//  MyMaster.h
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/25.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import <AWMaster/AWMaster.h>
#import "AWMaster+Tools.h"
#import "MoudleAProtocol.h"
#import "MoudleBProtocol.h"
#import "MyAnnouncement.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyMaster : AWMaster
<
    MyAnnouncement,
    MoudleAProtocol,
    MoudleBProtocol
>
@end

NS_ASSUME_NONNULL_END
