//
//  BulletNode.h
//  TextShooter
//
//  Created by wanghuiyong on 31/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BulletNode : SKNode

+ (instancetype)bulletFrom:(CGPoint)start toward:(CGPoint)destination;	// 工厂方法
- (void)applyRecurringForce;		// 导弹每一帧的移动

@end
