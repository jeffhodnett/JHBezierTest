//
//  BezierTestLayer.h
//  BezierTest
//
//  Created by Jeff Hodnett on 18/07/2011.
//  Copyright Applausible 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

typedef enum {
	DraggingSpriteNone,
	DraggingSpriteControlPoint1,
	DraggingSpriteControlPoint2,
	DraggingSpriteEndPosition
} DraggingSprite;

// BezierTestLayer
@interface BezierTestLayer : CCLayer
{
	CGSize size;
	
	DraggingSprite dragging;
	
	BOOL bezierLTR;
	
	// Bezier points
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGPoint endPosition;
}

// returns a CCScene that contains the BezierTestLayer as the only child
+(CCScene *) scene;

@end
