//
//  BezierTestLayer.m
//  BezierTest
//
//  Created by Jeff Hodnett on 18/07/2011.
//  Copyright Applausible 2011. All rights reserved.
//


// Import the interfaces
#import "BezierTestLayer.h"

enum {
	kTagCatSprite = 1001,
	kTagCatBezierAction,
	kTagControlPoint1Sprite,
	kTagControlPoint1Label,
	kTagControlPoint2Sprite,
	kTagControlPoint2Label,
	kTagEndPointSprite,
	kTagEndPointLabel
};

NSString *const kControlPoint1Title = @"Control Point 1";
NSString *const kControlPoint2Title = @"Control Point 2";
NSString *const kEndPointTitle = @"End Point";

@interface BezierTestLayer(Private)
-(void)startCatSpriteMovement;
-(void)performBezierMovement;

-(NSString *)formatPoint:(CGPoint)point named:(NSString *)name;

-(BOOL)containsTouchLocation:(UITouch *)touch;

@end

// HelloWorldLayer implementation
@implementation BezierTestLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BezierTestLayer *layer = [BezierTestLayer node];
	
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
		
		// Setup touches
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
		
		// ask director the the window size
		size = [[CCDirector sharedDirector] winSize];
		
		// Now lets add the cat sprite
		CCSprite *catSprite = [CCSprite spriteWithFile:@"cat.png"];
		catSprite.position = ccp(size.width/2, 10);
		[self addChild:catSprite z:3 tag:kTagCatSprite];
		
		// Set not dragging
		dragging = DraggingSpriteNone;
		
		// Set left to right by default
		bezierLTR = YES;
		
		// Start the cat sprite movement
		[self startCatSpriteMovement];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// Remove delegate for touches
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self] ;

	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)startCatSpriteMovement 
{
	CCSprite *catSprite = (CCSprite *)[self getChildByTag:kTagCatSprite];
	
	// Setup default positions for the bezier
	controlPoint1 = ccp(30, 100);
	controlPoint2 = ccp(150, 300);
	endPosition = ccp(300, 100);

	// Add some sprites for these points, so its easier for us to see
	CCSprite *controlPoint1Sprite = [CCSprite spriteWithFile:@"circle_green.png"];
	controlPoint1Sprite.position = controlPoint1;
	[self addChild:controlPoint1Sprite z:2 tag:kTagControlPoint1Sprite];
	
	CCSprite *controlPoint2Sprite = [CCSprite spriteWithFile:@"circle_red.png"];
	controlPoint2Sprite.position = controlPoint2;
	[self addChild:controlPoint2Sprite z:2 tag:kTagControlPoint2Sprite];

	CCSprite *endPointSprite = [CCSprite spriteWithFile:@"circle_blue.png"];
	endPointSprite.position = endPosition;
	[self addChild:endPointSprite z:2 tag:kTagEndPointSprite];
	
	// Add some labels for debugging
	NSString *fontName = @"Marker Felt";
	float fontSize = 12.0f;
	CCLabelTTF *controlPoint1Label = [CCLabelTTF labelWithString:[self formatPoint:controlPoint1 named:kControlPoint1Title] fontName:fontName fontSize:fontSize];
	controlPoint1Label.position = ccp(90, size.height - 10);
	[self addChild:controlPoint1Label z:1 tag:kTagControlPoint1Label];
	
	CCLabelTTF *controlPoint2Label = [CCLabelTTF labelWithString:[self formatPoint:controlPoint2 named:kControlPoint2Title] fontName:fontName fontSize:fontSize];
	controlPoint2Label.position = ccp(90, size.height - 30);
	[self addChild:controlPoint2Label z:1 tag:kTagControlPoint2Label];
	
	CCLabelTTF *endPointLabel = [CCLabelTTF labelWithString:[self formatPoint:endPosition named:kEndPointTitle] fontName:fontName fontSize:fontSize];
	endPointLabel.position = ccp(90, size.height - 50);
	[self addChild:endPointLabel z:1 tag:kTagEndPointLabel];
	
	// Set starting position for the cat sprite
	catSprite.position = controlPoint1;

	// Perform the movement
	[self performBezierMovement];
}

-(void)performBezierMovement
{
	// Get the sprite
	CCSprite *catSprite = (CCSprite *)[self getChildByTag:kTagCatSprite];
	
	// Setup the actions
	id bezierAction;
	id callback = [CCCallFunc actionWithTarget:self selector:@selector(bezierFinished:)];
	ccBezierConfig bezier;

	if(bezierLTR) {
		// Set its position
		catSprite.position = controlPoint1;
		
		// Create the bezier path
		bezier.controlPoint_1 = controlPoint1;
		bezier.controlPoint_2 = controlPoint2;
		bezier.endPosition = endPosition;
	}
	else {
		// Set its position
		catSprite.position = endPosition;
		
		// Create the bezier path
		bezier.controlPoint_1 = endPosition;
		bezier.controlPoint_2 = controlPoint2;
		bezier.endPosition = controlPoint1;		
	}

	// Creat the bezier action
	bezierAction = [CCBezierTo actionWithDuration:2 bezier:bezier];

	// Run the action sequence
	CCAction *arcAction = [CCSequence actions: bezierAction, callback, nil];
	arcAction.tag = kTagCatBezierAction;
	[catSprite runAction:arcAction];
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

	// Drawing primatives for debugging
	/*
	CGPoint vertices1[] = { ccp(controlPoint1.x-boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y+boxW), ccp(controlPoint1.x+boxW ,controlPoint1.y-boxW), ccp(controlPoint1.x-boxW ,controlPoint1.y-boxW) };
	ccDrawPoly(vertices1, 4, YES);

	
	glColor4ub(255, 0, 0, 255);
	CGPoint vertices2[] = { ccp(controlPoint2.x-boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y+boxW), ccp(controlPoint2.x+boxW ,controlPoint2.y-boxW), ccp(controlPoint2.x-boxW ,controlPoint2.y-boxW) };
	ccDrawPoly(vertices2, 4, YES);
	
	glColor4ub(0, 0, 255, 255);
	CGPoint vertices3[] = { ccp(endPosition.x-boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y+boxW), ccp(endPosition.x+boxW ,endPosition.y-boxW), ccp(endPosition.x-boxW ,endPosition.y-boxW) };
	ccDrawPoly(vertices3, 4, YES);
	 */
	
	// draw cubic bezier path
	glColor4ub(0, 255, 0, 255);
	ccDrawCubicBezier(controlPoint1, controlPoint1, controlPoint2, endPosition,100);
}

-(NSString *)formatPoint:(CGPoint)point named:(NSString *)name
{
	return [NSString stringWithFormat:@"%@:(%.2f,%.2f)",name,point.x, point.y];
}

#pragma mark - TouchHandler delegate methods
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{        
	// Check the touch locations
    if (![self containsTouchLocation:touch]) return NO;
    	
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Error checking
	if(dragging == DraggingSpriteNone)
		return;
    
	// Peform the move and drag of the correct sprite
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint lastLocation = [touch previousLocationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    lastLocation = [[CCDirector sharedDirector] convertToGL: lastLocation];
	
	CCSprite *sprite;
	CCLabelTTF *label;
	
	switch (dragging) {
		case DraggingSpriteControlPoint1:
			// Update the position
			sprite = (CCSprite *) [self getChildByTag:kTagControlPoint1Sprite];
			controlPoint1 = lastLocation;
			
			// Update the label
			label = (CCLabelTTF *)[self getChildByTag:kTagControlPoint1Label];
			[label setString:[self formatPoint:controlPoint1 named:kControlPoint1Title]];
			
			break;
		case DraggingSpriteControlPoint2:
			// Update the position
			sprite = (CCSprite *) [self getChildByTag:kTagControlPoint2Sprite];
			controlPoint2 = lastLocation;
			
			// Update the label
			label = (CCLabelTTF *)[self getChildByTag:kTagControlPoint2Label];
			[label setString:[self formatPoint:controlPoint2 named:kControlPoint2Title]];

			break;
		case DraggingSpriteEndPosition:
			// Update the position
			sprite = (CCSprite *) [self getChildByTag:kTagEndPointSprite];
			endPosition = lastLocation;
			
			// Update the label
			label = (CCLabelTTF *)[self getChildByTag:kTagEndPointLabel];
			[label setString:[self formatPoint:endPosition named:kEndPointTitle]];

			break;
		default:
			break;
	}
	
	sprite.position = lastLocation;	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Not dragging anymore
	dragging = DraggingSpriteNone;
}

- (BOOL)containsTouchLocation:(UITouch *)touch {
	
	// Checking bounds
	
	// Point 1
	CCSprite *controlPoint1Sprite = (CCSprite *) [self getChildByTag:kTagControlPoint1Sprite];
    CGRect controlPoint1Rect = [controlPoint1Sprite boundingBox];
    
	if(CGRectContainsPoint(controlPoint1Rect, [self convertTouchToNodeSpace:touch])) {
		dragging = DraggingSpriteControlPoint1;
		return YES;
	}

	// Point 2
	CCSprite *controlPoint2Sprite = (CCSprite *) [self getChildByTag:kTagControlPoint2Sprite];
    CGRect controlPoint2Rect = [controlPoint2Sprite boundingBox];
    
	if(CGRectContainsPoint(controlPoint2Rect, [self convertTouchToNodeSpace:touch])) {
		dragging = DraggingSpriteControlPoint2;
		return YES;
	}
	
	// End Point
	CCSprite *endPointSprite = (CCSprite *) [self getChildByTag:kTagEndPointSprite];
    CGRect endPointRect = [endPointSprite boundingBox];
    
	if(CGRectContainsPoint(endPointRect, [self convertTouchToNodeSpace:touch])) {
		dragging = DraggingSpriteEndPosition;
		return YES;
	}
	
	return NO;
}

@end
