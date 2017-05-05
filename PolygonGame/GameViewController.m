//
//  GameViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "GameViewController.h"
#import "DrawPolygon.h"

@interface GameViewController () {
    int vertexNum;
    NSMutableArray *vertexValues;
    NSMutableArray *operatorValues;
}


@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vertexNum = [self.vertexNumStr intValue];
    
    vertexValues = [[NSMutableArray alloc]init];
    operatorValues = [[NSMutableArray alloc]init];
    
    [self createVerAndOpeRandomly];
    [self drawPolygon];
    
    [self calculateHighestScore];
 
}

- (void)drawPolygon {
    
    int radiusOfCanvas = 100;
    if (vertexNum >= 10) {
        radiusOfCanvas = radiusOfCanvas + vertexNum * 3;
    }
    
    // 规定圈圈大小
    int radiusOfCircle = 20;
    if (vertexNum >= 10) {
        radiusOfCircle = radiusOfCircle - vertexNum + 10;
    }
    
    for (int i = 0; i < vertexNum; i++) {
        // 顶点的位置
        CGPoint point = CGPointMake(self.contentView.center.x + radiusOfCanvas * cos(2 * M_PI * (i+1) / vertexNum), self.contentView.frame.size.height / 2 + radiusOfCanvas * sin(2 * M_PI * (i+1) / vertexNum));
        
        
        // 创建带有数字的顶点
        UIButton *vertexButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 2 * radiusOfCircle, 2 * radiusOfCircle)];
        vertexButton.center = point;
        [vertexButton setTitle:[NSString stringWithFormat:@"%d", [vertexValues[i] intValue]] forState:UIControlStateNormal];
        [vertexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        vertexButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [vertexButton setBackgroundImage:[UIImage imageNamed:@"圈"] forState:UIControlStateNormal];
        vertexButton.userInteractionEnabled = NO;
        [self.contentView addSubview:vertexButton];
        
    }
    
}


- (void)createVerAndOpeRandomly {
    // 产生随机数
    for (int i = 0; i < vertexNum; i++) {
        [vertexValues addObject:[NSNumber numberWithInt:[self getRandomNumber:-100 to:100]]];
    }
    
    // 随机“+”，“-”，“*”，“／”
    NSArray *operators = [[NSArray alloc]initWithObjects:@"+", @"-", @"*", @"/", nil];
    for (int i = 0; i < vertexNum; i++) {
        [operatorValues addObject:[operators objectAtIndex:[self getRandomNumber:0 to:3]]];
    }
    
    
    
//    UIButton *button = [[[UIButton alloc]initWithFrame:CGRectMake(50, 200, 100, 3)]];
//    button.titleLabel.text = @"";
//    button.backgroundColor = [UIColor blackColor];
//    button.userInteractionEnabled = YES;
//    button.tag = 001;
//    [button addTarget:self action:@selector(edgeTouchDown) forControlEvents:UIControlEventTouchDown];
//    [button addTarget:self action:@selector(edgeTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//    [self.view bringSubviewToFront:button];
}

- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (void)edgeTouchDown {
    UIButton *button = (UIButton *)[self.view viewWithTag:001];
    button.backgroundColor = [UIColor orangeColor];
    
}
- (void)edgeTouchUpInside {
    
    // 去掉线
    UIButton *button = (UIButton *)[self.view viewWithTag:001];
    button.backgroundColor = [UIColor redColor];

    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        [button removeFromSuperview];

    }];
    
}

- (void)calculateHighestScore {
    
    /*
        计算得出最高分
     */
    self.highestScoreButton.titleLabel.text = @"100";
    
    
}




#pragma mark - 按钮实践

- (IBAction)backBtnClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.vertexNumStr = @"";
        
        vertexNum = 0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
