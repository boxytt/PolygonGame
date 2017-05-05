//
//  DrawPolygon.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/4.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "DrawPolygon.h"

@interface DrawPolygon() {
    int vertexCount;
}

@end

@implementation DrawPolygon

-(void)drawRect:(CGRect)rect
{
    
    vertexCount = [self.vertexNumber intValue];
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    int r = 100;
    if (vertexCount >= 10) {
        r = r + vertexCount * 3;
    }
    
    
    [self drawVertexOfRolygonWithCenterX:rect.origin.x + rect.size.width / 2 centerY:rect.origin.y + rect.size.height / 2 radius:r num:vertexCount ctx:ctx];

}


- (void)drawVertexOfRolygonWithCenterX:(CGFloat)x centerY:(CGFloat)y radius:(CGFloat)radius num:(NSInteger)num ctx:(CGContextRef)ctx
{
    // 规定圈圈大小
    int r = 20;
    if (num >= 10) {
        r = r - num + 10;
    }
    
    for (int i=1; i<=num; i++) {
        //计算顶点的位置
        CGPoint point = CGPointMake(x+radius*cos(2*M_PI*i/num), y+radius*sin(2*M_PI*i/num));
        
        CGContextSetRGBStrokeColor(ctx,1,1,1,1.0);//画笔线的颜色
        CGContextSetLineWidth(ctx, 1.0);//线的宽度
        // 圆心x，圆心y，radius半径，startAngle开始的弧度，endAngle结束的弧度，clockwise（0为顺时针，1为逆时针）
        CGContextAddArc(ctx, point.x, point.y, r, 0, 2*M_PI, 0); //添加一个圆
        CGContextDrawPath(ctx, kCGPathStroke); //绘制路径
        
        
    }
}

@end
