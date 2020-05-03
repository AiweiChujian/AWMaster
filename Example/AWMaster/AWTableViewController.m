//
//  AWTableViewController.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "AWTableViewController.h"
/// 调用服务时, 引入Master即可
#import "MyMaster.h"


@interface AWTableViewController ()

@end

@implementation AWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AWMaster";
    self.tableView.tableFooterView = [UIView new];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 所有的服务调用都通过Master进行
    switch (indexPath.section) {
        case 0:
            [self normalServiceForIndex:indexPath.row];
            break;
            
        case 1:
            [self urlPathServiceForIndex:indexPath.row];
            break;
            
        case 2:
            [self masterPublishAnnouncement];
            break;
    }
}

- (void)normalServiceForIndex:(NSInteger)index
{
    if (index == 3) {
        [MyMaster moudleB_showMessage:@"hello  直接调用时传递的字符串"];
        return;
    }
    UIImage *image = [[MyMaster new] moudleA_imageWithDomain:@"preview" andSerial:index];
    [MyMaster moudleB_showImage:image];
}
- (void)urlPathServiceForIndex:(NSInteger)index
{
    if (index == 0) {
        [MyMaster openServiceWithUrlPath:@"demo://instance/moudleB_showMessage:?hello  UrlPath调用传递的字符串/"];
    }
    else
    {
        UIImage *image = [MyMaster openServiceWithUrlPath:@"demo://class/moudleA_imageWithImageName:?dieqi"];
        [MyMaster moudleB_showImage:image];
    }
}
- (void)masterPublishAnnouncement
{
    NSDictionary *results = [MyMaster replyForAsk:@"hello"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results
    options:NSJSONWritingPrettyPrinted
      error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *message = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    [MyMaster moudleB_showAlertWithTitle:@"收到公告后返回信息" message:message confirmAction:^{
        NSLog(@"confirmAction");
    }];
    
}

@end
