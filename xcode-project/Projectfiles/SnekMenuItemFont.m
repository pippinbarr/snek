//
//  SnaykeMenuItemFont.m
//  Snayke
//
//  Created by Pippin Barr on 16/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SnekMenuItemFont.h"


@implementation SnekMenuItemFont

- (void) selected
{
    if (_isEnabled)
    {
        _isSelected = YES;
    }
}

- (void) unselected
{
    if (_isEnabled)
    {
        _isSelected = NO;
    }
}


@end
