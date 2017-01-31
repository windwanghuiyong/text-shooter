//
//  PhysicsCategories.h
//  TextShooter
//
//  Created by wanghuiyong on 31/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#ifndef PhysicsCategories_h
#define PhysicsCategories_h

// 类别位掩码
typedef NS_OPTIONS(uint32_t, PhysicsCategory) {
    PlayerCategory = 1 << 1,
    EnemyCategory = 1 << 2,
    PlayerMissileCategroy = 1 << 3
};

#endif /* PhysicsCategories_h */
