//
//  TAAppDelegate.h
//  TapirApplication
//

//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@interface TAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SKView *skView;
@property (weak) IBOutlet NSScrollView *console;
@property (unsafe_unretained) IBOutlet NSWindow *consoleWindow;

@end
