//
//  TSLCar.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLCarAgent.h"
#import "../TGL/TGL.h"

@implementation TSLCarAgent {
    
    CGPoint _frontWheel;
    CGPoint _backWheel;
    CGFloat _steerAngle;
    CGPoint _waypoint;
    TSLAgentCompletitionBlock _waypointComplete;
    
    BOOL _autoGas;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithBodySize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithBodySize:(CGSize) size];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super setup];
    
    _autoGas = NO;
    
    _mass     = 100;
    _friction = 0.15;
    
    _steerAngle = 0;
    
    _frontWheel.x = self.body.position.x + self.body.size.height / 2 * cos ( self.body.zRotation );
    _frontWheel.y = self.body.position.y + self.body.size.height / 2 * sin ( self.body.zRotation );
    
    _backWheel.x = self.body.position.x - self.body.size.height / 2 * cos ( self.body.zRotation );
    _backWheel.y = self.body.position.y - self.body.size.height / 2 * sin ( self.body.zRotation );
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super updateWithTimeSinceLastUpdate:deltaTime];
    
    if ( self.isActive == NO ) return;
    
    if (abs(self.body.position.x - _waypoint.x) < 10.0f && abs(self.body.position.y - _waypoint.y) < 10.0f) {
        NSLog(@"Hurray!!");
        _waypointComplete(&_waypoint);
    }
    
    if (_autoGas) {
        if (self.desiredVelocity == 0 && abs(self.velocity) < 2.0f ) {
            self.velocity = 0;
            self.active = NO;
            _autoGas = NO;
            return;
        }
        self.gas = 0.01f * (self.desiredVelocity - self.velocity);
    }
    
    if (self.velocity > kMAX_VELOCITY) {
        self.velocity = kMAX_VELOCITY;
    } else {
        self.velocity += self.acceleration;
    }
        
    
    if (!CGPointEqualToPoint(_waypoint, CGPointZero)) {
        CGFloat angleToPoint = atan2 ( _waypoint.y - _frontWheel.y, _waypoint.x - _frontWheel.x );
        
        self.steer = angleToPoint - self.body.zRotation;
    }
    
    _frontWheel.x = self.body.position.x + self.body.size.height / 2 * cos ( self.body.zRotation );
    _frontWheel.y = self.body.position.y + self.body.size.height / 2 * sin ( self.body.zRotation );
    
    _backWheel.x = self.body.position.x - self.body.size.height / 2 * cos ( self.body.zRotation );
    _backWheel.y = self.body.position.y - self.body.size.height / 2 * sin ( self.body.zRotation );
    
    _backWheel.x += self.velocity * deltaTime * cos ( self.body.zRotation );
    _backWheel.y += self.velocity * deltaTime * sin ( self.body.zRotation );
    
    _frontWheel.x += self.velocity * deltaTime * cos ( self.body.zRotation + _steerAngle );
    _frontWheel.y += self.velocity * deltaTime * sin ( self.body.zRotation + _steerAngle );

    self.body.position = CGPointMake (
        (_frontWheel.x + _backWheel.x) / 2,
        (_frontWheel.y + _backWheel.y) / 2
                                 );
    
    self.body.zRotation = atan2 ( _frontWheel.y - _backWheel.y , _frontWheel.x - _backWheel.x );
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setVelocity:(CGFloat) velocity
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _velocity = velocity;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setAcceleration:(CGFloat) acceleration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _acceleration = acceleration;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDesiredVelocity:(CGFloat) desiredVelocity
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _autoGas = YES;
    _desiredVelocity = desiredVelocity;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setGas:(CGFloat) gas
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Saturation
    if      ( gas > +1.0f ) gas = +1.0f;
    else if ( gas < -1.0f ) gas = -1.0f;
    
    _gas = gas;
    
    CGFloat newAcceleration = (gas < 0 ? -gas * kMIN_TORQUE : gas * kMAX_TORQUE) / self.mass;
    _acceleration = newAcceleration;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setSteer:(CGFloat)steer
////////////////////////////////////////////////////////////////////////////////////////////////
{
//    NSAssert(abs(steer) <= 1.0f, @"Steer value has to be from interval [-1; 1].");
    // Saturation
    if      ( steer > +1.0f ) steer = +1.0f;
    else if ( steer < -1.0f ) steer = -1.0f;
    
    _steerAngle = steer * kMAX_STEER;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) driveToPoint:(CGPoint) point onCompletition:(TSLAgentCompletitionBlock)completitionBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _waypoint = point;
    _waypointComplete = completitionBlock;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) colidesWith:(TSLBody *) otherBody
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [TGLSceneManager registerLayerWithNode:[TGLShapeNode shapeNodeWithRectangleSize:self.body.size fillColor:[SKColor whiteColor] strokeColor:nil] andUpdate:^(CFTimeInterval deltaTime, SKNode *node) {
        SKAction *moveAction = [SKAction moveTo:CGPointMake (
                                      self.body.position.x - self.body.size.height * cos(self.body.zRotation),
                                      self.body.position.y -  self.body.size.width * sin(self.body.zRotation)
                                      ) duration:0.1f];
        SKAction *rotateAction = [SKAction rotateToAngle:self.body.zRotation duration:0.1f];
        
        [node runAction:[SKAction group:@[moveAction, rotateAction]]];
        
//        node.position  = CGPointMake (
//                                      self.body.position.x - self.body.size.height * cos(self.body.zRotation),
//                                      self.body.position.y -  self.body.size.width * sin(self.body.zRotation)
//                                      );
//        node.zRotation = self.body.zRotation;
    }];
    
    [TGLSceneManager registerLayerWithNode:[TGLShapeNode shapeNodeWithCircleOfRadius:5 fillColor:[SKColor cyanColor] strokeColor:nil] andUpdate:^(CFTimeInterval deltaTime, SKNode *node) {
        node.position = _waypoint;
    }];
    
    [TGLSceneManager registerLayerWithNode:[SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"] andUpdate:^(CFTimeInterval deltaTime, SKNode *node) {
        SKLabelNode *label = (SKLabelNode *) node;
        label.text = [NSString stringWithFormat:@"Pos: (%f, %f) Rot: (%f / %f) Vel: (%f / %f)", self.body.position.x, self.body.position.y, self.body.zRotation, _steerAngle, self.velocity, self.gas];
        label.fontSize = 15.0f;
        label.position = CGPointMake(self.body.position.x + label.frame.size.width / 2, self.body.position.y + 20);
    }];
}

@end
