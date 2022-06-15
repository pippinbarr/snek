//
//  SnekMenuItemSprite.m
//  Snek
//
//  Created by Pippin Barr on 23/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SnekMenuItemSprite.h"


@implementation SnekMenuItemSprite

+ (id) spriteWithTarget:(id)target selector:(SEL)selector color:(ccColor3B)color highlight:(BOOL)highlight
{
    CCSprite* normalSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    normalSprite.color = color;

    CCSprite* selectedSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    selectedSprite.color = normalSprite.color;
    if (highlight)
        selectedSprite.opacity = 200;
    
	return [self itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil target:target selector:selector];
}


- (void) addLabel:(NSString*)label
{
    CCSprite* normalSprite = [CCSprite spriteWithFile:@"menuItem.png"];
    int fontSize = floor(normalSprite.contentSize.height / 3);
    
    CCLabelTTF* itemLabel = [CCLabelTTF labelWithString:label fontName:@"Helvetica-Bold" fontSize:fontSize];
    itemLabel.color = ccBLACK;
    itemLabel.anchorPoint = CGPointMake(0.5f,0.5f);
    
    [self addChild:itemLabel];
    itemLabel.position = CGPointMake(self.contentSize.width/2,self.contentSize.height/2);   
}


@end