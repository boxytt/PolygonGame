//
//  HomeViewController.h
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *vertexNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *specifyButton;

- (IBAction)SpecifyBtnClicked:(UIButton *)sender;
@end
