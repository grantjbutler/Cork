//
//  NSArray+CRKAdditions.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "NSArray+CRKAdditions.h"

@implementation NSArray (CRKAdditions)

- (id)firstObjectPassingTest:(BOOL (^)(id object))f {
	for (id object in self) {
		if (f(object)) {
			return object;
		}
	}
	
	return nil;
}

@end
