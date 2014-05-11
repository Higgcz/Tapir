//
//  NSString+CharacterEnumeration.h
//  TapirApplication
//
//  Created by Programming Thomas, Edited by Vojtech Micka on 10.05.14.
//  URL: https://gist.github.com/programmingthomas/6856295#file-nsstring-enumeratecharacters-m
//  Copyright (c) 2013 Thomas and 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EnumerationBlock)(const unichar character, NSUInteger index, BOOL *stop);

@interface NSString (CharacterEnumeration)

- (void) enumerateCharacters:(EnumerationBlock) enumerationBlock;

@end
