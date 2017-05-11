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
@property (weak, nonatomic) IBOutlet UILabel *yourScoreLabel;
@property (nonatomic, strong) NSString *vertexNumStr;
@property (nonatomic, strong) NSString *vertexStr;
@property (nonatomic, strong) NSString *operatorStr;
@property (weak, nonatomic) IBOutlet UIButton *revokeButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
- (IBAction)backBtnClicked:(UIButton *)sender;
- (IBAction)againBtnClicked:(UIButton *)sender;
- (IBAction)revokeBtnClicked:(UIButton *)sender;
- (IBAction)historyBtnClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *highestButton;
- (IBAction)highestBtnClicked:(UIButton *)sender;

@end
