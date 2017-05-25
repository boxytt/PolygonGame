//
//  BestChoice.m
//  PolygonGame
//
//  Created by boxytt on 2017/5/25.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import "BestChoice.h"

#include<iostream>
#include<string>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#define MAX_BC 1024
using namespace std;


@implementation BestChoice



int n;
int m[MAX_BC][MAX_BC][2];
string m_Sequence[MAX_BC][MAX_BC][2];
char op[MAX_BC];
int minf; //m[i][j][0]表示从v[i]节点开始，边长为j的链的最小值
int maxf; //m[i][j][1]表示从v[i]节点开始，边长为j的链的最大值
//用来记录minf和maxf的路径
string minS;
string maxS;

- (instancetype)init {
    if (self = [super init]) {
        self.highestScoreAndSequence = [[NSArray alloc]init];
        
    }
    return self;
}

- (NSArray *)getScoreAndSequenceWithN:(int)num andOP:(NSArray *)op andValue:(NSArray *)value {
    char ope[num];
    int val[num];
    for (int i = 0; i < num; ++i) {
        ope[i] = ([[op objectAtIndex:i]  isEqual: @"+"]) ? '+': '*';
        val[i] = [[value objectAtIndex:i] intValue];
    }
    [self bestChoiceWithN:num andOP:ope andV:val];
    return [self polyMax];
}

- (void)bestChoiceWithN:(int)arg_n andOP:(char *)arg_op andV:(int*)arg_v {
    n=arg_n;
    for(int i=1; i<n+1; i++)
        op[i] = arg_op[i-1];
    for(int i=1; i<n+1; i++)
        for(int s=0; s<2; s++)
            m[i][1][s] = arg_v[i-1];
    for(int i=0; i<n+1; i++)
        for(int j=0; j<n+1; j++)
            for(int s=0; s<2; s++)
                m_Sequence[i][j][s] = "";
}

- (void)minMaxWithI:(int)i andS:(int)s andJ:(int)j {
    int e[4];
    int a = m[i][s][0];
    int b = m[i][s][1];//a,b分别为第一条子链的最小值和最大值
    int r = (i+s-1) % n + 1; //多边形的实际顶点编号
    string rStr;
    char r_c_str[12] = {0};
    int c = m[r][j-s][0];
    int d = m[r][j-s][1];//c，d分别为第二条子链的最小值和最大值
    
    sprintf(r_c_str,"%d",r);
    rStr = string(r_c_str);
    //计算最后一步op为+时的最小，最大值
    if(op[r] == '+'){
        minf = a+c;
        maxf = b+d;
        minS = m_Sequence[i][s][0] + m_Sequence[r][j-s][0] + rStr + ",";
        maxS = m_Sequence[i][s][1] + m_Sequence[r][j-s][1] + rStr + ",";
    }else {
        e[0] = a*c;
        e[1] = a*d;
        e[2] = b*c;
        e[3] = b*d;
        minf = e[0];
        maxf = e[0];
        minS = m_Sequence[i][s][0] + m_Sequence[r][j-s][0] + rStr + ",";
        maxS = m_Sequence[i][s][0] + m_Sequence[r][j-s][0] + rStr + ",";
        for(int k=1; k<4; k++){
            if(minf > e[k]){
                minf = e[k];
                if(k == 1)
                    minS = m_Sequence[i][s][0] + m_Sequence[r][j-s][1] + rStr + ",";
                if(k == 2)
                    minS = m_Sequence[i][s][1] + m_Sequence[r][j-s][0] + rStr + ",";
                if(k == 3)
                    minS = m_Sequence[i][s][1] + m_Sequence[r][j-s][1] + rStr + ",";
            }
            if(maxf < e[k]){
                maxf = e[k];
                if(k == 1)
                    maxS = m_Sequence[i][s][0] + m_Sequence[r][j-s][1] + rStr + ",";
                if(k == 2)
                    maxS = m_Sequence[i][s][1] + m_Sequence[r][j-s][0] + rStr + ",";
                if(k == 3)
                    maxS = m_Sequence[i][s][1] + m_Sequence[r][j-s][1] + rStr + ",";
            }
        }
    }
}

- (NSArray *)polyMax {
    //j是迭代链的长度，迭代首次删掉第i条边，生成迭代链，s是迭代最后合并的位置，根据op进行+或*
    for(int j=2; j<=n; j++)
        for(int i=1; i<=n; i++){
            [self minMaxWithI:i andS:1 andJ:j];
            m[i][j][0] = minf;
            m[i][j][1] = maxf;
            m_Sequence[i][j][0] = minS;
            m_Sequence[i][j][1] = maxS;
            for(int s=2; s<j; s++){  //s是迭代最后合并的位置，根据op进行+或*
                [self minMaxWithI:i andS:s andJ:j];
                if(m[i][j][0] > minf){
                    m[i][j][0] = minf;
                    m_Sequence[i][j][0] = minS;
                }
                if(m[i][j][1] < maxf) {
                    m[i][j][1] = maxf;
                    m_Sequence[i][j][1] = maxS;
                }
            }
        }
    
    int temp = m[1][n][1];
    int temp1 = 1;
    for(int i=2; i<=n; i++){
        if(temp < m[i][n][1]){
            temp = m[i][n][1];
            temp1 = i;
        }
    }
    
    
    char firstDeleteEdge_c_str[12] = {0};
    sprintf(firstDeleteEdge_c_str,"%d",temp1);
    string firstDeleteEdgeStr(firstDeleteEdge_c_str);
    string deleteEdgeOrderStr = firstDeleteEdgeStr + "," + m_Sequence[temp1][n][1];
//    cout<<"最优结果为: "<<endl;
//    cout<<temp<<endl;
//    cout<<"首次删除第"<<temp1<<"边 "<<endl; //打印首次删除的边
//    cout<<"删除顺序为: "<<endl;
//    //    cout<<m_Sequence[temp1][n][1]<<endl;
//    cout<<deleteEdgeOrderStr<<endl;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [tempArray addObject:[NSNumber numberWithInt:temp]];
    char c[25];
    
    strcpy(c,deleteEdgeOrderStr.c_str());
    char seg[] = ",";
    char *substr= strtok(c, seg);/*利用现成的分割函数,substr为分割出来的子字符串*/
    int i =0;
    while (substr != NULL) {
        [tempArray addObject:[NSString stringWithFormat:@"%s", substr]];
        i++;
        substr = strtok(NULL,seg);/*在第一次调用时，strtok()必需给予参数str字符串，
                                   往后的调用则将参数str设置成NULL。每次调用成功则返回被分割出片段的指针。*/
    }
    
    return [tempArray copy];
}

@end
