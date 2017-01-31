//
//  GameScene.m
//  TextShooter
//
//  Created by wanghuiyong on 30/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "GameScene.h"
#import "PlayerNode.h"
#import "EnemyNode.h"
#import "BulletNode.h"

@interface GameScene () <SKPhysicsContactDelegate>	// 委托用于处理碰撞检测

@property (strong, nonatomic) PlayerNode		*playerNode;
@property (strong, nonatomic) SKNode			*enemies;
@property (strong, nonatomic) SKNode			*playerBullets;

@end

@implementation GameScene

+ (instancetype)sceneWithSize:(CGSize)size levelNumber:(NSInteger)levelNumber {
    return [[self alloc] initWithSize:size levelNumber:levelNumber];
}

- (instancetype)initWithSize:(CGSize)size {
    return [self initWithSize:size levelNumber:1];
}

- (instancetype)initWithSize:(CGSize)size levelNumber:(NSInteger)levelNumber {
    if (self = [super initWithSize:size]) {
        _levelNumber = levelNumber;
        _playerLives = 5;
        
        self.backgroundColor = [SKColor whiteColor];
        
        // 生命值
        SKLabelNode *lives = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
        lives.fontSize = 16;
        lives.fontColor = [SKColor blackColor];
        lives.name = @"LivesLabel";
        lives.text = [NSString stringWithFormat:@"Lives: %lu", (unsigned long)_playerLives];
        lives.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        lives.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        lives.position = CGPointMake(self.frame.size.width, self.frame.size.height);
        [self addChild:lives];
        
        // 等级
        SKLabelNode *level = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
        level.fontSize = 16;
        level.fontColor = [SKColor blackColor];
        level.name = @"LevelLabel";
        level.text = [NSString stringWithFormat:@"Level: %lu", (unsigned long)_levelNumber];
        level.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        level.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        level.position = CGPointMake(0, self.frame.size.height);
        [self addChild:level];
        
        // 玩家
        _playerNode = [PlayerNode node];
        _playerNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame) * 0.1);
        [self addChild:_playerNode];
        
        // 敌人
        _enemies = [SKNode node];
        [self addChild:_enemies];
        [self spawnEnemies];
        
        // 导弹
        _playerBullets = [SKNode node];
        [self addChild:_playerBullets];
        
        // 物理世界
        self.physicsWorld.gravity = CGVectorMake(0, -1);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        // 移动玩家, 屏幕底部1/5区域
        if (location.y < CGRectGetHeight(self.frame) * 0.2) {
            CGPoint target = CGPointMake(location.x, self.playerNode.position.y);	// 横向移动
            [self.playerNode moveToward:target];
        // 发射导弹, 屏幕剩余部分
        } else {
            BulletNode *bullet = [BulletNode bulletFrom:self.playerNode.position toward:location];
            [self.playerBullets addChild:bullet];
        }
    }

}

- (void)spawnEnemies {
    NSUInteger count = log(self.levelNumber) + self.levelNumber;
    for (NSUInteger i = 0; i < count; i++) {
        EnemyNode *enemy = [EnemyNode node];
        CGSize size = self.frame.size;
        // 随机位置
        CGFloat x = arc4random_uniform(size.width * 0.8) + (size.width * 0.1);
        CGFloat y = arc4random_uniform(size.height * 0.5) + (size.height * 0.5);
        enemy.position = CGPointMake(x, y);
        [self.enemies addChild:enemy];
    }
}

// Called before each frame is rendered
-(void)update:(CFTimeInterval)currentTime {
    
    if (self.finished) return;
    
    [self updateBullets];
    [self updateEnemies];
    [self checkForNextLevel];
    
}

- (void)updateBullets {
    NSMutableArray *bulletsToRemove = [NSMutableArray array];
    
    // playerBullets 节点的子节点遍历
    for (BulletNode *bullet in self.playerBullets.children) {
        // 清除所有移动到屏幕外部的导弹
        if (!CGRectContainsPoint(self.frame, bullet.position)) {
            // 标记将予以清除的导弹, 迭代过程中不应改变集合内容, 因此先标记, 再清除
            [bulletsToRemove addObject:bullet];
            continue;
        }
        // 将推力作用于剩余的导弹
        [bullet applyRecurringForce];
    }
    [self.playerBullets removeChildrenInArray:bulletsToRemove];
}

- (void)updateEnemies {
    NSMutableArray *enemiesToRemove = [NSMutableArray array];
    for (SKNode *node in self.enemies.children) {
        if (!CGRectContainsPoint(self.frame, node.position)) {
            [enemiesToRemove addObject:node];
            continue;
        }
    }
    if ([enemiesToRemove count] > 0) {
        [self.enemies removeChildrenInArray:enemiesToRemove];
    }
}

- (void)checkForNextLevel {
    if ([self.enemies.children count] == 0) {
        [self goToNextLevel];
    }
}

- (void)goToNextLevel {
    self.finished = YES;
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    label.text = @"Level Complete!";
    label.fontColor = [SKColor blueColor];
    label.fontSize = 32;
    label.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    [self addChild:label];
    
    GameScene *nextLevel = [[GameScene alloc] initWithSize:self.frame.size levelNumber:self.levelNumber + 1];
    nextLevel.playerLives = self.playerLives;
    [self.view presentScene:nextLevel transition:[SKTransition flipHorizontalWithDuration:1.0]];
}

#pragma mark - SKPhysicsContactDelegate 

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask) {
        // 两种物理对象都属于同一物理类型
        SKNode *nodeA = contact.bodyA.node;
        SKNode *nodeB = contact.bodyB.node;
    } else {
        SKNode *attacker = nil;
        SKNode *attackee = nil;
        
        if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
            // A 正在攻击 B
            attacker = contact.bodyA.node;
            attackee = contact.bodyB.node;
        } else {
            // B 正在攻击 A
            attacker = contact.bodyB.node;
            attackee = contact.bodyA.node;
        }
        if ([attackee isKindOfClass:[PlayerNode class]]) {
            self.playerLives--;
        }
    }
}

@end
