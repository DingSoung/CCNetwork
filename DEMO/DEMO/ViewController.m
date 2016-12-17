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
@property (weak, nonatomic) IBOutlet UIImageView *logImage;
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
        
        [Network getWithUrl:self.urlTextFiled.text success:^(NSData *data) {
            weakSelf.logLabel.text = [data jsonStr];
        } fail:^(NSError *error) {
            weakSelf.logLabel.text = error.domain;
        }];
        
        NSDictionary *parameter = @{
            @"username": @"Ding Songwen",
            @"email": @"dingsoung@gmail.com",
            @"age": @26,
            };
        [Network postWithUrl:self.urlTextFiled.text parameter:parameter success:^(NSData *data) {
            NSLog(@"%@", [data jsonStr]);
        } fail:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
        [Network downloadWithUrl:self.urlTextFiled.text success:^(NSData *data) {
            weakSelf.logImage.image = [UIImage imageWithData:data];
        } fail:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
        NSURLSessionDownloadTask *taskDump = [Network downloadWithUrl:self.urlTextFiled.text success:^(NSData *data) {
            weakSelf.logImage.image = [UIImage imageWithData:data];
        } fail:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        [taskDump cancel];
        
        
        
        return NO;
    }
    return YES;
}

@end
