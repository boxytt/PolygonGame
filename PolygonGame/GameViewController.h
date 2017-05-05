//
//  GameViewController.h
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *highestScoreButton;
@property (nonatomic, strong) NSString *vertexNumStr;
- (IBAction)backBtnClicked:(UIButton *)sender;

@end
