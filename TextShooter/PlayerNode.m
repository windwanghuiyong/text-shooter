//
//  PlayerNode.m
//  TextShooter
//
//  Created by wanghuiyong on 30/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "PlayerNode.h"
#import "Geometry.h"
#import "PhysicsCategories.h"

@implementation PlayerNode

- (instancetype)init {
    if (self = [super init]) {
        self.name = [NSString stringWithFormat:@"Player %p", self];
        [self initNodeGraph];
        [self initPhysicsBody];
    }
    return self;
}

- (void)initNodeGraph {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    label.fontColor = [SKColor darkGrayColor];
    label.fontSize = 40;
    label.text = @"v";
    label.zRotation = M_PI;
    label.name = @"label";
    [self addChild:label];
}

- (void)moveToward:(CGPoint)location {
    
    // 每次点击去消息之前的所有动作, 防止冲突
    [self removeActionForKey: @"movement"];
    [self removeActionForKey:@"wobbling"];
    
    // 移动
    CGFloat distance = PointDistance(self.position, location);
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat duration = 2.0 * distance / screenWidth;		// 移动最多需要2秒
    [self runAction:[SKAction moveTo:location duration:duration] withKey:@"movement"];
    
    // 摆动
    CGFloat wobbleTime = 0.5;
    CGFloat halfWobbleTime = wobbleTime * 0.5;
    SKAction *wobbling = [SKAction sequence:@[
    		[SKAction scaleXTo:0.2 duration:halfWobbleTime],		// 宽度先缩小到正常尺寸的1/5
        	[SKAction scaleXTo:1.0 duration:halfWobbleTime]]];	// 再放大到完整尺寸
    NSUInteger wobbleCount = duration / wobbleTime;				// 一次移动的摆动次数
    [self runAction:[SKAction repeatAction:wobbling count:wobbleCount] withKey:@"wobbling"];
}

- (void)initPhysicsBody {
    SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
    body.affectedByGravity = NO;
    body.categoryBitMask = PlayerCategory;
    body.contactTestBitMask = EnemyCategory;		// 玩家可以被敌人攻击的意思?
    body.collisionBitMask = 0;
    self.physicsBody = body;
}

@end
