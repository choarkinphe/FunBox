//
//  OCViewController.m
//  FunBox_Example
//
//  Created by 肖华 on 2020/8/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "OCViewController.h"
#import <FunBox/FunBox-Swift.h>
#import "FunBox_Example-Swift.h"
@interface OCViewController ()

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
    
    NSDictionary *dict = self.rt_params;
    
    NSLog(@"%@",dict);
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    Router *router = [Service router];
    
    [router openWithUrl:@"funbox://testOC" params:@"哈哈哈" animated:YES completion:^(NSURL * url, NSString * identifier, UIAlertAction * alert, NSString * error) {
        
    }];

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
