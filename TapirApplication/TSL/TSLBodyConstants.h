//
//  TSLAgentConstants.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#ifndef TapirApplication_TSLBodyConstants_h
#define TapirApplication_TSLBodyConstants_h

typedef uint32_t TBitMask;

typedef NS_OPTIONS (TBitMask, eTSLBodyCategory) {
    TSLCarCategory       = 1 << 0,
    TSLSemaphoreCategory = 1 << 1,
    TSLWallCategory      = 1 << 2,
};

#endif
