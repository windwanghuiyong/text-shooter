//
//  BulletNode.m
//  TextShooter
//
//  Created by wanghuiyong on 31/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "BulletNode.h"
#import "PhysicsCategories.h"
#import "Geometry.h"

@interface BulletNode ()

@property (assign, nonatomic) CGVector thrust;

@end

@implementation BulletNode

- (instancetype)init {
    if (self = [super init]) {
        SKLabelNode *dot = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
        dot.fontColor = [SKColor blackColor];
        dot.fontSize = 40;
        dot.text = @".";
        [self addChild:dot];
        
        // 物理特性
        SKPhysicsBody *body = [SKPhysicsBody bodyWithCircleOfRadius:1];
        body.dynamic = YES;
        body.categoryBitMask = PlayerMissileCategroy;
        body.contactTestBitMask = EnemyCategory;
        body.collisionBitMask = EnemyCategory;			// 碰撞
        body.mass = 0.01;
        
        self.physicsBody = body;
        self.name = [NSString stringWithFormat:@"Bullet %p", self];
    }
    return self;
}

+ (instancetype)bulletFrom:(CGPoint)start toward:(CGPoint)destination {
    BulletNode *bullet = [[self alloc] init];
    
    bullet.position = start;
    
    CGVector movement = VectorBetweenPoints(start, destination);		// 由起点指向终点的位移向量
    CGFloat magnitude = VectorLength(movement);						// 长度
    if (magnitude == 0.0f) return nil;
    
    CGVector scaledMovement = VectorMultiply(movement, 1 / magnitude);	// 单位向量
    
    CGFloat thrustMagnitude = 100.0;
    bullet.thrust = VectorMultiply(scaledMovement, thrustMagnitude);
    
    return bullet;
}

// 推动发射, 在场景的每一帧中都要调用它
- (void)applyRecurringForce {
    [self.physicsBody applyForce:self.thrust];
}

@end
