//
//  CRKUserSerialization.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKContactSerialization.h"

#import "CRKUser.h"

#import "NSManagedObject+CRKAdditions.h"

#import "CRKSigningKeyStore.h"

static NSString * const CRKContactSerializationDisplayNameKey = @"displayName";
static NSString * const CRKContactSerializationIDKey = @"id";
static NSString * const CRKContactSerializationPublicKeyKey = @"publicKey";

@implementation CRKContactSerialization

+ (NSData *)contactDataForUser:(CRKUser *)user {
    NSMutableDictionary *contactCard = [NSMutableDictionary dictionary];
    contactCard[CRKContactSerializationDisplayNameKey] = user.displayName;
    contactCard[CRKContactSerializationIDKey] = user.id.UUIDString;
    
    NSData *publicKey = [[CRKSigningKeyStore sharedStore] exportedPublicKeyForUser:user];
    if (publicKey) {
        contactCard[CRKContactSerializationPublicKeyKey] = [publicKey base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    }
    
    return [NSJSONSerialization dataWithJSONObject:contactCard options:(NSJSONWritingOptions)0 error:nil];
}

+ (CRKUser *)userForContactData:(NSData *)data inContext:(NSManagedObjectContext *)context {
    NSDictionary *contactCard = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString *UUIDString = contactCard[CRKContactSerializationIDKey];
    NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    
    CRKUser *user = [CRKUser uniqueObjectWithIdentifier:userUUID inContext:context];
    user.displayName = contactCard[CRKContactSerializationDisplayNameKey];
    
    NSString *base64EncodedPublicKey = contactCard[CRKContactSerializationPublicKeyKey];
    NSData *publicKey = [[NSData alloc] initWithBase64EncodedString:base64EncodedPublicKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    [[CRKSigningKeyStore sharedStore] importPublicKey:publicKey forUser:user];
    
    return user;
}

@end
