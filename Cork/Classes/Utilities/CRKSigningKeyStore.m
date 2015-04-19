//
//  CRKSigningKeyStore.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKSigningKeyStore.h"

#import "CRKUser.h"

@implementation CRKSigningKeyStore

+ (instancetype)sharedStore {
    static CRKSigningKeyStore *sharedStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[CRKSigningKeyStore alloc] init];
    });
    return sharedStore;
}

static const UInt8 publicKeyIdentifier[] = "com.grantjbutler.Cork.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.grantjbutler.Cork.privatekey\0";

- (instancetype)init {
    self = [super init];
    if (self) {
        if (!self.hasKey) {
            [self generateKeyPairPlease];
        }
    }
    return self;
}

- (BOOL)hasKey {
    SecKeyRef publicKey = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)self.publicKeyQuery, (CFTypeRef *)&publicKey);
    
    return status == noErr;
}

- (void)generateKeyPairPlease {
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // 2
    
    NSData *publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    // 3
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;                                // 4
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
                    forKey:(__bridge id)kSecAttrKeyType]; // 5
    [keyPairAttr setObject:[NSNumber numberWithInt:1024]
                    forKey:(__bridge id)kSecAttrKeySizeInBits]; // 6
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES]
                       forKey:(__bridge id)kSecAttrIsPermanent]; // 7
    [privateKeyAttr setObject:privateTag
                       forKey:(__bridge id)kSecAttrApplicationTag]; // 8
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES]
                      forKey:(__bridge id)kSecAttrIsPermanent]; // 9
    [publicKeyAttr setObject:publicTag
                      forKey:(__bridge id)kSecAttrApplicationTag]; // 10
    
    [keyPairAttr setObject:privateKeyAttr
                    forKey:(__bridge id)kSecPrivateKeyAttrs]; // 11
    [keyPairAttr setObject:publicKeyAttr
                    forKey:(__bridge id)kSecPublicKeyAttrs]; // 12
    
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr,
                                &publicKey, &privateKey); // 13
    //    error handling...
    
    
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);                       // 14
}

- (NSDictionary *)publicKeyQuery {
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
             length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey =
                            [[NSMutableDictionary alloc] init]; // 5
 
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    return queryPublicKey;
}

- (NSDictionary *)publicKeyQueryForUser:(CRKUser *)user {
    NSData * userTag = [user.id.UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryPublicKey =
                            [[NSMutableDictionary alloc] init]; // 5
 
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:userTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    return queryPublicKey;
}

- (NSData *)encryptString:(NSString *)string withPublicKeyOfUser:(CRKUser *)user {
    OSStatus status = noErr;
 
    size_t cipherBufferSize;
    uint8_t *cipherBuffer;                     // 1
 
    SecKeyRef publicKey = NULL;                                 // 3
     // 4
 
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)[self publicKeyQueryForUser:user], (CFTypeRef *)&publicKey); // 7
 
//  Allocate a buffer
 
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
 
    for (int i=0; i<blockCount; i++) {
        
        int bufferSize = (int)MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            
            if (publicKey) {
                CFRelease(publicKey);
            }
            
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    if (publicKey) CFRelease(publicKey);

    return encryptedData;
}

- (NSData *)encryptStringWithPublicKey:(NSString *)string {
    OSStatus status = noErr;
 
    size_t cipherBufferSize;
    uint8_t *cipherBuffer;                     // 1
 
    SecKeyRef publicKey = NULL;                                 // 3
     // 4
 
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)self.publicKeyQuery, (CFTypeRef *)&publicKey); // 7
 
//  Allocate a buffer
 
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
 
    for (int i=0; i<blockCount; i++) {
        
        int bufferSize = (int)MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            
            if (publicKey) {
                CFRelease(publicKey);
            }
            
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    if (publicKey) CFRelease(publicKey);

    return encryptedData;
}

- (NSString *)decryptWithPrivateKey:(NSData *)dataToDecrypt {
    OSStatus status = noErr;
 
    size_t cipherBufferSize = [dataToDecrypt length];
    uint8_t *cipherBuffer = (uint8_t *)[dataToDecrypt bytes];
 
    SecKeyRef privateKey = NULL;
 
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier
                            length:strlen((const char *)privateKeyIdentifier)];
 
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
 
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
                                                                // 1
 
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
  
    cipherBufferSize = SecKeyGetBlockSize(privateKey);
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil(cipherBufferSize / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
    
    for (int i=0; i<blockCount; i++) {
        
        int bufferSize = (int)MIN(blockSize,cipherBufferSize - i * blockSize);
        NSData *buffer = [dataToDecrypt subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyDecrypt(privateKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            
            if (privateKey) {
                CFRelease(privateKey);
            }
            
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    if (privateKey) CFRelease(privateKey);
    
    return [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
}

@end
