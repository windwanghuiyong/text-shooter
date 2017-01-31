//
//  GameViewController.m
//  TextShooter
//
//  Created by wanghuiyong on 30/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;					// 帧数
    skView.showsNodeCount = YES;				// 节点数
    skView.ignoresSiblingOrder = YES;
    
    GameScene *scene = [GameScene sceneWithSize:self.view.frame.size levelNumber:1];
    
    [skView presentScene:scene];	
}

- (BOOL)shouldAutorotate {
    return YES;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
