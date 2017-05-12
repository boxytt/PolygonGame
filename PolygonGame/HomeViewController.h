//
//  HomeViewController.h
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController



@property (weak, nonatomic) UIButton *createButton;
@property (weak, nonatomic) UIButton *specifyButton;
@property (weak, nonatomic) UIPickerView *vertexNumPicker;
@property (nonatomic, strong) UILabel *vertexNumLabel;
@property (nonatomic, strong) UIImageView *gameNameImageView;
@property (nonatomic, strong) UIImageView *earthImageView;

@end
