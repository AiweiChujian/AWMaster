//
//  MoudleBShowImageVC.m
//  AWMaster_Example
//
//  Created by Aiwei on 2020/4/29.
//  Copyright © 2020 hellohezhili@gmail.com. All rights reserved.
//

#import "MoudleBShowImageVC.h"

@interface MoudleBShowImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong)UIImage *image;
@end

@implementation MoudleBShowImageVC

- (instancetype)initWithImage:(UIImage *)image
{
    
    if (self == [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _image = image;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = _image;
    
}
- (IBAction)closeAction:(id)sender {
    if ([self.presentingViewController presentedViewController] == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
