//
//  NSArray+CRKAdditions.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;

@interface NSArray (CRKAdditions)

- (id)firstObjectPassingTest:(BOOL (^)(id object))f;

@end
