/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitArray.h"
#import "ZXEAN13Reader.h"
#import "ZXErrors.h"

// For an EAN-13 barcode, the first digit is represented by the parities used
// to encode the next six digits, according to the table below. For example,
// if the barcode is 5 123456 789012 then the value of the first digit is
// signified by using odd for '1', even for '2', even for '3', odd for '4',
// odd for '5', and even for '6'. See http://en.wikipedia.org/wiki/EAN-13
//
//                Parity of next 6 digits
//    Digit   0     1     2     3     4     5
//       0    Odd   Odd   Odd   Odd   Odd   Odd
//       1    Odd   Odd   Even  Odd   Even  Even
//       2    Odd   Odd   Even  Even  Odd   Even
//       3    Odd   Odd   Even  Even  Even  Odd
//       4    Odd   Even  Odd   Odd   Even  Even
//       5    Odd   Even  Even  Odd   Odd   Even
//       6    Odd   Even  Even  Even  Odd   Odd
//       7    Odd   Even  Odd   Even  Odd   Even
//       8    Odd   Even  Odd   Even  Even  Odd
//       9    Odd   Even  Even  Odd   Even  Odd
//
// Note that the encoding for '0' uses the same parity as a UPC barcode. Hence
// a UPC barcode can be converted to an EAN-13 barcode by prepending a 0.
//
// The encoding is represented by the following array, which is a bit pattern
// using Odd = 0 and Even = 1. For example, 5 is represented by:
//
//              Odd Even Even Odd Odd Even
// in binary:
//                0    1    1   0   0    1   == 0x19
//
int FIRST_DIGIT_ENCODINGS[10] = {
  0x00, 0x0B, 0x0D, 0xE, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A
};

@interface ZXEAN13Reader ()

@property (nonatomic, assign) int* decodeMiddleCounters;

- (BOOL)determineFirstDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound;

@end

@implementation ZXEAN13Reader

@synthesize decodeMiddleCounters;

- (id)init {
  if (self = [super init]) {
    self.decodeMiddleCounters = (int*)malloc(sizeof(4) * sizeof(int));
    self.decodeMiddleCounters[0] = 0;
    self.decodeMiddleCounters[1] = 0;
    self.decodeMiddleCounters[2] = 0;
    self.decodeMiddleCounters[3] = 0;
  }
  return self;
}

- (void)dealloc {
  if (self.decodeMiddleCounters != NULL) {
    free(self.decodeMiddleCounters);
    self.decodeMiddleCounters = NULL;
  }

  [super dealloc];
}

- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)resultString error:(NSError**)error {
  int *counters = self.decodeMiddleCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  const int countersLen = 4;
  int end = row.size;
  int rowOffset = [[startRange objectAtIndex:1] intValue];

  int lgPatternFound = 0;

  for (int x = 0; x < 6 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_AND_G_PATTERNS error:error];
    if (bestMatch == -1) {
      return -1;
    }
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch % 10)];
    for (int i = 0; i < countersLen; i++) {
      rowOffset += counters[i];
    }
    if (bestMatch >= 10) {
      lgPatternFound |= 1 << (5 - x);
    }
  }

  if (![self determineFirstDigit:resultString lgPatternFound:lgPatternFound]) {
    if (error) *error = NotFoundErrorInstance();
    return -1;
  }

  NSArray * middleRange = [ZXUPCEANReader findGuardPattern:row rowOffset:rowOffset whiteFirst:YES pattern:(int*)MIDDLE_PATTERN patternLen:MIDDLE_PATTERN_LEN error:error];
  if (!middleRange) {
    return -1;
  }
  rowOffset = [[middleRange objectAtIndex:1] intValue];

  for (int x = 0; x < 6 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_PATTERNS error:error];
    if (bestMatch == -1) {
      return -1;
    }
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];
    for (int i = 0; i < countersLen; i++) {
      rowOffset += counters[i];
    }
  }

  return rowOffset;
}

- (ZXBarcodeFormat)barcodeFormat {
  return kBarcodeFormatEan13;
}


/**
 * Based on pattern of odd-even ('L' and 'G') patterns used to encoded the explicitly-encoded
 * digits in a barcode, determines the implicitly encoded first digit and adds it to the
 * result string.
 */
- (BOOL)determineFirstDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound {
  for (int d = 0; d < 10; d++) {
    if (lgPatternFound == FIRST_DIGIT_ENCODINGS[d]) {
      [resultString insertString:[NSString stringWithFormat:@"%C", (unichar)('0' + d)] atIndex:0];
      return YES;
    }
  }
  return NO;
}

@end
