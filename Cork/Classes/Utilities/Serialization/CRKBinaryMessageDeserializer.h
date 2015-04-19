//
//  CRKBinaryMessageDeserializer.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import CoreData;

#import "CRKMessageDeserializer.h"

@interface CRKBinaryMessageDeserializer : NSObject <CRKMessageDeserializer>

- (instancetype)initWithContext:(NSManagedObjectContext *)context NS_DESIGNATED_INITIALIZER;

@end
