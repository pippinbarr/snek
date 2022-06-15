//
//  SnekMenuItemSprite.h
//  Snek
//
//  Created by Pippin Barr on 23/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SnekMenuItemSprite : CCMenuItemSprite
{
    
}

+ (id) spriteWithTarget:(id)target selector:(SEL)selector color:(ccColor3B)color highlight:(BOOL)highlight;
- (void) addLabel:(NSString*)label;

@end
