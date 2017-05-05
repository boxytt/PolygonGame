//
//  HomeViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *vertexNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.vertexNumTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if (textField == self.vertexNumTextField) {
        // 顶点数范围规定
        if (textField.text.intValue > 15 || textField.text.intValue < 3 || [textField.text isEqualToString:@""]) {

            self.startButton.enabled = NO;
        } else {

            self.startButton.enabled = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if([segue.identifier isEqualToString:@"toGameVC"]) {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:self.vertexNumTextField.text forKey:@"vertexNumStr"];
        self.vertexNumTextField.text = @"";
    }           
    
}




@end
