//
//  CRKSigningKeyStore.h
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;
@import Security;

@class CRKUser;

@interface CRKSigningKeyStore : NSObject

+ (instancetype)sharedStore;

- (NSData *)exportedPublicKey;
- (NSData *)exportedPublicKeyForUser:(CRKUser *)user;

- (BOOL)importPublicKey:(NSData *)publicKey forUser:(CRKUser *)user;

- (NSData *)encryptStringWithPublicKey:(NSString *)string;
- (NSData *)encryptString:(NSString *)string withPublicKeyOfUser:(CRKUser *)user;

- (NSString *)decryptWithPrivateKey:(NSData *)dataToDecrypt;

@end
