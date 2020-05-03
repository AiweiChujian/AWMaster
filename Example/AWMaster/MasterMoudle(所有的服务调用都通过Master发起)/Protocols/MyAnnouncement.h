//
//  MyAnnouncement.h
//  AWMaster
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#ifndef MyAnnouncement_h
#define MyAnnouncement_h
#import <Foundation/Foundation.h>

@protocol  MyAnnouncement<NSObject>

@required
+ (CGAffineTransform)classAnnouncementReplyTransform;
+ (id)replyForAsk:(NSString *)askString;

@optional
- (void)instanceAnnouncementWithMultiArg:(NSInteger )integer doublePointer:(double *)pointer CGRect:(CGRect)rect object:(NSArray *)array;

@end


#endif /* MyAnnouncement_h */
