//
//  GameScene.h
//  TextShooter
//
//  Created by wanghuiyong on 30/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (assign, nonatomic) NSUInteger levelNumber;
@property (assign, nonatomic) NSUInteger playerLives;
@property (assign, nonatomic) BOOL finished;

+ (instancetype)sceneWithSize:(CGSize)size levelNumber:(NSInteger) levelNumber;
- (instancetype)initWithSize:(CGSize)size levelNumber:(NSInteger) levelNumber;

@end
