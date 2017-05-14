//
//  GameViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/3.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "GameViewController.h"
#import "STPopup/STPopup.h"
#import "StepTableViewController.h"
#import "StepDemoViewController.h"
#define pi 3.14159265358979323846
#define radiansToDegrees(x) (180.0 * x / pi)

/* tag的值：
    顶点：101～ 
    线：201～
    操作符：301～
    序号：401～
    按钮：501～505
*/
typedef struct {
    NSInteger priorVertexNum;
    NSInteger priorVertexValue;
    NSInteger deletedEdgeNum;
    NSInteger nextVertexNum;
    NSInteger nextVertexValue;
}DeleteStep;

@interface GameViewController () {
    NSInteger vertexNum;
    NSMutableArray *vertexValues; // 顶点数值
    NSMutableArray *operatorValues; // 操作符
    NSMutableArray *vertexPosition; // 顶点位置
    NSMutableArray *allValues; // 顶点数值和操作符
    NSMutableArray *historyArray; // 存放历史删除步骤DeleteStep
    NSArray *highestArray; // 存放最高分步骤
    BOOL isFirstLoad;
    BOOL isFirstStep;
    BOOL isEnd;
    NSInteger startScore;
    
    NSInteger firstStepRmEdge;
    CGFloat radiusOfCanvas;
    CGFloat radiusOfCircle;
}

@end


@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化
    vertexNum = [self.vertexNumStr intValue];
    isFirstLoad = YES;
    isFirstStep = YES;
    isEnd = NO;
    vertexValues = [[NSMutableArray alloc]init];
    operatorValues = [[NSMutableArray alloc]init];
    vertexPosition = [[NSMutableArray alloc]init];
    allValues = [[NSMutableArray alloc]init];
    historyArray = [[NSMutableArray alloc]init];
    self.againButton.enabled = NO;
    self.revokeButton.enabled = NO;
    self.historyButton.enabled = NO;
    
    // 整体大小
    radiusOfCanvas = 100;
    if (vertexNum >= 10) {
        radiusOfCanvas = radiusOfCanvas + vertexNum * 3;
    }
    
    // 规定圈圈大小
    radiusOfCircle = 20;
    if (vertexNum >= 10) {
        radiusOfCircle = radiusOfCircle - vertexNum + 10;
    }
    
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
    
    // 让分数label显示为当前最高分的点
    startScore = [vertexValues[0] integerValue];
    for (int i = 0; i < vertexNum; i++) {
        if ([vertexValues[i] integerValue] > startScore) {
            startScore = [vertexValues[i] integerValue];
        }
    }
    self.yourScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)startScore];
    
    // 动态规划计算最高分
    highestArray = [[NSArray alloc]initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
}

-(void)viewDidAppear:(BOOL)animated {
    // 绘图
    if (isFirstLoad) {
        [self drawPolygon];
        isFirstLoad = NO;
    }
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

    // 画顶点
    for (int i = 0; i < vertexNum; i++) {
        // 顶点的位置
        CGPoint point = CGPointMake(self.contentView.center.x + radiusOfCanvas * cos(2 * M_PI * (i+1) / vertexNum), self.contentView.frame.size.height / 2 + radiusOfCanvas * sin(2 * M_PI * (i+1) / vertexNum));
        NSLog(@"point: %f, %f", self.contentView.center.x, self.contentView.center.y);
        // 保存顶点
        [vertexPosition addObject:NSStringFromCGPoint(point)];
        
        // 创建带有数字的顶点
        UIButton *vertexButton = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2, 2 * radiusOfCircle, 2 * radiusOfCircle)];
        vertexButton.tag = 101 + i;
        [vertexButton setTitle:[NSString stringWithFormat:@"%d", [vertexValues[i] intValue]] forState:UIControlStateNormal];
        [vertexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        vertexButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        vertexButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [vertexButton setBackgroundImage:[UIImage imageNamed:@"圈"] forState:UIControlStateNormal];
        
        vertexButton.userInteractionEnabled = NO;
        [self.contentView addSubview:vertexButton];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            vertexButton.center = point;
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    // 画线和序号和操作符
    for (int i = 0; i < vertexNum; i++) {
        
        NSInteger j = (i != vertexNum-1 ? i + 1 : 0);
        // 画连线
        float rads = [self angleForStartPoint:CGPointFromString(vertexPosition[i]) EndPoint:CGPointFromString(vertexPosition[j])];
        float distance = [self distanceBetweenPiontA:CGPointFromString(vertexPosition[i]) andPointB:CGPointFromString(vertexPosition[j])] - 2 * radiusOfCircle;
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, distance, 5)];
        button.tag = 201 + i;
        [button addTarget:self action:@selector(edgeTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(edgeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(edgeTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];

        button.backgroundColor = [UIColor clearColor];
        // 旋转
        button.transform = CGAffineTransformMakeRotation(rads);
        // 移动
        button.center = CGPointMake((CGPointFromString(vertexPosition[i]).x + CGPointFromString(vertexPosition[j]).x) / 2, (CGPointFromString(vertexPosition[i]).y + CGPointFromString(vertexPosition[j]).y) / 2);
        [self.contentView addSubview:button];
 
        // 计算序号和操作符的位置
        CGPoint canvasCenter = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height / 2);
        CGPoint buttonCenter = button.center;
        NSLog(@"line: %f,%f", canvasCenter.x, canvasCenter.y);

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
        
        UILabel *operatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
        operatorLabel.tag = 301 + i;
        operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
        operatorLabel.text = [NSString stringWithFormat:@"%@", operatorValues[i]];
        operatorLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        operatorLabel.textColor = [UIColor clearColor];
        [self.contentView addSubview:operatorLabel];
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 26, 20)];
        numLabel.tag = 401 + i;
        numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
        numLabel.text = [NSString stringWithFormat:@"%d", i+1];
        numLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor clearColor];
        [self.contentView addSubview:numLabel];

        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            button.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                operatorLabel.textColor = [UIColor blackColor];
                numLabel.textColor = [UIColor blackColor];
            } completion:^(BOOL finished) {
            }];
        }];
        
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
    NSLog(@"touchUpinside1");
    NSInteger tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.contentView viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.contentView viewWithTag:tag+200];
    
    NSInteger index = (tag - 200) * 2 -1;
    
    if (isFirstStep) {
        // 第1步，删除掉一条边
        // 将要删除的边加入到historyArrary数组中
        DeleteStep delete;
        delete.deletedEdgeNum = tag-200;
        delete.priorVertexNum = tag-200;
        delete.priorVertexValue = [[vertexValues objectAtIndex:tag-200-1] intValue];
        delete.nextVertexNum = (tag-200 == vertexNum) ? 1 : tag-200+1;
        delete.nextVertexValue = [[vertexValues objectAtIndex:((tag-200 == vertexNum) ? 1 : tag-200+1)-1] intValue];
        //将结构体封装成value对象
        NSValue *value = [NSValue valueWithBytes:&delete objCType:@encode(DeleteStep)];
        [historyArray addObject:value];
        self.againButton.enabled = YES;
        self.revokeButton.enabled = YES;
        self.historyButton.enabled = YES;
        
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
       NSInteger ix = index;
       NSInteger jx = (ix == 0) ? allValues.count-1 : index-1; // 前数
       NSInteger kx = (ix == allValues.count - 1) ? 0 : index+1; // 后数
        
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
        NSInteger priorValue = [[allValues objectAtIndex:jx] integerValue];
        NSInteger nextValue = [[allValues objectAtIndex:kx] integerValue];
        UIButton *priorVertexButton = (UIButton *)[self.view viewWithTag: jx/2+1+100];
        UIButton *nextVertexButton = (UIButton *)[self.view viewWithTag: kx/2+1+100];
        NSInteger result = 0;
        
        // 将要删除的边加入到historyArrary数组中
        DeleteStep delete;
        delete.deletedEdgeNum = ix / 2 + 1;
        delete.priorVertexNum = jx / 2 + 1;
        delete.priorVertexValue = priorValue;
        delete.nextVertexNum = kx / 2 + 1;
        delete.nextVertexValue = nextValue;
        NSValue *value = [NSValue valueWithBytes:&delete objCType:@encode(DeleteStep)];
        [historyArray addObject:value];
        
        // 计算
        if ([op isEqualToString:@"+"]) {
            result = priorValue + nextValue;
        } else if ([op isEqualToString:@"*"]) {
            result = priorValue * nextValue;
        }
        NSLog(@"result: %ld", (long)result);
        
        // 将结果赋给前一个点
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            priorVertexButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
            [priorVertexButton setTitle:[NSString stringWithFormat:@"%ld", (long)result] forState:UIControlStateNormal];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                priorVertexButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:nil];
        }];
        
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
       NSInteger nullCount = 0;
       NSInteger score = 0;
        for (int i = 1; i < allValues.count; i+=2) {
            if ([allValues objectAtIndex:i] == [NSNull null]) {
                nullCount++;
            }
        }
        
        // 结束了
        if (nullCount == operatorValues.count) {
            NSLog(@"结束");
            isEnd = YES;
            for (int i = 0; i < allValues.count; i+=2) {
                if ([allValues objectAtIndex:i] != [NSNull null]) {
                    score = [[allValues objectAtIndex:i] intValue];
                }
            }
            
           NSInteger theOnlyVertexNum = 0;
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
                self.yourScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
                self.yourScoreLabel.frame =  CGRectMake(original.origin.x, original.origin.y -20, original.size.width, original.size.height);
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.yourScoreLabel.textColor = [UIColor whiteColor];
                    self.yourScoreLabel.frame = original;
                    vertexButton.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
                    vertexButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
                } completion:^(BOOL finished) {
                                   }];
            }];
            
        } else {
            // 没结束
            // 移动边
           NSInteger moveEdgeNum;
           NSInteger theOtherVertexNum;
            BOOL needMove = YES;
           NSInteger nextEdge = (ix == allValues.count - 1) ? 1 : ix+2;
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
                NSInteger theVertexNum = jx / 2 + 1;  // 第theVertexNum个顶点
                theOtherVertexNum = (moveEdgeNum+1 > vertexValues.count) ? ((moveEdgeNum+1) - vertexValues.count) :moveEdgeNum+1; // 第theOtherVertexNum个顶点
                NSLog(@"要移动的边: %ld", moveEdgeNum);
                NSLog(@"第%ld个顶点, 第%ld个顶点", theVertexNum, theOtherVertexNum);

                
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
                CGFloat xOfOperatorLabel = 0.0;
                CGFloat yOfOperatorLabel = 0.0;
                CGFloat xOfNumLabel = 0.0;
                CGFloat yOfNumLabel = 0.0;
                
                if ((fabs(buttonCenter.x - canvasCenter.x) < 0.1) && (fabs(buttonCenter.y - canvasCenter.y) < 0.1)) {
                    UIButton *theVertexButton = (UIButton *)[self.contentView viewWithTag:100+theVertexNum];
                    UIButton *theOtherVertexButton = (UIButton *)[self.contentView viewWithTag:100+theOtherVertexNum];
                    if (fabs(theVertexButton.center.y - theOtherVertexButton.center.y) < 1.0) {
                        xOfOperatorLabel = buttonCenter.x;
                        yOfOperatorLabel = buttonCenter.y - 15;
                        xOfNumLabel = buttonCenter.x;
                        yOfNumLabel = buttonCenter.y + 15;
                    } else if (fabs(theVertexButton.center.x - theOtherVertexButton.center.x) < 1.0) {
                        xOfOperatorLabel = buttonCenter.x - 15;
                        yOfOperatorLabel = buttonCenter.y;
                        xOfNumLabel = buttonCenter.x + 15;
                        yOfNumLabel = buttonCenter.y;
                    } else {
                        // 找到垂直点对称的点
                        UIButton *tempButton = (theVertexButton.center.y < theOtherVertexButton.center.y) ? theVertexButton : theOtherVertexButton;
                        CGFloat aimPointX;
                        CGFloat aimPointY;
                        CGPoint aimPoint;
                        
                        if (tempButton.center.x - canvasCenter.x < 0) {
                            // 点在左边
                            aimPointX = canvasCenter.x - (canvasCenter.y - tempButton.center.y);
                            aimPointY = canvasCenter.y + (canvasCenter.x - tempButton.center.x);
                            aimPoint = CGPointMake(aimPointX, aimPointY);
                            float d = [self distanceBetweenPiontA:aimPoint andPointB:canvasCenter];
                            xOfOperatorLabel = (d + 15) * (canvasCenter.x - aimPointX) / d + aimPointX;
                            yOfOperatorLabel = aimPointY - (d + 15) * (aimPointY - canvasCenter.y) / d;
                            xOfNumLabel = (d - 15) * (canvasCenter.x - aimPointX) / d + aimPointX;
                            yOfNumLabel = aimPointY - (d - 15) * (aimPointY - canvasCenter.y) / d;
                        } else {
                            // 点在右边
                            aimPointX = canvasCenter.x + (canvasCenter.y - tempButton.center.y);
                            aimPointY = canvasCenter.y + (canvasCenter.x - tempButton.center.x);
                            aimPoint = CGPointMake(aimPointX, aimPointY);
                            float d = [self distanceBetweenPiontA:aimPoint andPointB:canvasCenter];
                            xOfOperatorLabel = (d + 15) * (canvasCenter.x - aimPointX) / d + aimPointX;
                            yOfOperatorLabel = aimPointY - (d - 20) * (aimPointY - canvasCenter.y) / d;
                            xOfNumLabel = (d - 20) * (canvasCenter.x - aimPointX) / d + aimPointX;
                            yOfNumLabel = aimPointY - (d + 15) * (aimPointY - canvasCenter.y) / d;
                        }
                    }
                } else {

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
    
    // 更新分数label
    NSMutableArray *notNullArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < vertexNum * 2; i += 2) {
        if (allValues[i] != [NSNull null]) {
            [notNullArray addObject:allValues[i]];
        }
    }
    NSInteger max = [notNullArray[0] integerValue];
    
    for (int i = 0; i < notNullArray.count; i++) {
        if ([notNullArray[i] integerValue] > max) {
            max = [notNullArray[i] integerValue];
        }
    }
    
    if (![self.yourScoreLabel.text isEqualToString:[NSString stringWithFormat:@"%ld", (long)max]]) {
        CGRect original = self.yourScoreLabel.frame;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.yourScoreLabel.frame = CGRectMake(original.origin.x, original.origin.y + 30, original.size.width, original.size.height);
            self.yourScoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
        } completion:^(BOOL finished) {
            self.yourScoreLabel.transform = CGAffineTransformMakeScale(1, 1);
            
            self.yourScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)max];
            self.yourScoreLabel.frame =  CGRectMake(original.origin.x, original.origin.y -20, original.size.width, original.size.height);
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.yourScoreLabel.textColor = [UIColor whiteColor];
                self.yourScoreLabel.frame = original;
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

#pragma mark - 按钮事件

// 返回主页
- (IBAction)backBtnClicked:(UIButton *)sender {
    UIView *buttonView = (UIView *)[self.view viewWithTag:502];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:animation forKey:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.vertexNumStr = @"";
        vertexNum = 0;
    }];
}

- (IBAction)againBtnClicked:(id)sender {
    UIView *buttonView = (UIView *)[self.view viewWithTag:503];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    for (UIView *view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    // 重新创建allValues数组
    [allValues removeAllObjects];
    for (int i = 0; i < vertexNum; i++) {
        [allValues addObject: [vertexValues objectAtIndex:i]];
        [allValues addObject: [operatorValues objectAtIndex:i]];
    }
    NSLog(@"all: %@", allValues);
    
    // 将historyArray清空
    [historyArray removeAllObjects];
    self.againButton.enabled = NO;
    self.revokeButton.enabled = NO;
    self.historyButton.enabled = NO;

    [vertexPosition removeAllObjects];
    // 绘图
    [self drawPolygon];
    isFirstStep = YES;
    isEnd = NO;
    
    // 得分label
    CGRect original = self.yourScoreLabel.frame;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.yourScoreLabel.frame = CGRectMake(original.origin.x, original.origin.y + 30, original.size.width, original.size.height);
        self.yourScoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
    } completion:^(BOOL finished) {
        self.yourScoreLabel.transform = CGAffineTransformMakeScale(1, 1);
        self.yourScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)startScore];
        self.yourScoreLabel.frame =  CGRectMake(original.origin.x, original.origin.y -20, original.size.width, original.size.height);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.yourScoreLabel.textColor = [UIColor whiteColor];
            self.yourScoreLabel.frame = original;
        } completion:^(BOOL finished) {
        }];
    }];

}

- (IBAction)revokeBtnClicked:(UIButton *)sender {
    UIView *buttonView = (UIView *)[self.view viewWithTag:504];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    DeleteStep s;
    [[historyArray lastObject] getValue:&s];
    NSInteger priorVertexNum = s.priorVertexNum;
    NSInteger priorVertexValue = s.priorVertexValue;
    NSInteger nextVertexNum = s.nextVertexNum;
    NSInteger nextVertexValue = s.nextVertexValue;
    NSInteger deletedEdgeNum = s.deletedEdgeNum;
    NSInteger moveEdgeNum; //要移动的边
    NSInteger theVertexNum; // 要移动的边的上一个点
    NSInteger theOtherVertexNum;    //要移动的边的下一个点
    
    [historyArray removeLastObject];
    // 重新给allValues赋值
    [allValues replaceObjectAtIndex: (priorVertexNum-1)*2 withObject:[NSNumber numberWithInteger:priorVertexValue]];
    [allValues replaceObjectAtIndex: (nextVertexNum-1)*2  withObject:[NSNumber numberWithInteger:nextVertexValue]];
    [allValues replaceObjectAtIndex: (deletedEdgeNum * 2 - 1) withObject: [operatorValues objectAtIndex:deletedEdgeNum-1]];

    float rads = [self angleForStartPoint:CGPointFromString(vertexPosition[s.priorVertexNum-1]) EndPoint:CGPointFromString(vertexPosition[s.nextVertexNum-1])];
    float distance = [self distanceBetweenPiontA:CGPointFromString(vertexPosition[s.priorVertexNum-1]) andPointB:CGPointFromString(vertexPosition[s.nextVertexNum-1])] - 2 * radiusOfCircle;
    
    if ((deletedEdgeNum != firstStepRmEdge / 2 + 1)) {
        // 判断是否后点连着的边要移动
        // 移动的边
        BOOL needMove = YES;
        NSInteger nextEdge = (deletedEdgeNum*2-1 == allValues.count - 1) ? 1 : deletedEdgeNum*2-1 + 2;
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
            theVertexNum = nextVertexNum;  // 第theVertexNum个顶点
            theOtherVertexNum = (moveEdgeNum+1 > vertexValues.count) ? ((moveEdgeNum+1) - vertexValues.count) :moveEdgeNum+1; // 第theOtherVertexNum个顶点
            NSLog(@"要移动的边: %ld", moveEdgeNum);
            NSLog(@"第%ld个顶点, 第%ld个顶点", theVertexNum, theOtherVertexNum);
            
            // 移动边moveEdge
            UIButton *moveEdge = (UIButton *)[self.view viewWithTag:200+moveEdgeNum];
            // 先移去
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                moveEdge.transform = CGAffineTransformMakeScale(0.1, 0.1);
                moveEdge.backgroundColor = [UIColor clearColor];
            } completion:^(BOOL finished) {
                [moveEdge removeFromSuperview];
            }];
            
            // 画移动的边和序号和操作符
            // 画连线
            CGFloat rads_move = [self angleForStartPoint:CGPointFromString(vertexPosition[theVertexNum-1]) EndPoint:CGPointFromString(vertexPosition[theOtherVertexNum-1])];
        
            CGFloat distance_move = [self distanceBetweenPiontA:CGPointFromString(vertexPosition[theVertexNum-1]) andPointB:CGPointFromString(vertexPosition[theOtherVertexNum-1])] - 2 * radiusOfCircle;
        
            UIButton *newEdage = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width/2 - distance_move/2, self.contentView.frame.size.height/2, distance_move, 5)];
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
                newEdage.transform = CGAffineTransformMakeRotation(rads_move);
                newEdage.backgroundColor = [UIColor blackColor];
        
        
            } completion:^(BOOL finished) {
        
            }];
        
            // 计算序号和操作符的位置
            CGPoint canvasCenter = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height / 2);
            CGPoint buttonCenter = newEdage.center;
            CGFloat xOfOperatorLabel;
            CGFloat yOfOperatorLabel;
            CGFloat xOfNumLabel;
            CGFloat yOfNumLabel;
            
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
        
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
                numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
                
            } completion:^(BOOL finished) {
                
            }];

        }

    
        // 前一个顶点的数字变，画后一个点，画一个点后面的边
        // 前一个顶点
        UIButton *priorVertexButton = (UIButton *)[self.contentView viewWithTag:100+priorVertexNum];
        [priorVertexButton setTitle:[NSString stringWithFormat:@"%ld", (long)priorVertexValue] forState:UIControlStateNormal];
        if (isEnd) {
            
            CGRect original = self.yourScoreLabel.frame;
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.yourScoreLabel.frame = CGRectMake(original.origin.x, original.origin.y + 30, original.size.width, original.size.height);
                self.yourScoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                
            } completion:^(BOOL finished) {
                self.yourScoreLabel.transform = CGAffineTransformMakeScale(1, 1);
                self.yourScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)startScore];
                self.yourScoreLabel.frame =  CGRectMake(original.origin.x, original.origin.y -20, original.size.width, original.size.height);
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.yourScoreLabel.textColor = [UIColor whiteColor];
                    self.yourScoreLabel.frame = original;
                    priorVertexButton.center = CGPointFromString(vertexPosition[priorVertexNum-1]);
                    priorVertexButton.transform = CGAffineTransformMakeScale(0.98, 0.98);
                } completion:^(BOOL finished) {
                    isEnd = NO;
                }];
            }];

        }
        
        //后一个顶点
        // 顶点的位置
        CGPoint point = CGPointMake(self.contentView.center.x + radiusOfCanvas * cos(2 * M_PI * (nextVertexNum) / vertexNum), self.contentView.frame.size.height / 2 + radiusOfCanvas * sin(2 * M_PI * (nextVertexNum) / vertexNum));
        
        // 保存顶点
        [vertexPosition addObject:NSStringFromCGPoint(point)];
        
        // 创建带有数字的顶点
        UIButton *nextVertexButton = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2, 2 * radiusOfCircle, 2 * radiusOfCircle)];
        nextVertexButton.tag = 100 + nextVertexNum;
        [nextVertexButton setTitle:[NSString stringWithFormat:@"%ld", (long)nextVertexValue] forState:UIControlStateNormal];
        [nextVertexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        nextVertexButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [nextVertexButton setBackgroundImage:[UIImage imageNamed:@"圈"] forState:UIControlStateNormal];
        nextVertexButton.userInteractionEnabled = NO;
        [self.contentView addSubview:nextVertexButton];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            nextVertexButton.center = point;
        } completion:^(BOOL finished) {
            
        }];
        
    

    }
    
    // 画两个顶点之间的边
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, distance, 5)];
    button.tag = 200 + s.deletedEdgeNum;
    [button addTarget:self action:@selector(edgeTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(edgeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(edgeTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    button.backgroundColor = [UIColor clearColor];
    // 旋转
    button.transform = CGAffineTransformMakeRotation(rads);
    // 移动
    button.center = CGPointMake((CGPointFromString(vertexPosition[s.priorVertexNum-1]).x + CGPointFromString(vertexPosition[s.nextVertexNum-1]).x) / 2, (CGPointFromString(vertexPosition[s.priorVertexNum-1]).y + CGPointFromString(vertexPosition[s.nextVertexNum-1]).y) / 2);
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
    operatorLabel.tag = 300 + s.deletedEdgeNum;
    operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
    operatorLabel.text = [NSString stringWithFormat:@"%@", operatorValues[s.deletedEdgeNum-1]];
    operatorLabel.textColor = [UIColor clearColor];
    [self.contentView addSubview:operatorLabel];
    
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    numLabel.tag = 400 + s.deletedEdgeNum;
    numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
    numLabel.text = [NSString stringWithFormat:@"%ld", (long)s.deletedEdgeNum];
    numLabel.textColor = [UIColor clearColor];
    [self.contentView addSubview:numLabel];
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            operatorLabel.textColor = [UIColor blackColor];
            numLabel.textColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
        }];
    }];
    

    if (historyArray.count == 0) {
        isFirstStep = YES;
        self.againButton.enabled = NO;
        self.revokeButton.enabled = NO;
        self.historyButton.enabled = NO;
    }
    
}

- (IBAction)historyBtnClicked:(UIButton *)sender {
    UIView *buttonView = (UIView *)[self.view viewWithTag:505];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[StepTableViewController new]];
    popupController.transitionStyle = STPopupTransitionStyleCustom;
    popupController.transitioning = self;
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
    
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toStep" object:historyArray];

}

- (IBAction)highestBtnClicked:(UIButton *)sender {
    
    UIView *buttonView = (UIView *)[self.view viewWithTag:501];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        buttonView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            buttonView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }];

    
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[StepDemoViewController new]];
    popupController.transitionStyle = STPopupTransitionStyleCustom;
    popupController.transitioning = self;
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObject:vertexValues];
    [array addObject:operatorValues];
    [array addObject:highestArray];
//    [array addObject:vertexPosition];
    
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toStepDemo" object:array];
}


#pragma mark - STPopupControllerTransitioning

- (NSTimeInterval)popupControllerTransitionDuration:(STPopupControllerTransitioningContext *)context
{
    return context.action == STPopupControllerTransitioningActionPresent ? 0.5 : 0.35;
}

- (void)popupControllerAnimateTransition:(STPopupControllerTransitioningContext *)context completion:(void (^)())completion
{
    UIView *containerView = context.containerView;
    if (context.action == STPopupControllerTransitioningActionPresent) {
        containerView.transform = CGAffineTransformMakeTranslation(containerView.superview.bounds.size.width - containerView.frame.origin.x, 0);
        
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            context.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
    else {
        [UIView animateWithDuration:[self popupControllerTransitionDuration:context] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            containerView.transform = CGAffineTransformMakeTranslation(- 2 * (containerView.superview.bounds.size.width - containerView.frame.origin.x), 0);
        } completion:^(BOOL finished) {
            containerView.transform = CGAffineTransformIdentity;
            completion();
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
