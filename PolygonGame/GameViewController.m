//
//  GameViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "GameViewController.h"
#import "DrawPolygon.h"

#define pi 3.14159265358979323846
#define radiansToDegrees(x) (180.0 * x / pi)

/* tag的值：
    顶点：101～ 
    线：201～
    操作符：301～
    序号：401～
*/

@interface GameViewController () {
    int vertexNum;
    NSMutableArray *vertexValues; // 顶点数值
    NSMutableArray *operatorValues; // 操作符
    NSMutableArray *vertexPosition; // 顶点位置
    NSMutableArray *allValues; // 顶点数值和操作符
}


@end


@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vertexNum = [self.vertexNumStr intValue];
    
    vertexValues = [[NSMutableArray alloc]init];
    operatorValues = [[NSMutableArray alloc]init];
    vertexPosition = [[NSMutableArray alloc]init];
    allValues = [[NSMutableArray alloc]initWithObjects:@"a",@"b",@"c",@"d",@"e",@"f", nil];
    
    [self createVerAndOpeRandomly];
    [self drawPolygon];
    [self calculateHighestScore];
    
    NSLog(@"before: %@", allValues[1]);
    [allValues removeObjectAtIndex:1];
    NSLog(@"after: %@", allValues[1]);

 
}

#pragma mark - 产生数值和操作符

- (void)createVerAndOpeRandomly {
    // 产生随机数
    for (int i = 0; i < vertexNum; i++) {
        [vertexValues addObject:[NSNumber numberWithInt:[self getRandomNumber:-100 to:100]]];
    }
    
    NSLog(@"%@", vertexValues);
    
    // 随机“+”，“-”，“*”，“／”
    NSArray *operators = [[NSArray alloc]initWithObjects:@"+", @"*", nil];
    for (int i = 0; i < vertexNum; i++) {
        [operatorValues addObject:[operators objectAtIndex:[self getRandomNumber:0 to:1]]];
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
        vertexButton.tag = 101 + i;
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
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, distance, 5)];
        button.tag = 201 + i;
        [button addTarget:self action:@selector(edgeTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(edgeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(edgeTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];

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
        
        float xOfOperatorLabel = (d - 15) / d * x0 + canvasCenter.x;
        float yOfOperatorLabel = (d - 15) / d * y0 + canvasCenter.y;

        float xOfNumLabel = (d + 15) / d * x0 + canvasCenter.x;
        float yOfNumLabel = (d + 15) / d * y0 + canvasCenter.y;
        
       
        UILabel *operatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
        operatorLabel.tag = 301 + i;
        operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
        operatorLabel.text = [NSString stringWithFormat:@"%@", operatorValues[i]];
        [self.contentView addSubview:operatorLabel];
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        numLabel.tag = 401 + i;
        numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
        numLabel.text = [NSString stringWithFormat:@"%d", i+1];
        [self.contentView addSubview:numLabel];

    }
}

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

#pragma mark - 删除线

// 按下横线
- (void)edgeTouchDown:(UIButton *)button {
    long tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];

    button.backgroundColor = [UIColor redColor];
    numLabel.textColor = [UIColor redColor];
    operatorLabel.textColor = [UIColor redColor];
    NSLog(@"touch No.%ld button\n", (long)button.tag);
}

// 按下后在外面抬起，取消删除
- (void)edgeTouchUpOutside:(UIButton *)button {
    long tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];
    
    button.backgroundColor = [UIColor blackColor];
    numLabel.textColor = [UIColor blackColor];
    operatorLabel.textColor = [UIColor blackColor];

}

// 按下后在里面抬起，删除
- (void)edgeTouchUpInside:(UIButton *)button {
    
    // 去掉线
    long tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        NSLog(@"remove No.%ld button\n", (long)button.tag);
        [button removeFromSuperview];
        [numLabel removeFromSuperview];
        [operatorLabel removeFromSuperview];
        
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
