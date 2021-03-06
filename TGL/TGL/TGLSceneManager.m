//
//  TGLSceneManager.m
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGLSceneManager.h"
#import "Utilities/TGLScene.h"

@interface TGLSceneManager ()
@property (nonatomic, strong) NSMutableArray *layersToRegistraion;
@property (nonatomic, strong) NSMutableArray *layersZIndex;

- (void) flush;

@end

@implementation TGLSceneManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scene = nil;
        _layersToRegistraion = [NSMutableArray array];
        _layersZIndex        = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Private setters 

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setScene:(TGLScene *) scene
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _scene = scene;
    
    if ([_layersToRegistraion count] != 0) {
        
        // Add registrated layers
        [_layersToRegistraion enumerateObjectsUsingBlock:^(TGLLayer *layer, NSUInteger idx, BOOL *stop) {
            [self registerLayer:layer atZIndex:((NSNumber *) _layersZIndex[idx]).unsignedIntegerValue];
        }];
        
        // Cleanup
        [_layersToRegistraion removeAllObjects];
        [_layersZIndex removeAllObjects];
    }
}

#pragma mark - Singleton

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLSceneManager *) sharedInstance
////////////////////////////////////////////////////////////////////////////////////////////////
{
    static TGLSceneManager * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TGLSceneManager alloc] init];
    });
    
    return _sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TGLScene *) createSceneWithScene:(TGLScene *) scene
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.scene = scene;
    return scene;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TGLScene *) createSceneWithSize:(CGSize) sceneSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLScene *theScene = [TGLScene sceneWithSize:sceneSize];
    self.scene = theScene;
    return theScene;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) flush
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [[TGLSceneManager sharedInstance] flush];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) flush
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [_layersToRegistraion removeAllObjects];
    [_layersZIndex removeAllObjects];
}

#pragma mark - Registering layers

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.scene == nil) {
        [_layersToRegistraion addObject:layer];
        [_layersZIndex addObject:@(zIndex)];
    } else {
        [self.scene registerLayer:layer atZIndex:zIndex];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayer:(TGLLayer *) layer
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [[TGLSceneManager sharedInstance] registerLayer:layer atZIndex:TGLZIndexGround];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [[TGLSceneManager sharedInstance] registerLayer:layer atZIndex:zIndex];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayerWithNode:(SKNode *) node
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [TGLSceneManager registerLayerWithNode:node atZIndex:TGLZIndexGround];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayerWithNode:(SKNode *) node atZIndex:(TGLZIndex) zIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [[TGLSceneManager sharedInstance] registerLayer:[TGLLayer layerWithNode:node] atZIndex:zIndex];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [TGLSceneManager registerLayerWithNode:node andUpdate:updateBlock atZIndex:TGLZIndexGround];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (void) registerLayerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock atZIndex:(TGLZIndex) zIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [[TGLSceneManager sharedInstance] registerLayer:[TGLLayer layerWithNode:node andUpdate:updateBlock] atZIndex:zIndex];
}

@end
