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
    NSMutableArray *vertexValues; // 顶点数值
    NSMutableArray *operatorValues; // 操作符
    NSMutableArray *vertexPosition; // 顶点位置
}


@end


@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vertexNum = [self.vertexNumStr intValue];
    
    vertexValues = [[NSMutableArray alloc]init];
    operatorValues = [[NSMutableArray alloc]init];
    vertexPosition = [[NSMutableArray alloc]init];
    
    [self createVerAndOpeRandomly];
    [self drawPolygon];
    
    [self calculateHighestScore];
 
}

#pragma mark - 产生数值和操作符

- (void)createVerAndOpeRandomly {
    // 产生随机数
    for (int i = 0; i < vertexNum; i++) {
        [vertexValues addObject:[NSNumber numberWithInt:[self getRandomNumber:-100 to:100]]];
    }
    
    NSLog(@"%@", vertexValues);
    
    // 随机“+”，“-”，“*”，“／”
    NSArray *operators = [[NSArray alloc]initWithObjects:@"+", @"-", @"*", @"/", nil];
    for (int i = 0; i < vertexNum; i++) {
        [operatorValues addObject:[operators objectAtIndex:[self getRandomNumber:0 to:3]]];
    }
    NSLog(@"%@", operatorValues);
    
}

- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}


#pragma mark - 绘图

- (void)drawPolygon {
    
    // 整体大小
    int radiusOfCanvas = 100;
    if (vertexNum >= 10) {
        radiusOfCanvas = radiusOfCanvas + vertexNum * 3;
    }
    
    // 规定圈圈大小
    int radiusOfCircle = 20;
    if (vertexNum >= 10) {
        radiusOfCircle = radiusOfCircle - vertexNum + 10;
    }
    
    // 画顶点
    for (int i = 0; i < vertexNum; i++) {
        // 顶点的位置
        CGPoint point = CGPointMake(self.contentView.center.x + radiusOfCanvas * cos(2 * M_PI * (i+1) / vertexNum), self.contentView.frame.size.height / 2 + radiusOfCanvas * sin(2 * M_PI * (i+1) / vertexNum));
        
        // 保存顶点
        [vertexPosition addObject:NSStringFromCGPoint(point)];
        
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
    
    // 画线和序号和操作符
    for (int i = 0; i < vertexNum; i++) {
        
        int j = (i != vertexNum-1 ? i + 1 : 0);
        // 画连线
        float rads = [self angleForStartPoint:CGPointFromString(vertexPosition[i]) EndPoint:CGPointFromString(vertexPosition[j])];
        float distance = [self distanceBetweenPiontA:CGPointFromString(vertexPosition[i]) andPointB:CGPointFromString(vertexPosition[j])] - 2 * radiusOfCircle;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, distance, 3)];
        button.backgroundColor = [UIColor blackColor];
        // 旋转
        button.transform = CGAffineTransformMakeRotation(rads);
        // 移动
        button.center = CGPointMake((CGPointFromString(vertexPosition[i]).x + CGPointFromString(vertexPosition[j]).x) / 2, (CGPointFromString(vertexPosition[i]).y + CGPointFromString(vertexPosition[j]).y) / 2);
        [self.contentView addSubview:button];
 
        // 计算序号和操作符的位置
        CGPoint canvasCenter = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height / 2);
        CGPoint buttonCenter = button.center;

        float d = [self distanceBetweenPiontA:canvasCenter andPointB:buttonCenter];
        float r = [self angleForStartPoint:canvasCenter EndPoint:buttonCenter];

        float x0 = d * cos(r);
        float y0 = d * sin(fabsf(r));
        if (r < 0) {
            y0 = -y0;
        }

        float xOfNumLabel = (d + 15) / d * x0 + canvasCenter.x;
        float yOfNumLabel = (d + 15) / d * y0 + canvasCenter.y;
        
        float xOfOperatorLabel = (d - 15) / d * x0 + canvasCenter.x;
        float yOfOperatorLabel = (d - 15) / d * y0 + canvasCenter.y;


        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
        numLabel.text = [NSString stringWithFormat:@"%d", i+1];
        [self.contentView addSubview:numLabel];

        UILabel *operatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
        operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
        operatorLabel.text = [NSString stringWithFormat:@"%@", operatorValues[i]];
        [self.contentView addSubview:operatorLabel];

    }
    
}

#define pi 3.14159265358979323846
#define radiansToDegrees(x) (180.0 * x / pi)

// 两点之间的弧度
-(CGFloat)angleForStartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint{
    
    CGPoint Xpoint = CGPointMake(startPoint.x + 100, startPoint.y);
    
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    CGFloat c = Xpoint.x - startPoint.x;
    CGFloat d = Xpoint.y - startPoint.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    if (startPoint.y>endPoint.y) {
        rads = -rads;
    }
    return rads;
}

// 两点之间的距离
- (CGFloat)distanceBetweenPiontA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    CGFloat deltaX = pointB.x - pointA.x;
    CGFloat deltaY = pointB.y - pointA.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
};


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

#pragma mark - 动态规划计算最高分

- (void)calculateHighestScore {
    
    /*
        计算得出最高分
     */
    self.highestScoreButton.titleLabel.text = @"100";
    
    
}




#pragma mark - 按钮事件

// 返回主页
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
