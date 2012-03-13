//
//  EXiLE.m
//
//  Created by Barrett Jacobsen on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EXiLE.h"

@implementation EasyXibLocalizationEntity
@synthesize onUnlocalizedString;
@synthesize ignoreIfSurroundedByUnderscore;

- (void)localizeAccessibilityLabelFor:(UIView*)view withDefault:(NSString*)theString {
    if (view.accessibilityLabel != nil && ![view.accessibilityLabel isEqualToString:theString]) {
        view.accessibilityLabel = [self getLocalizedString:view.accessibilityLabel withSuffix:ACCESSIBILITY_LABEL_SUFFIX];
    }
}

- (NSString *)getLocalizedString:(NSString*)theString withSuffix:(NSString*)suffix {
    if (theString == nil) return nil;
    
    NSMutableCharacterSet *acceptedCharacters = [[NSMutableCharacterSet alloc] init];
    [acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
    [acceptedCharacters formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [acceptedCharacters addCharactersInString:@"_"];
    
    NSString *fixedString = [NSString stringWithFormat:@"%@_%@", currentPrefix, theString];
    fixedString = [fixedString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    fixedString = [[fixedString componentsSeparatedByCharactersInSet:[acceptedCharacters invertedSet]] componentsJoinedByString:@""];
    fixedString = [fixedString uppercaseString];
    
    fixedString = [fixedString stringByAppendingString:suffix];
    
    NSString *localizedString = NSLocalizedString(fixedString, nil);
    
    if ([localizedString isEqualToString:fixedString]) {
        
        if (self.onUnlocalizedString && !(self.ignoreIfSurroundedByUnderscore && [theString hasSuffix:@"_"] && [theString hasPrefix:@"_"]))
            self.onUnlocalizedString(theString, fixedString);
        
        return theString;
    }
    
    return localizedString;
}

- (void)localizeButton:(UIButton*)button {
    button.titleLabel.text = [self getLocalizedString:button.titleLabel.text withSuffix:BUTTON_TEXT_SUFFIX];
    
    [self localizeAccessibilityLabelFor:button withDefault:button.titleLabel.text];
}

- (void)localizeLabel:(UILabel*)label {
    label.text = [self getLocalizedString:label.text withSuffix:LABEL_TEXT_SUFFIX];
    [self localizeAccessibilityLabelFor:label withDefault:label.text];
}

- (void)localizeTextField:(UITextField*)textField {
    textField.text = [self getLocalizedString:textField.text withSuffix:TEXT_FIELD_DEFAULT_TEXT_SUFFIX];
    
    if (![textField.placeholder isEqualToString:@""])
        textField.placeholder = [self getLocalizedString:textField.placeholder withSuffix:TEXT_FIELD_PLACEHOLDER_TEXT_SUFFIX];
    
    [self localizeAccessibilityLabelFor:textField withDefault:textField.text];
}


- (void)localizeViewRecursively:(UIView*)view {
    if ([view isKindOfClass:[UIButton class]]) {
        [self localizeButton:(UIButton*)view];
    }
    else if ([view isKindOfClass:[UILabel class]]) {
        [self localizeLabel:(UILabel*)view];
    }
    else if ([view isKindOfClass:[UITextField class]]) {
        [self localizeTextField:(UITextField*)view];
    }
    else {
        [self localizeAccessibilityLabelFor:view withDefault:nil];
        
        [[view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self localizeViewRecursively:obj];
        }];
    }
}

- (void)localizeViewController:(UIViewController*)viewController withLocalizationPrefix:(NSString*)prefix {
    currentPrefix = [prefix copy];
    [self localizeViewRecursively:viewController.view];
    currentPrefix = nil;
}


+ (EasyXibLocalizationEntity*)shared {
    static dispatch_once_t pred;
    static EasyXibLocalizationEntity *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[EasyXibLocalizationEntity alloc] init];
    });
    return shared;
}

@end
