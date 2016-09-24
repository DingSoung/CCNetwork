//
//  ViewController.m
//  DEMO
//
//  Created by Songwen Ding 3/16/16.
//  Copyright © 2016 DingSoung. All rights reserved.
//

#import "ViewController.h"
#import "DEMO-swift.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlTextFiled.keyboardType = UIKeyboardTypeURL;
    self.urlTextFiled.returnKeyType = UIReturnKeySend;
    self.urlTextFiled.delegate = self;
    
    [self textFieldShouldReturn: self.urlTextFiled];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma MARK- <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.urlTextFiled) {
        [textField resignFirstResponder];
        __weak typeof(self) weakSelf = self;
        self.logLabel.text = @"requesting...";
        [CCNetwork getWithUrl:self.urlTextFiled.text parameter:@{} success:^(NSData *data) {
            // serialization request data as json ...
            weakSelf.logLabel.text = [NSString stringWithFormat:@"%@", data];
        } fail:^(NSError *error) {
            weakSelf.logLabel.text = error.domain;
        }];
        
        return NO;
    }
    return YES;
}

@end
