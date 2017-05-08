//
//  HomeViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"

@interface HomeViewController () {
    BOOL btnEnabled;
    BOOL valueEnabled;
    BOOL operatorEnabled;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.vertexNumTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.vertexNumTextField.keyboardType = UIKeyboardTypeNumberPad;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 具体指定数值和运算符

- (IBAction)SpecifyBtnClicked:(UIButton *)sender {
    self.createButton.enabled = NO;
    self.specifyButton.enabled = NO;
    
    UITextField *valueTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, self.specifyButton.frame.origin.y + 33 + 10, self.view.bounds.size.width - 120, 30)];
    valueTextField.font = [UIFont systemFontOfSize:14];
    valueTextField.borderStyle = UITextBorderStyleRoundedRect;
    valueTextField.placeholder = [NSString stringWithFormat:@"输入%@个顶点的值，用空格隔开", self.vertexNumTextField.text];
    valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    valueTextField.tag = 001;
    [self.view addSubview:valueTextField];
    [valueTextField becomeFirstResponder];
    
    UITextField *operatorTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, self.specifyButton.frame.origin.y + 33 + 10 + 30 + 10, self.view.bounds.size.width - 120, 30)];
    operatorTextField.font = [UIFont systemFontOfSize:14];
    operatorTextField.borderStyle = UITextBorderStyleRoundedRect;
    operatorTextField.placeholder = [NSString stringWithFormat:@"输入%@条横线上的操作符，用空格隔开", self.vertexNumTextField.text];
    operatorTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    operatorTextField.tag = 002;
    [self.view addSubview:operatorTextField];
    
    // 设置button
    UIButton *confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(operatorTextField.frame.origin.x + 25, operatorTextField.frame.origin.y + 30 + 10, operatorTextField.frame.size.width / 2 - 40, 30)];
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [confirmButton setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] forState:UIControlStateNormal];
    [confirmButton.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [confirmButton.layer setCornerRadius:4];
    [confirmButton.layer setBorderWidth:0.5];//设置边界的宽度
    [confirmButton.layer setBorderColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    confirmButton.tag = 003;
    confirmButton.enabled = NO;
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    UIButton *cannelButton = [[UIButton alloc]initWithFrame:CGRectMake(confirmButton.frame.origin.x + confirmButton.frame.size.width + 30, confirmButton.frame.origin.y, operatorTextField.frame.size.width / 2 - 40, 30)];
    [cannelButton setTitle:@"取消" forState:UIControlStateNormal];
    cannelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cannelButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    [cannelButton.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [cannelButton.layer setCornerRadius:4];
    [cannelButton.layer setBorderWidth:0.5];//设置边界的宽度
    [cannelButton.layer setBorderColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    cannelButton.tag = 004;
    [cannelButton addTarget:self action:@selector(cannelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cannelButton];

    [valueTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [operatorTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

}


// 确认按钮
- (void)confirmBtnClicked {
    UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
    UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];

    NSString *valueStr = valueTextField.text;
    NSString *operatorStr = operatorTextField.text;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    GameViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gameVC"];
    
    vc.vertexStr = valueStr;
    vc.operatorStr = operatorStr;
    vc.vertexNumStr = self.vertexNumTextField.text;
    
    [self presentViewController:vc animated:YES completion:nil];

}

// 取消按钮
- (void)cannelBtnClicked {
    
    UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
    UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];
    UIButton *confirmButton = (UIButton *)[self.view viewWithTag:003];
    UIButton *cannelButton = (UIButton *)[self.view viewWithTag:004];
    [valueTextField removeFromSuperview];
    [operatorTextField removeFromSuperview];
    [confirmButton removeFromSuperview];
    [cannelButton removeFromSuperview];
    
    self.createButton.enabled = YES;
    self.specifyButton.enabled = YES;

}


#pragma mark - 实时监视输入框

- (void)textFieldDidChange:(UITextField *)textField {

    if (textField == self.vertexNumTextField) {
        // 顶点数范围规定
        if (textField.text.intValue > 15 || textField.text.intValue < 3 || [textField.text isEqualToString:@""]) {
            
            self.createButton.enabled = NO;
            self.specifyButton.enabled = NO;
        } else {
            self.createButton.enabled = YES;
            self.specifyButton.enabled = YES;
        }
        
    } else {

        UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
        UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];
        UIButton *confirmButton = (UIButton *)[self.view viewWithTag:003];
        
        if (textField == valueTextField) {
            int blankCount = [self countBlankWithString:valueTextField.text];
            if (blankCount == [self.vertexNumTextField.text intValue] - 1) {
                valueEnabled = YES;
            } else {
                valueEnabled = NO;
            }
        }
        
        if (textField == operatorTextField) {
            if (textField.text.length == [self.vertexNumTextField.text intValue] * 2 -1) {
                operatorEnabled = YES;
            } else {
                operatorEnabled = NO;
            }
        }
        
        if (valueEnabled && operatorEnabled) {
            btnEnabled = YES;
        } else {
            btnEnabled = NO;
        }
        
        if (btnEnabled) {
            confirmButton.enabled = YES;
            [confirmButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            confirmButton.enabled = NO;
            [confirmButton setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] forState:UIControlStateNormal];
        }
        
    }
    
}

// 返回字符串中空格的个数
- (int)countBlankWithString:(NSString *)string {
    int count = 0;
    for (int i = 0; i < string.length; i++) {
        if ([string characterAtIndex:i] == ' ') {
            count++;
        }
    }
    return count;
}


#pragma mark - Storyboard转场
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if([segue.identifier isEqualToString:@"toGameVC"]) {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:self.vertexNumTextField.text forKey:@"vertexNumStr"];
        self.vertexNumTextField.text = @"";
        self.createButton.enabled = NO;
        self.specifyButton.enabled = NO;
    }
    
}

























@end
