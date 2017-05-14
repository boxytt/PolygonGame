//
//  StepDemoViewController.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/13.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "StepDemoViewController.h"
#import "STPopup.h"

typedef struct {
    NSInteger priorVertexNum;
    NSInteger priorVertexValue;
    NSInteger deletedEdgeNum;
    NSInteger nextVertexNum;
    NSInteger nextVertexValue;
}DeleteStep;

@interface StepDemoViewController () {
    NSArray *highestStepArray; // 存放最高分步骤顺序
    NSMutableArray *allValues;
    NSMutableArray *vertexValues;
    NSMutableArray *vertexPosition;
    NSMutableArray *operatorValues;
    NSInteger vertexNum;
    CGFloat radiusOfCanvas;
    CGFloat radiusOfCircle;
    BOOL isFirstStep;
    BOOL isEnd;
    NSInteger firstStepRmEdge;
    NSInteger deleteOrder;
    
}

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) UIButton *deleteNumButton;


@end

@implementation StepDemoViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"最高分演示";
        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStep:) name:@"toStepDemo" object:nil];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playBtnDidTap)];
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    vertexPosition = [[NSMutableArray alloc]init];
    isFirstStep = YES;
    isEnd = NO;
    
 
}

-(void)viewDidAppear:(BOOL)animated {
    [self drawPolygon];

}

- (void)getStep: (NSNotification *)notification {

    NSArray *array = notification.object;
    vertexValues = array[0];
    operatorValues = array[1];
    highestStepArray = array[2];
    vertexNum = highestStepArray.count;

    // 创建allValues数组
    allValues = [[NSMutableArray alloc]init];
    for (int i = 0; i < vertexNum; i++) {
        NSLog(@"#1");

        [allValues addObject: [vertexValues objectAtIndex:i]];
        [allValues addObject: [operatorValues objectAtIndex:i]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"toStep" object:nil];
    
}

- (void)playBtnDidTap {
    if (isEnd) {
        for (UIView *view in [self.view subviews]) {
            [view removeFromSuperview];
        }
        // 重新创建allValues数组
        [allValues removeAllObjects];
        for (int i = 0; i < vertexNum; i++) {
            [allValues addObject: [vertexValues objectAtIndex:i]];
            [allValues addObject: [operatorValues objectAtIndex:i]];
        }
        
        [vertexPosition removeAllObjects];
        // 绘图
        [self drawPolygon];
        isFirstStep = YES;
        isEnd = NO;
    }
    
    self.deleteNumButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x, self.view.center.y / 5, 56, 42)];
    self.deleteNumButton.center = CGPointMake(self.view.center.x, self.view.center.y / 5);
    self.deleteNumButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:40];
    [self.deleteNumButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    self.deleteNumButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.deleteNumButton.userInteractionEnabled = NO;
    [self.view addSubview:self.deleteNumButton];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    deleteOrder = 0;
    if(!self.timer){
        
        //创建一个定时器，这个是直接加到当前消息循环中，注意与其他初始化方法的区别
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self
                
                                              selector:@selector(delete) userInfo:nil repeats:YES];
        
    }
    
}

-(void)delete {
    NSInteger stepNum = [highestStepArray[deleteOrder] integerValue];
    UIButton *button = (UIButton *)[self.view viewWithTag:200+stepNum];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.deleteNumButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
        [self.deleteNumButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.deleteNumButton setTitle:[NSString stringWithFormat:@"%ld", (long)stepNum] forState:UIControlStateNormal];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.deleteNumButton.transform = CGAffineTransformMakeScale(0.01, 0.01);
            
        } completion:^(BOOL finished) {
            [self.deleteNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.deleteNumButton setTitle:@"" forState:UIControlStateNormal];
        }];

    
    }];
    
    [self deleteWithButton:button];
    
    deleteOrder++;
    // 结束
    if (deleteOrder == vertexNum) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;

        }
    }
}

#pragma mark - 绘图

- (void)drawPolygon {
    
    // 画顶点
    for (int i = 0; i < vertexNum; i++) {
        // 顶点的位置
        CGPoint point = CGPointMake(self.view.center.x + radiusOfCanvas * cos(2 * M_PI * (i+1) / vertexNum), self.view.frame.size.height / 2 + radiusOfCanvas * sin(2 * M_PI * (i+1) / vertexNum));
        NSLog(@"point: %f, %f", self.view.center.x, self.view.center.y);
        // 保存顶点
        [vertexPosition addObject:NSStringFromCGPoint(point)];
        
        // 创建带有数字的顶点
        UIButton *vertexButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 2 * radiusOfCircle, 2 * radiusOfCircle)];
        vertexButton.tag = 101 + i;
        [vertexButton setTitle:[NSString stringWithFormat:@"%d", [vertexValues[i] intValue]] forState:UIControlStateNormal];
        vertexButton.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        [vertexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        vertexButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [vertexButton setBackgroundImage:[UIImage imageNamed:@"圈"] forState:UIControlStateNormal];
        
        vertexButton.userInteractionEnabled = NO;
        [self.view addSubview:vertexButton];
        
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
        button.backgroundColor = [UIColor clearColor];
        // 旋转
        button.transform = CGAffineTransformMakeRotation(rads);
        // 移动
        button.center = CGPointMake((CGPointFromString(vertexPosition[i]).x + CGPointFromString(vertexPosition[j]).x) / 2, (CGPointFromString(vertexPosition[i]).y + CGPointFromString(vertexPosition[j]).y) / 2);
        [self.view addSubview:button];
        
        // 计算序号和操作符的位置
        CGPoint canvasCenter = CGPointMake(self.view.center.x, self.view.frame.size.height / 2);
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
        
        UILabel *operatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 8, 20)];
        operatorLabel.tag = 301 + i;
        operatorLabel.center = CGPointMake(xOfOperatorLabel, yOfOperatorLabel);
        operatorLabel.text = [NSString stringWithFormat:@"%@", operatorValues[i]];
        operatorLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        operatorLabel.textColor = [UIColor clearColor];
        [self.view addSubview:operatorLabel];
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 26, 20)];
        numLabel.tag = 401 + i;
        numLabel.center = CGPointMake(xOfNumLabel, yOfNumLabel);
        numLabel.text = [NSString stringWithFormat:@"%d", i+1];
        numLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:18];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor clearColor];
        [self.view addSubview:numLabel];
        
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

#pragma mark: 删除
- (void)deleteWithButton:(UIButton *)button {

    NSInteger tag = button.tag;
    UILabel *numLabel = (UILabel *)[self.view viewWithTag:tag+100];
    UILabel *operatorLabel = (UILabel *)[self.view viewWithTag:tag+200];
    
    NSInteger index = (tag - 200) * 2 -1;
    
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
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                vertexButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                vertexButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
            } completion:^(BOOL finished) {
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
                
                UIButton *newEdage = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - distance/2, self.view.frame.size.height/2, distance, 5)];
                newEdage.tag = 200 + moveEdgeNum;
                newEdage.backgroundColor = [UIColor clearColor];
                [self.view addSubview:newEdage];
                
                [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    // 移动
                    newEdage.center = CGPointMake((CGPointFromString(vertexPosition[theVertexNum-1]).x + CGPointFromString(vertexPosition[theOtherVertexNum-1]).x) / 2, (CGPointFromString(vertexPosition[theVertexNum-1]).y + CGPointFromString(vertexPosition[theOtherVertexNum-1]).y) / 2);
                    // 旋转
                    newEdage.transform = CGAffineTransformMakeRotation(rads);
                    newEdage.backgroundColor = [UIColor blackColor];
                    
                    
                } completion:^(BOOL finished) {
                    
                }];
                
                // 计算序号和操作符的位置
                CGPoint canvasCenter = CGPointMake(self.view.center.x, self.view.frame.size.height / 2);
                CGPoint buttonCenter = newEdage.center;
                CGFloat xOfOperatorLabel = 0.0;
                CGFloat yOfOperatorLabel = 0.0;
                CGFloat xOfNumLabel = 0.0;
                CGFloat yOfNumLabel = 0.0;
                
                if ((fabs(buttonCenter.x - canvasCenter.x) < 0.1) && (fabs(buttonCenter.y - canvasCenter.y) < 0.1)) {
                    UIButton *theVertexButton = (UIButton *)[self.view viewWithTag:100+theVertexNum];
                    UIButton *theOtherVertexButton = (UIButton *)[self.view viewWithTag:100+theOtherVertexNum];
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
