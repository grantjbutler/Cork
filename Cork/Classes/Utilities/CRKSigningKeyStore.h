//
//  CRKSigningKeyStore.h
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;
@import Security;

@interface CRKSigningKeyStore : NSObject

+ (instancetype)sharedStore;

@end
