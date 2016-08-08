//
//  ViewController.m
//  DEMO
//
//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.
//

#import "ViewController.h"
#import "DEMO-swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CCNetwork GET:@"http://www.v2ex.com/api/nodes/all.json" parameter:@{} success:^(NSData * data) {
        // serialization request data as json ...
        NSLog(@"%@", data);
    } fail:^(NSError * error) {
        NSLog(@"%@", error.domain);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
