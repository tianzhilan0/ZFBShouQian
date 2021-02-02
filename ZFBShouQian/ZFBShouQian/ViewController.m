//
//  ViewController.m
//  ZFBShouQian
//
//  Created by 李闯 on 2021/2/2.
//

#import "ViewController.h"
#import "JPUSHService.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [JPUSHService addTags:[NSSet setWithArray:@[@"10000"]] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        NSLog(@"设置tag");
    } seq:0 ];
}


@end
