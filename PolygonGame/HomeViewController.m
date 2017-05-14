//
//  HomeViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"

/*
 tag
 001: valueTextField
 002: operatorTextField
 003: confirmButton
 004: cannelButton
 005: createButton
 006: specifyButton
 */

@interface HomeViewController ()<UIPickerViewDelegate, UIPickerViewDataSource> {
    BOOL btnEnabled;
    BOOL valueEnabled;
    BOOL operatorEnabled;
    NSArray *vertexNumArray;
    NSString *vertexNumStr;
    CGFloat angle;
    BOOL isFirstOpen;
}


@property (nonatomic, strong) IQKeyboardReturnKeyHandler *returnKeyHandler;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    IQKeyboardReturnKeyHandler *retuenKeyHandler = [[IQKeyboardReturnKeyHandler alloc]initWithViewController:self];
    retuenKeyHandler.lastTextFieldReturnKeyType =UIReturnKeyDone;
    
    vertexNumArray = [[NSArray alloc]initWithObjects:@"n",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",nil];
    
    // 顶点数Label
    UILabel *vertexNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.width + self.view.bounds.size.width/2 - 100, self.view.bounds.size.height/2 - 15, 80, 30)];
    vertexNumLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    vertexNumLabel.backgroundColor = [UIColor orangeColor];
    vertexNumLabel.textColor = [UIColor whiteColor];
    vertexNumLabel.text = @"顶点数";
    vertexNumLabel.textAlignment = NSTextAlignmentCenter;
    vertexNumLabel.layer.cornerRadius = 4;
    vertexNumLabel.clipsToBounds = YES;
    self.vertexNumLabel = vertexNumLabel;
    [self.view addSubview:vertexNumLabel];
    
    // 顶点pickerView
    UIPickerView *vertexNumPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width + self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 55 / 2, 60, 55)];
    vertexNumPicker.dataSource = self;
    vertexNumPicker.delegate = self;
    self.vertexNumPicker = vertexNumPicker;
    [self.view addSubview:vertexNumPicker];
    
    // 随机产生button
    UIButton *createButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width + self.view.bounds.size.width / 2 - 45, vertexNumPicker.frame.origin.y + vertexNumPicker.frame.size.height + 10, 90, 35)];
    [createButton setTitle:@"随机产生" forState:UIControlStateNormal];
    createButton.backgroundColor = [UIColor blueColor];
    createButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    createButton.layer.cornerRadius = 4;
    createButton.clipsToBounds = YES;
    createButton.enabled = NO;
    createButton.tag = 005;
    [createButton addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.createButton = createButton;
    [self.view addSubview:createButton];
    
    // 具体指定button
    UIButton *specifyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width + self.view.bounds.size.width / 2 - 45, createButton.frame.origin.y + createButton.frame.size.height + 10, 90, 35)];
    [specifyButton setTitle:@"具体指定" forState:UIControlStateNormal];
    specifyButton.backgroundColor = [UIColor purpleColor];
    specifyButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    [specifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [specifyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    specifyButton.layer.cornerRadius = 4;
    specifyButton.clipsToBounds = YES;
    specifyButton.enabled = NO;
    specifyButton.tag = 006;
    [specifyButton addTarget:self action:@selector(SpecifyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.specifyButton = specifyButton;
    [self.view addSubview:specifyButton];

    // 游戏名UIImageView
    UIImageView *gameNameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width + self.view.bounds.size.width / 2 - 210/2, vertexNumLabel.frame.origin.y - 20 - 50, 210, 50)];
    gameNameImageView.image = [UIImage imageNamed:@"多边形游戏"];
    self.gameNameImageView = gameNameImageView;
    [self.view addSubview:gameNameImageView];
    // 三个点
    UIImageView *point1 = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 105 + 40, -20, 10, 10)];
    point1.image = [UIImage imageNamed:@"point"];
    point1.tag = 101;
    [self.view addSubview:point1];
    
    UIImageView *point2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 105 + 140, -20, 10, 10)];
    point2.image = [UIImage imageNamed:@"point"];
    point2.tag = 102;
    [self.view addSubview:point2];
    
    UIImageView *point3 = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 105 + 200, -20, 10, 10)];
    point3.image = [UIImage imageNamed:@"point"];
    point3.tag = 103;
    [self.view addSubview:point3];
    
    isFirstOpen = YES;
    // 旋转地球
    UIImageView *earthImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2, self.gameNameImageView.frame.origin.y - 20 - 150/2, 0.1, 0.1)];
    earthImageView.image = [UIImage imageNamed:@"homeImage"];
    self.earthImageView = earthImageView;
    [self.view addSubview:earthImageView];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (isFirstOpen) {
        // 游戏名UIImageView
        [UIView animateWithDuration:1 delay:0.5 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.gameNameImageView.frame = CGRectMake(self.view.bounds.size.width / 2 - 210/2, self.vertexNumLabel.frame.origin.y - 20 - 50, 210, 50);
            
        } completion:^(BOOL finished) {
            
        }];
        
        // 三个点
        UIImageView *point1 = (UIImageView *)[self.view viewWithTag:101];
        UIImageView *point2 = (UIImageView *)[self.view viewWithTag:102];
        UIImageView *point3 = (UIImageView *)[self.view viewWithTag:103];
        [UIView animateWithDuration:0.7 delay:1.3 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            point1.frame = CGRectMake(self.gameNameImageView.frame.origin.x + 40, self.gameNameImageView.frame.origin.y + 5, 10, 10);
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.7 delay:1 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            point2.frame = CGRectMake(self.gameNameImageView.frame.origin.x + 140, self.gameNameImageView.frame.origin.y + 5, 10, 10);
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.7 delay:1.1 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            point3.frame = CGRectMake(self.gameNameImageView.frame.origin.x + 200, self.gameNameImageView.frame.origin.y + 5, 10, 10);
        } completion:^(BOOL finished) {
            
        }];
        
        // 地球自转
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.earthImageView.transform = CGAffineTransformMakeScale(1500, 1500);
        } completion:^(BOOL finished) {
            // 慢慢自转
            [self spin];
            
        }];
        
        [UIView animateWithDuration:0.5 delay:0.6 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.vertexNumLabel.frame = CGRectMake(self.view.bounds.size.width/2 - 90, self.view.bounds.size.height/2 - 15, 80, 30);
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.7 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.vertexNumPicker.frame = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 55 / 2, 60, 55);
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.8 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.createButton.frame = CGRectMake(self.view.bounds.size.width / 2 - 45, self.vertexNumPicker.frame.origin.y + self.vertexNumPicker.frame.size.height + 10, 90, 35);
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.9 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.specifyButton.frame = CGRectMake(self.view.bounds.size.width / 2 - 45, self.createButton.frame.origin.y + self.createButton.frame.size.height + 10, 90, 35);
        } completion:nil];

    }
    
    isFirstOpen = NO;
    
    UIImageView *cloudImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(-88, self.earthImageView.frame.origin.y, 88, 88)];
    cloudImageView1.image = [UIImage imageNamed:@"cloud1"];
    [self.view addSubview:cloudImageView1];
    UIImageView *cloudImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width + 100, self.earthImageView.frame.origin.y + 30, 100, 100)];
    cloudImageView2.image = [UIImage imageNamed:@"cloud2"];
    [self.view addSubview:cloudImageView2];
    
    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveLinear animations:^{
        cloudImageView1.frame = CGRectMake(self.view.frame.size.width + 88, self.earthImageView.frame.origin.y, 88, 88);
        cloudImageView2.frame = CGRectMake(-100, self.earthImageView.frame.origin.y + 30, 100, 100);
    } completion:nil];

    
}

- (void)spin {
    // 不停旋转
    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.earthImageView.transform = CGAffineTransformRotate(self.earthImageView.transform, M_PI);
    } completion:^(BOOL finished) {
        [self spin];
    }];
}



#pragma Mark -- UIPickerViewDataSource & datagete
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [vertexNumArray count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews) {
        if (singleLine.frame.size.height < 1) {
            singleLine.backgroundColor = [UIColor orangeColor];
        }
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    [label setText:[vertexNumArray objectAtIndex:row]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    [label setTextAlignment:NSTextAlignmentCenter];
        return label;
}


//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [vertexNumArray objectAtIndex:row];
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    vertexNumStr = [vertexNumArray objectAtIndex:row];
    
    if ([vertexNumStr isEqualToString:@"n"]) {
        self.createButton.enabled = NO;
        self.specifyButton.enabled = NO;
    } else {
        self.createButton.enabled = YES;
        self.specifyButton.enabled = YES;
    }
    
}



#pragma mark - 按钮事件

- (void)createBtnClicked {
    
    UIView *buttonView = (UIView *)[self.view viewWithTag:005];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];


    GameViewController *gameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gameVC"];
    gameVC.vertexNumStr = vertexNumStr;
    
    [self.vertexNumPicker selectRow:0 inComponent:0 animated:NO];
    self.createButton.enabled = NO;
    self.specifyButton.enabled = NO;

    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    [self presentViewController:gameVC animated:YES completion:nil];
    
}

- (void)SpecifyBtnClicked {
    
    UIView *buttonView = (UIView *)[self.view viewWithTag:006];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    self.createButton.enabled = NO;
    self.specifyButton.enabled = NO;
    self.vertexNumPicker.userInteractionEnabled = NO;
    UITextField *valueTextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.bounds.size.width, self.specifyButton.frame.origin.y + 33 + 10, self.view.bounds.size.width - 120, 30)];
    valueTextField.font = [UIFont systemFontOfSize:14];
    if (self.view.bounds.size.width == 320) {
        valueTextField.font = [UIFont systemFontOfSize:13];
    }
    [valueTextField setBackground:[UIImage imageNamed:@"textField"]];
    valueTextField.placeholder = [NSString stringWithFormat:@"输入%@个顶点的值，用空格隔开", vertexNumStr];
    valueTextField.textColor = [UIColor whiteColor];
    valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    valueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    valueTextField.inputAccessoryView = [[UIView alloc] init];
    valueTextField.tag = 001;
    [self.view addSubview:valueTextField];
    [valueTextField becomeFirstResponder];
    
    UITextField *operatorTextField = [[UITextField alloc]initWithFrame:CGRectMake(self.view.bounds.size.width, self.specifyButton.frame.origin.y + 33 + 10 + 30 + 5, self.view.bounds.size.width - 120, 30)];
    operatorTextField.font = [UIFont systemFontOfSize:14];
    if (self.view.bounds.size.width == 320) {
        operatorTextField.font = [UIFont systemFontOfSize:13];
    }
    [operatorTextField setBackground:[UIImage imageNamed:@"textField"]];
    operatorTextField.placeholder = [NSString stringWithFormat:@"输入%@个操作符，用空格隔开", vertexNumStr];
    operatorTextField.textColor = [UIColor whiteColor];
    operatorTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    operatorTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    operatorTextField.inputAccessoryView = [[UIView alloc] init];
    operatorTextField.tag = 002;
    [self.view addSubview:operatorTextField];

    // 设置button
    UIButton *confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width, operatorTextField.frame.origin.y + 30 + 10, operatorTextField.frame.size.width / 2 - 40, 30)];
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    confirmButton.backgroundColor = [UIColor greenColor];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    confirmButton.layer.cornerRadius = 4;
    confirmButton.clipsToBounds = YES;
    confirmButton.tag = 003;
    confirmButton.enabled = NO;
    [confirmButton addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    UIButton *cannelButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width, confirmButton.frame.origin.y, operatorTextField.frame.size.width / 2 - 40, 30)];
    [cannelButton setTitle:@"取消" forState:UIControlStateNormal];
    cannelButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:20];
    cannelButton.backgroundColor = [UIColor redColor];
    [cannelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cannelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    cannelButton.layer.cornerRadius = 4;
    cannelButton.clipsToBounds = YES;
    cannelButton.tag = 004;
    [cannelButton addTarget:self action:@selector(cannelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cannelButton];

    [valueTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [operatorTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        valueTextField.frame = CGRectMake(60, self.specifyButton.frame.origin.y + 33 + 10, self.view.bounds.size.width - 120, 30);
    } completion:^(BOOL finished) {
        [valueTextField becomeFirstResponder];
    }];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        operatorTextField.frame = CGRectMake(60, self.specifyButton.frame.origin.y + 33 + 10 + 30 + 10, self.view.bounds.size.width - 120, 30);
    } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.5 delay:0.6 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        confirmButton.frame = CGRectMake(operatorTextField.frame.origin.x + 25, operatorTextField.frame.origin.y + 30 + 10, operatorTextField.frame.size.width / 2 - 40, 30);
    } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.5 delay:0.7 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        cannelButton.frame = CGRectMake(confirmButton.frame.origin.x + confirmButton.frame.size.width + 30, confirmButton.frame.origin.y, operatorTextField.frame.size.width / 2 - 40, 30);
    } completion:^(BOOL finished) {
    }];
    
}


// 确认按钮
- (void)confirmBtnClicked {
    UIView *buttonView = (UIView *)[self.view viewWithTag:003];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
    UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];

    NSString *valueStr = valueTextField.text;
    NSString *operatorStr = operatorTextField.text;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    GameViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gameVC"];
    vc.vertexStr = valueStr;
    vc.operatorStr = operatorStr;
    vc.vertexNumStr = vertexNumStr;
    
    [self removeTextField];
    [self.vertexNumPicker selectRow:0 inComponent:0 animated:NO];
    self.createButton.enabled = NO;
    self.specifyButton.enabled = NO;
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    [self presentViewController:vc animated:YES completion:nil];

}

// 取消按钮
- (void)cannelBtnClicked {
    UIView *buttonView = (UIView *)[self.view viewWithTag:004];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    [self removeTextField];
}

- (void)removeTextField {
    
    UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
    UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];
    UIButton *confirmButton = (UIButton *)[self.view viewWithTag:003];
    UIButton *cannelButton = (UIButton *)[self.view viewWithTag:004];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        valueTextField.frame = CGRectMake(-self.view.bounds.size.width - 120, self.specifyButton.frame.origin.y + 33 + 10, self.view.bounds.size.width - 120, 30);
    } completion:^(BOOL finished) {
        [valueTextField removeFromSuperview];
    }];
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        operatorTextField.frame = CGRectMake(-self.view.bounds.size.width - 120, self.specifyButton.frame.origin.y + 33 + 10 + 30 + 10, self.view.bounds.size.width - 120, 30);
    } completion:^(BOOL finished) {
        [operatorTextField removeFromSuperview];
        
    }];
    [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        confirmButton.frame = CGRectMake(-operatorTextField.frame.size.width / 2 - 40, operatorTextField.frame.origin.y + 30 + 10, operatorTextField.frame.size.width / 2 - 40, 30);
    } completion:^(BOOL finished) {
        [confirmButton removeFromSuperview];
        
    }];
    [UIView animateWithDuration:0.5 delay:0.3 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        cannelButton.frame = CGRectMake(-operatorTextField.frame.size.width / 2 - 40, confirmButton.frame.origin.y, operatorTextField.frame.size.width / 2 - 40, 30);
    } completion:^(BOOL finished) {
        [cannelButton removeFromSuperview];
    }];
    
    
    self.createButton.enabled = YES;
    self.specifyButton.enabled = YES;
    self.vertexNumPicker.userInteractionEnabled = YES;

}


#pragma mark - 实时监视输入框

- (void)textFieldDidChange:(UITextField *)textField {

        UITextField *valueTextField = (UITextField *)[self.view viewWithTag:001];
        UITextField *operatorTextField = (UITextField *)[self.view viewWithTag:002];
        UIButton *confirmButton = (UIButton *)[self.view viewWithTag:003];
        
        if (textField == valueTextField) {
            int blankCount = [self countBlankWithString:valueTextField.text];
            if (blankCount == [vertexNumStr intValue] - 1) {
                valueEnabled = YES;
            } else {
                valueEnabled = NO;
            }
        }
        
        if (textField == operatorTextField) {
            if (textField.text.length == [vertexNumStr intValue] * 2 -1) {
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
        } else {
            confirmButton.enabled = NO;
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
