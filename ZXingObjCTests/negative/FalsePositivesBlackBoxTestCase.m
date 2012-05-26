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

#import "FalsePositivesBlackBoxTestCase.h"
#import "ZXMultiFormatReader.h"

@implementation FalsePositivesBlackBoxTestCase

- (id)initWithInvocation:(NSInvocation *)anInvocation {
  self = [super initWithInvocation:anInvocation testBasePathSuffix:@"Resources/blackbox/falsepositives"];

  if (self) {
    [self addTest:1 rotation:0.0f];
    [self addTest:0 rotation:90.0f];
    [self addTest:0 rotation:180.0f];
    [self addTest:1 rotation:270.0f];
  }

  return self;
}

- (void)testBlackBox {
  [super runTests];
}

@end
