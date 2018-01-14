//
//  ViewController.m
//  国际化和手机权限
//
//  Created by 雨停 on 2018/1/14.
//  Copyright © 2018年 yuting. All rights reserved.
//

#import "ViewController.h"
static NSString *appLanguage = @"appLanguage";
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changeLanguage:(UIButton *)sender {
    
    switch (sender.tag) {
        case 101: {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:appLanguage];
        }
            break;
        case 102: {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hant" forKey:appLanguage];
        }
            break;
        case 103: {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:appLanguage];
        }
            break;
        default:
            break;
    }
    
}

@end
