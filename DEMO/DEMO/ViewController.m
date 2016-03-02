//
//  ViewController.m
//  DEMO
//
//  Created by Alex D. on 3/2/16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "ViewController.h"
#import "DEMO-swift.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [CCNetwork GET:@"http://www.v2ex.com/api/nodes/all.json" parameter:@{} success:^(NSData * data) {
        // serialization request data as json ...
    } fail:^(NSError * error) {
        NSLog(@"%@", error.domain);
    }];

}

@end
