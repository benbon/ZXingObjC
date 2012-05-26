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

#import "ZXAddressBookDoCoMoResultParser.h"
#import "ZXAddressBookParsedResult.h"
#import "ZXResult.h"

@interface ZXAddressBookDoCoMoResultParser ()

+ (NSString *)parseName:(NSString *)name;

@end

@implementation ZXAddressBookDoCoMoResultParser

+ (ZXAddressBookParsedResult *)parse:(ZXResult *)result {
  NSString * rawText = [result text];
  if (rawText == nil || ![rawText hasPrefix:@"MECARD:"]) {
    return nil;
  }
  NSArray * rawName = [self matchDoCoMoPrefixedField:@"N:" rawText:rawText trim:YES];
  if (rawName == nil) {
    return nil;
  }
  NSString * name = [self parseName:[rawName objectAtIndex:0]];
  NSString * pronunciation = [self matchSingleDoCoMoPrefixedField:@"SOUND:" rawText:rawText trim:YES];
  NSArray * phoneNumbers = [self matchDoCoMoPrefixedField:@"TEL:" rawText:rawText trim:YES];
  NSArray * emails = [self matchDoCoMoPrefixedField:@"EMAIL:" rawText:rawText trim:YES];
  NSString * note = [self matchSingleDoCoMoPrefixedField:@"NOTE:" rawText:rawText trim:NO];
  NSArray * addresses = [self matchDoCoMoPrefixedField:@"ADR:" rawText:rawText trim:YES];
  NSString * birthday = [self matchSingleDoCoMoPrefixedField:@"BDAY:" rawText:rawText trim:YES];
  if (birthday != nil && ![self isStringOfDigits:birthday length:8]) {
    birthday = nil;
  }
  NSString * url = [self matchSingleDoCoMoPrefixedField:@"URL:" rawText:rawText trim:YES];
  NSString * org = [self matchSingleDoCoMoPrefixedField:@"ORG:" rawText:rawText trim:YES];

  return [[[ZXAddressBookParsedResult alloc] initWithNames:[self maybeWrap:name]
                                             pronunciation:pronunciation
                                              phoneNumbers:phoneNumbers
                                                    emails:emails
                                                      note:note
                                                 addresses:addresses
                                                       org:org
                                                  birthday:birthday
                                                     title:nil
                                                       url:url] autorelease];
}

+ (NSString *)parseName:(NSString *)name {
  int comma = [name rangeOfString:@","].location;
  if (comma != NSNotFound) {
    return [NSString stringWithFormat:@"%@ %@", [name substringFromIndex:comma + 1], [name substringToIndex:comma]];
  }
  return name;
}

@end
