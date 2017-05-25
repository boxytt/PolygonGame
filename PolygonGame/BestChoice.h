//
//  BestChoice.h
//  PolygonGame
//
//  Created by boxytt on 2017/5/25.
//  Copyright © 2017年 boxytt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BestChoice : NSObject

@property (nonatomic, strong)NSArray *highestScoreAndSequence;

- (instancetype)init;
- (NSArray *)getScoreAndSequenceWithN:(int)num andOP:(NSArray *)op andValue:(NSArray *)value;
- (void)bestChoiceWithN:(int)arg_n andOP:(char *)arg_op andV:(int*)arg_v;
- (void)minMaxWithI:(int)i andS:(int)s andJ:(int)j;
- (NSArray *)polyMax;

@end
