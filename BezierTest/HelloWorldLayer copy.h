//
//  HelloWorldLayer.h
//  BezierTest
//
//  Created by Jeff Hodnett on 18/07/2011.
//  Copyright Acrossair 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	BOOL bezierLTR;
	
	// Bezier points
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGPoint endPosition;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
