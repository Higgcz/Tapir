//
//  NSString+CharacterEnumeration.m
//  TapirApplication
//
//  Created by Programming Thomas, Edited by Vojtech Micka on 10.05.14.
//  URL: https://gist.github.com/programmingthomas/6856295#file-nsstring-enumeratecharacters-m
//  Copyright (c) 2013 Thomas and 2014 Vojtech Micka. All rights reserved.
//

#import "NSString+CharacterEnumeration.h"

@implementation NSString (CharacterEnumeration)

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) enumerateCharacters:(EnumerationBlock) enumerationBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    const unichar * chars = CFStringGetCharactersPtr((__bridge CFStringRef) self);
    //Function will return NULL if internal storage of string doesn't allow for easy iteration
    if (chars != NULL) {
        NSUInteger index = 0;
        BOOL stop = NO;
        while ( *chars && !stop ) {
            enumerationBlock(*chars, index, &stop);
            chars++;
            index++;
        }
    } else {
        //Use IMP/SEL if the other enumeration is unavailable
        SEL sel = @selector(characterAtIndex:);
        unichar (*charAtIndex)(id, SEL, NSUInteger) = (typeof(charAtIndex)) [self methodForSelector:sel];
        BOOL stop = NO;
        for ( NSUInteger i = 0; i < self.length && !stop; i++ ) {
            const unichar c = charAtIndex(self, sel, i);
            enumerationBlock(c, i, &stop);
        }
    }
}

@end
