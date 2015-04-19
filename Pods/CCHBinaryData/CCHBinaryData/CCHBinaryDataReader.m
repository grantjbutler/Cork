//
//  BinaryDataReader.m
//  BinaryData
//
//  Copyright (C) 2014 Claus Höfele
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCHBinaryDataReader.h"

@interface CCHBinaryDataReader()

@property (nonatomic) NSData *data;
@property (nonatomic) const uint8_t *currentPosition;
@property (nonatomic, getter = isBigEndian) BOOL bigEndian;

@end

@implementation CCHBinaryDataReader

- (instancetype)initWithData:(NSData *)data options:(CCHBinaryDataReaderOptions)options
{
    self = [super init];
    if (self) {
        _data = data;
        _currentPosition = (const uint8_t *)data.bytes;
        _bigEndian = (options & CCHBinaryDataReaderBigEndian) != 0;
    }
    
    return self;
}

- (void)reset
{
    self.currentPosition = (const uint8_t *)self.data.bytes;
}

- (void)setNumberOfBytesRead:(NSUInteger)numberOfBytes
{
    NSAssert(numberOfBytes <= self.data.length, @"Passed end of data");
    
    self.currentPosition = (const uint8_t *)self.data.bytes + numberOfBytes;
}

- (void)skipNumberOfBytes:(NSUInteger)numberOfBytes
{
    NSAssert([self canReadNumberOfBytes:numberOfBytes], @"Passed end of data");
    
    self.currentPosition += numberOfBytes;
}

- (BOOL)canReadNumberOfBytes:(NSUInteger)numberOfBytes
{
    NSUInteger currentLength = self.currentPosition - (const uint8_t *)self.data.bytes;
    return (currentLength + numberOfBytes <= self.data.length);
}

- (char)readChar
{
    NSAssert(sizeof(char) == 1, @"Invalid size");
    NSAssert([self canReadNumberOfBytes:sizeof(char)], @"Passed end of data");
    
    char value = *((char *)self.currentPosition);
    [self skipNumberOfBytes:sizeof(char)];
    
    return value;
}

- (unsigned char)readUnsignedChar
{
    return (unsigned char)[self readChar];
}

- (short)readShort
{
    NSAssert(sizeof(short) == 2, @"Invalid size");
    NSAssert([self canReadNumberOfBytes:sizeof(short)], @"Passed end of data");

    short value = *((short *)self.currentPosition);
    if (self.isBigEndian) {
        value = CFSwapInt16BigToHost(value);
    } else {
        value = CFSwapInt16LittleToHost(value);
    }
    [self skipNumberOfBytes:sizeof(short)];
    
    return value;
}

- (unsigned short)readUnsignedShort
{
    return (unsigned short)[self readShort];
}

- (int)readInt
{
    NSAssert(sizeof(int) == 4, @"Invalid size");
    NSAssert([self canReadNumberOfBytes:sizeof(int)], @"Passed end of data");

    int value = *((int *)self.currentPosition);
    if (self.isBigEndian) {
        value = CFSwapInt32BigToHost(value);
    } else {
        value = CFSwapInt32LittleToHost(value);
    }
    [self skipNumberOfBytes:sizeof(int)];
    
    return value;
}

- (unsigned int)readUnsignedInt
{
    return (unsigned int)[self readInt];
}

- (long long)readLongLong
{
    NSAssert(sizeof(long long) == 8, @"Invalid size");
    NSAssert([self canReadNumberOfBytes:sizeof(long long)], @"Passed end of data");

    long long value = *((long long *)self.currentPosition);
    if (self.isBigEndian) {
        value = CFSwapInt64BigToHost(value);
    } else {
        value = CFSwapInt64LittleToHost(value);
    }
    [self skipNumberOfBytes:sizeof(long long)];
    
    return value;
}

- (unsigned long long)readUnsignedLongLong
{
    return (unsigned long long)[self readLongLong];
}

- (NSString *)readNullTerminatedStringWithEncoding:(NSStringEncoding)encoding
{
    const uint8_t *start = self.currentPosition;
    while (*self.currentPosition++ != '\0') {
        NSAssert([self canReadNumberOfBytes:0], @"Passed end of data");
    }
    
    NSUInteger numberOfBytes = self.currentPosition - start - 1;
    NSString *result = [[NSString alloc] initWithBytes:(const void *)start length:numberOfBytes encoding:encoding];
    
    return result;
}

- (NSString *)readStringWithNumberOfBytes:(NSUInteger)numberOfBytes encoding:(NSStringEncoding)encoding
{
    NSAssert([self canReadNumberOfBytes:numberOfBytes], @"Passed end of data");
    
    NSString *result = [[NSString alloc] initWithBytes:(const void *)self.currentPosition length:numberOfBytes encoding:encoding];
    [self skipNumberOfBytes:numberOfBytes];
    
    return result;
}

@end
