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

#import "ZXAbstractDoCoMoResultParser.h"

/**
 * Implements the "MATMSG" email message entry format.
 * 
 * Supported keys: TO, SUB, BODY
 */

@class ZXEmailAddressParsedResult, ZXResult;

@interface ZXEmailDoCoMoResultParser : ZXAbstractDoCoMoResultParser

+ (ZXEmailAddressParsedResult *)parse:(ZXResult *)result;
+ (BOOL)isBasicallyValidEmailAddress:(NSString *)email;

@end
