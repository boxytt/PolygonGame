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

    BOOL isFirstStep;
    long firstStepRmEdge;
}


@end


@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vertexNum = [self.vertexNumStr intValue];
    isFirstStep = YES;
    
    vertexValues = [[NSMutableArray alloc]init];
    operatorValues = [[NSMutableArray alloc]init];
    vertexPosition = [[NSMutableArray alloc]init];
    allValues = [[NSMutableArray alloc]init];
    
    // 创建vertexValues数组和operatorValues数组
    if (self.vertexStr) {
        // 通过vertexStr和operatorStr给数组赋值
        NSArray *array1 = [self.vertexStr componentsSeparatedByString:@" "];
        for (int i = 0; i < [array1 count]; i++) {
            [vertexValues addObject:[array1 objectAtIndex:i]];
        }
        NSArray *array2 = [self.operatorStr componentsSeparatedByString:@" "];
        for (int i = 0; i < [array2 count]; i++) {
            [operatorValues addObject:[array2 objectAtIndex:i]];
        }

    } else {
        // 随机生成数组
        [self createVerAndOpeRandomly];

    }
    
    // 创建allValues数组
    for (int i = 0; i < vertexNum; i++) {
        [allValues addObject: [vertexValues objectAtIndex:i]];
        [allValues addObject: [operatorValues objectAtIndex:i]];
    }
    NSLog(@"all: %@", allValues);

    // 绘图
    [self drawPolygon];
    
    // 动态规划计算最高分
    [self calculateHighestScore];

 
}

#pragma mark - 产生数值和操作符

- (void)createVerAndOpeRandomly {
    // 产生随机数
    for (int i = 0; i < vertexNum; i++) {
        [vertexValues addObject:[NSNumber numberWithInt:[self getRandomNumber:-10 to:10]]];
    }
    
    // 随机“+”，“*”
    NSArray *operators = [[NSArray alloc]initWithObjects:@"+", @"*", nil];
    for (int i = 0; i < vertexNum; i++) {
        [operatorValues addObject:[operators objectAtIndex:[self getRandomNumber:0 to:1]]];
    }
    
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
    NSInteger tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];

    button.backgroundColor = [UIColor redColor];
    numLabel.textColor = [UIColor redColor];
    operatorLabel.textColor = [UIColor redColor];
    NSLog(@"touch No.%ld button\n", (NSInteger)button.tag);
}

// 按下后在外面抬起，取消删除
- (void)edgeTouchUpOutside:(UIButton *)button {
    NSInteger tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];
    
    button.backgroundColor = [UIColor blackColor];
    numLabel.textColor = [UIColor blackColor];
    operatorLabel.textColor = [UIColor blackColor];

}

// 按下后在里面抬起，删除
- (void)edgeTouchUpInside:(UIButton *)button {
    
    long tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];
    
    long index = (tag - 200) * 2 -1;
    
    if (isFirstStep) {
        // 第1步，删除掉一条边

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            button.transform = CGAffineTransformMakeScale(0.1, 0.1);
            numLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
            operatorLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            button.backgroundColor = [UIColor clearColor];
            numLabel.backgroundColor = [UIColor clearColor];
            operatorLabel.backgroundColor = [UIColor clearColor];
            
        } completion:^(BOOL finished) {

            // 删除边
            [button removeFromSuperview];
            [numLabel removeFromSuperview];
            [operatorLabel removeFromSuperview];
        }];
        
        [allValues replaceObjectAtIndex:index withObject:[NSNull null]];
        isFirstStep = NO;
        firstStepRmEdge = index;

    } else {
        // 随后的n-1步
        // 获取 两个数值和一个操作符
        long ix = index;
        long jx = (ix == 0) ? allValues.count-1 : index-1; // 前数
        long kx = (ix == allValues.count - 1) ? 0 : index+1; // 后数
        
        while ([allValues objectAtIndex:jx] == [NSNull null]) {
            if (jx == 0) {
                jx = allValues.count - 2;
            } else {
                jx -= 2;
            }

        }
        
        while ([allValues objectAtIndex:kx] == [NSNull null]) {
            if (kx == allValues.count - 2) {
                kx = 0;
            } else {
                kx += 2;
            }

        }
        
        NSString *op = [allValues objectAtIndex:ix];
        NSInteger priorInt = [[allValues objectAtIndex:jx] integerValue];
        NSInteger nextInt = [[allValues objectAtIndex:kx] integerValue];
        UIButton *priorVertexButton = (UIButton *)[self.view viewWithTag: jx/2+1+100];
        UIButton *nextVertexButton = (UIButton *)[self.view viewWithTag: kx/2+1+100];
        NSInteger result = 0;
        
        // 计算
        if ([op isEqualToString:@"+"]) {
            result = priorInt + nextInt;
        } else if ([op isEqualToString:@"*"]) {
            result = priorInt * nextInt;
        }
        NSLog(@"result: %ld", (long)result);
        
        // 将结果赋给前一个点
        [priorVertexButton setTitle:[NSString stringWithFormat:@"%ld", (long)result] forState:UIControlStateNormal];
        
        // 将结果赋值给前点，将数组中边和后点对应位置置NULL
        [allValues replaceObjectAtIndex:jx withObject:[NSNumber numberWithInteger:result]];
        [allValues replaceObjectAtIndex:ix withObject:[NSNull null]];
        [allValues replaceObjectAtIndex:kx withObject:[NSNull null]];
        
        // 移除后点和边
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            nextVertexButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
            button.transform = CGAffineTransformMakeScale(0.1, 0.1);
            numLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
            operatorLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);

            nextVertexButton.backgroundColor = [UIColor clearColor];
            button.backgroundColor = [UIColor clearColor];
            numLabel.backgroundColor = [UIColor clearColor];
            operatorLabel.backgroundColor = [UIColor clearColor];

        } completion:^(BOOL finished) {
            // 将后一个点删除
            [nextVertexButton removeFromSuperview];
            // 删除边
            [button removeFromSuperview];
            [numLabel removeFromSuperview];
            [operatorLabel removeFromSuperview];
        }];
        
        
        // 判断是否结束
        int nullCount = 0;
        int score = 0;
        for (int i = 1; i < allValues.count; i+=2) {
            if ([allValues objectAtIndex:i] == [NSNull null]) {
                nullCount++;
            }
        }
        
        // 结束了
        if (nullCount == operatorValues.count) {
            NSLog(@"结束");
            for (int i = 0; i < allValues.count; i+=2) {
                if ([allValues objectAtIndex:i] != [NSNull null]) {
                    score = [[allValues objectAtIndex:i] intValue];
                }
            }
            
            long theOnlyVertexNum = 0;
            for (int i = 0; i < allValues.count; i+=2) {
                if ([allValues objectAtIndex:i] != [NSNull null]) {
                    theOnlyVertexNum = (i+1)/2 + 1;
                }
            }
            
            UIButton *vertexButton = (UIButton *)[self.view viewWithTag:100+theOnlyVertexNum];
            
            CGRect original = self.yourScoreLabel.frame;
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.yourScoreLabel.frame = CGRectMake(original.origin.x, original.origin.y + 30, original.size.width, original.size.height);
                self.yourScoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
               
            } completion:^(BOOL finished) {
                self.yourScoreLabel.transform = CGAffineTransformMakeScale(1, 1);

                self.yourScoreLabel.text = [NSString stringWithFormat:@"%d", score];
                self.yourScoreLabel.frame =  CGRectMake(original.origin.x, original.origin.y -20, original.size.width, original.size.height);
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.yourScoreLabel.textColor = [UIColor blackColor];
                    self.yourScoreLabel.frame = original;
                    vertexButton.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
                    vertexButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
                } completion:^(BOOL finished) {
                    
                }];
            }];
            
        } else {
            // 没结束
            // 移动边
            long moveEdgeNum;
            long theOtherVertexNum;
            BOOL needMove = YES;
            long nextEdge = (ix == allValues.count - 1) ? 1 : ix+2;
            NSLog(@"%ld", nextEdge);
            if (nextEdge == firstStepRmEdge) {
                needMove = NO;
                NSLog(@"不用移动");
            }
            while ([allValues objectAtIndex:nextEdge] == [NSNull null] && nextEdge != firstStepRmEdge && needMove) {
                nextEdge = (nextEdge == allValues.count - 1) ? 1 : nextEdge+2;
                NSLog(@"%ld", nextEdge);
                if (nextEdge == firstStepRmEdge) {
                    needMove = NO;
                    NSLog(@"不用移动");
                }
            }
            
            
            
            if (needMove) {
                moveEdgeNum = (nextEdge + 1) / 2; // 第moveEdgeNum条
                long theVertexNum = jx / 2 + 1;  // 第theVertexNum个顶点
                theOtherVertexNum = (moveEdgeNum+1 > vertexValues.count) ? ((moveEdgeNum+1) - vertexValues.count) :moveEdgeNum+1; // 第theOtherVertexNum个顶点
                NSLog(@"要移动的边: %ld", moveEdgeNum);
                NSLog(@"第%ld个顶点, 第%ld个顶点", theVertexNum, theOtherVertexNum);
                // 规定圈圈大小
                int radiusOfCircle = 20;
                if (vertexNum >= 10) {
                    radiusOfCircle = radiusOfCircle - vertexNum + 10;
                }
                
                // 移动边moveEdge
                UIButton *moveEdge = (UIButton *)[self.view viewWithTag:200+moveEdgeNum];
                // 先移去
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    moveEdge.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    moveEdge.backgroundColor = [UIColor clearColor];
                } completion:^(BOOL finished) {
                    [moveEdge removeFromSuperview];
                }];
                
                // 再添加
                // 画连线
                float rads = [self angleForStartPoint:CGPointFromString(vertexPosition[theVertexNum-1]) EndPoint:CGPointFromString(vertexPosition[theOtherVertexNum-1])];

                float distance = [self distanceBetweenPiontA:CGPointFromString(vertexPosition[theVertexNum-1]) andPointB:CGPointFromString(vertexPosition[theOtherVertexNum-1])] - 2 * radiusOfCircle;

                UIButton *newEdage = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width/2 - distance/2, self.contentView.frame.size.height/2, distance, 5)];
                newEdage.tag = 200 + moveEdgeNum;
                [newEdage addTarget:self action:@selector(edgeTouchDown:) forControlEvents:UIControlEventTouchDown];
                [newEdage addTarget:self action:@selector(edgeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [newEdage addTarget:self action:@selector(edgeTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
                newEdage.backgroundColor = [UIColor clearColor];
                [self.contentView addSubview:newEdage];

                [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    // 移动
                    newEdage.center = CGPointMake((CGPointFromString(vertexPosition[theVertexNum-1]).x + CGPointFromString(vertexPosition[theOtherVertexNum-1]).x) / 2, (CGPointFromString(vertexPosition[theVertexNum-1]).y + CGPointFromString(vertexPosition[theOtherVertexNum-1]).y) / 2);
                    // 旋转
                    newEdage.transform = CGAffineTransformMakeRotation(rads);
                    newEdage.backgroundColor = [UIColor blackColor];

                    
                } completion:^(BOOL finished) {
                   
                }];
                
                // 计算序号和操作符的位置
                CGPoint canvasCenter = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height / 2);
                CGPoint buttonCenter = newEdage.center;
                
                float xOfOperatorLabel;
                float yOfOperatorLabel;
                float xOfNumLabel;
                float yOfNumLabel;
                
                if ((buttonCenter.x != canvasCenter.x) && (buttonCenter.y != canvasCenter.y)) {
                    float d = [self distanceBetweenPiontA:canvasCenter andPointB:buttonCenter];
                    float r = [self angleForStartPoint:canvasCenter EndPoint:buttonCenter];
                    
                    float x0 = d * cos(r);
                    float y0 = d * sin(fabsf(r));
                    if (r < 0) {
                        y0 = -y0;
                    }
                    
                    xOfOperatorLabel = (d - 15) / d * x0 + canvasCenter.x;
                    yOfOperatorLabel = (d - 15) / d * y0 + canvasCenter.y;
                    
                    xOfNumLabel = (d + 15) / d * x0 + canvasCenter.x;
                    yOfNumLabel = (d + 15) / d * y0 + canvasCenter.y;
                    
                } else {
                    // 两个点重合，不能算d和r。出现在分母处
                    xOfOperatorLabel = buttonCenter.x - 15;
                    yOfOperatorLabel = buttonCenter.y - 15;
                    
                    xOfNumLabel = buttonCenter.x + 15;
                    yOfNumLabel = buttonCenter.y + 15;
                }
                
                UILabel *operatorLabel = (UILabel *)[self.view viewWithTag:300+moveEdgeNum];
                UILabel *numLabel = (UILabel *)[self.view viewWithTag:400+moveEdgeNum];

                [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
                    numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);

                } completion:^(BOOL finished) {
                    
                }];

                
            }
        }
 
    }
    
    NSLog(@"all: %@", allValues);

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
