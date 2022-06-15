//
//  MenuLayer.h
//  Snayke
//
//  Created by Pippin Barr on 16/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKitHelper.h"
#import "Typedefs.h"


@interface MenuLayer : CCLayer<GameKitHelperProtocol>
{
    CCNode* backupScores;
    CCNode* preMenu;
    MenuState state;
    
    BOOL showPreMenu;
}

+ (id) scene;

@end
