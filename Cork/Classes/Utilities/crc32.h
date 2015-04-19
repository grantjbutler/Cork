//
//  crc32.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#ifndef __Cork__crc32__
#define __Cork__crc32__

#include <stdio.h>

uint32_t
crc32(uint32_t crc, const void *buf, size_t size);

#endif /* defined(__Cork__crc32__) */
