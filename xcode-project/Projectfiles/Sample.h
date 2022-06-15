//
//  Sample.h
//  Snek
//
//  Created by Pippin Barr on 22/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Sample : NSObject
{
    
}

@property NSString* file;
@property NSUInteger offset;
@property NSUInteger next;
@property NSUInteger repeatOffset;

- (id) initWithFile:(NSString*)theFile offset:(NSUInteger)theOffset repeatOffset:(NSUInteger)theRepeatOffset;
- (void) play:(NSUInteger)ticks;
- (void) reset;

@end
