//
//  HelloWorldLayer.m
//  BezierTest
//
//  Created by Jeff Hodnett on 18/07/2011.
//  Copyright Acrossair 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

enum {
	kGlassSprite = 1001,
	kAngleBarSprite,
	kDialBezierAction,
	kBeerHeadSprite,
};

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// Add a white background
		CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
		bg.position = ccp(size.width/2, size.height/2);
//		[self addChild:bg z:0];
	
		// Add the degree widget
		CCSprite *degreeWidgetSprite = [CCSprite spriteWithFile:@"Degree.png"];
		degreeWidgetSprite.position = ccp(size.width/2, 40);
		[self addChild:degreeWidgetSprite z:2];
		
		// Now lets add the dial sprite
		CCSprite *dialBarSprite = [CCSprite spriteWithFile:@"Dial.png"];
		dialBarSprite.position = ccp(size.width/2, 10);
		[self addChild:dialBarSprite z:3 tag:kAngleBarSprite];
		
		bezierLTR = YES;
		
		// Start the angle bar movement
		[self startAngleBarMovement];
		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)startAngleBarMovement 
{
	CGSize size = [[CCDirector sharedDirector] winSize];

	controlPoint1 = ccp(300, 200);
	controlPoint2 = ccp(170, 400);
	endPosition = ccp(20, 200);
	
	// Perform the movement
	[self performBezierMovement];
}

-(void)performBezierMovement
{
	// Get the sprite
	CCSprite *angleBarSprite = (CCSprite *)[self getChildByTag:kAngleBarSprite];
	
	// Setup the actions
	id bezierAction;
	id callback = [CCCallFunc actionWithTarget:self selector:@selector(bezierFinished:)];
	ccBezierConfig bezier;

	if(bezierLTR) {
		// Set its position
		angleBarSprite.position = controlPoint1;
		
		// Create the bezier path
		bezier.controlPoint_1 = controlPoint1;
		bezier.controlPoint_2 = controlPoint2;
		bezier.endPosition = endPosition;
	}
	else {
		// Set its position
		angleBarSprite.position = endPosition;
		
		// Create the bezier path
		bezier.controlPoint_1 = endPosition;
		bezier.controlPoint_2 = controlPoint2;
		bezier.endPosition = controlPoint1;		
	}

	// Creat the bezier action
	bezierAction = [CCBezierTo actionWithDuration:2 bezier:bezier];

	// Run the action sequence
	CCAction *arcAction = [CCSequence actions: bezierAction, callback, nil];
	arcAction.tag = kDialBezierAction;
	[angleBarSprite runAction:arcAction];
}

-(void)bezierFinished:(id)sender 
{
	// Reverse
	bezierLTR = !bezierLTR;
	
	// Perform the movement
	[self performBezierMovement];
}

-(void) draw
{
	// Debugging
	float boxW = 2.0f;
	
	glEnable(GL_LINE_SMOOTH);
	glColor4ub(255, 0, 255, 255);
	glLineWidth(2);
	CGPoint vertices1[] = { ccp(controlPoint1.x-boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y-boxW), ccp(controlPoint1.x-boxW ,controlPoint1.y-boxW) };
	ccDrawPoly(vertices1, 4, YES);

	
	glColor4ub(255, 0, 0, 255);
	CGPoint vertices2[] = { ccp(controlPoint2.x-boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y-boxW), ccp(controlPoint2.x-boxW ,controlPoint2.y-boxW) };
	ccDrawPoly(vertices2, 4, YES);
	
	glColor4ub(0, 0, 255, 255);
	CGPoint vertices3[] = { ccp(endPosition.x-boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y-boxW), ccp(endPosition.x-boxW ,endPosition.y-boxW) };
	ccDrawPoly(vertices3, 4, YES);

	// draw cubic bezier path
	glColor4ub(0, 255, 0, 255);
	ccDrawCubicBezier(controlPoint1, controlPoint1, controlPoint2, endPosition,100);
}

@end
