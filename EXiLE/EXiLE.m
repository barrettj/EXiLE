//
//  EXiLE.m
//
//  Created by Barrett Jacobsen on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EXiLE.h"

typedef void (^ExileSetTextBlock)(NSString *newText);

@implementation EasyXibLocalizationEntity
@synthesize onUnlocalizedString;
@synthesize ignoreIfSurroundedByUnderscore;
@synthesize allowLocalizationKeySpecification;

- (void)localizeAccessibilityLabelFor:(UIView*)view withDefault:(NSString*)theString {
    if (view.accessibilityLabel != nil && ![view.accessibilityLabel isEqualToString:theString]) {
        [self localize:view set:@selector(setAccessibilityLabel:) text:view.accessibilityLabel suffix:ACCESSIBILITY_LABEL_SUFFIX];
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

- (NSString *)getLocalizedStringForKey:(NSString*)key withDefault:(NSString*)defaultText {
    NSString *localizedString = NSLocalizedString(key, nil);
    
    if ([localizedString isEqualToString:key]) {
        if (self.onUnlocalizedString)
            self.onUnlocalizedString(defaultText, key);
        
        return defaultText;
    }
    
    return localizedString;
}

- (void)localize:(UIView*)view set:(SEL)setSelector text:(NSString*)text suffix:(NSString*)suffix {
    ExileSetTextBlock setViaSelector = ^(NSString *newText) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [view performSelector:setSelector withObject:newText];
#pragma clang diagnostic pop           
    };
    
    return [self localizeText:text setTextBlock:setViaSelector suffix:suffix];
}

- (void)localizeText:(NSString*)text setTextBlock:(ExileSetTextBlock)setBlock suffix:(NSString*)suffix {
    if (text == nil) return;
    
    if (self.allowLocalizationKeySpecification && [text hasSuffix:@"**"]) {
        NSArray *components = [text componentsSeparatedByString:@"**"];
        
        if (components.count == 3) {
            NSString *defaultText = [components objectAtIndex:0];
            NSString *key = [components objectAtIndex:1];
            
            setBlock([self getLocalizedStringForKey:key withDefault:defaultText]);
            
            return;
        }
        
        NSLog(@"Incorrect use of ** syntax in EXiLE.");
    }
    
    setBlock([self getLocalizedString:text withSuffix:suffix]);
    
    return;
}

- (void)localizeButton:(UIButton*)button {
    [self localize:button.titleLabel set:@selector(setText:) text:button.titleLabel.text suffix:BUTTON_TEXT_SUFFIX];
    
    [self localizeAccessibilityLabelFor:button withDefault:button.titleLabel.text];
}

- (void)localizeLabel:(UILabel*)label {
    [self localize:label set:@selector(setText:) text:label.text suffix:LABEL_TEXT_SUFFIX];
    
    [self localizeAccessibilityLabelFor:label withDefault:label.text];
}

- (void)localizeTextField:(UITextField*)textField {
    if (![textField.text isEqualToString:@""]) {
        [self localize:textField set:@selector(setText:) text:textField.text suffix:TEXT_FIELD_DEFAULT_TEXT_SUFFIX];
    }
    
    if (![textField.placeholder isEqualToString:@""]) {
        [self localize:textField set:@selector(setPlaceholder:) text:textField.placeholder suffix:TEXT_FIELD_PLACEHOLDER_TEXT_SUFFIX];
    }
    
    [self localizeAccessibilityLabelFor:textField withDefault:textField.text];
}


- (void)localizeSegmentedControl:(UISegmentedControl*)seg {
    if (seg.numberOfSegments > 0) {
        for (NSUInteger i = 0; i < seg.numberOfSegments; i++) {
            [self localizeText:[seg titleForSegmentAtIndex:i] setTextBlock:^(NSString *newText) {
                [seg setTitle:newText forSegmentAtIndex:i];
            } suffix:SEGMENTED_CONTROL_SEGMENT];
        }
    }
    
    [self localizeAccessibilityLabelFor:seg withDefault:nil];
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
    else if ([view isKindOfClass:[UISegmentedControl class]]) {
        [self localizeSegmentedControl:(UISegmentedControl*)view];
    }
    else if ([view isKindOfClass:[UIImageView class]]) {
        if (view.accessibilityLabel != nil && ![view.accessibilityLabel hasSuffix:@".png"])
            [self localizeAccessibilityLabelFor:view withDefault:view.accessibilityLabel];
    }
    else {
        [self localizeAccessibilityLabelFor:view withDefault:nil];
        
        [[view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self localizeViewRecursively:obj];
        }];
    }
}

- (void)localizeView:(UIView*)view withLocalizationPrefix:(NSString*)prefix {
    currentPrefix = [prefix copy];
    [self localizeViewRecursively:view];
    currentPrefix = nil;
}

- (void)localizeViewController:(UIViewController*)viewController withLocalizationPrefix:(NSString*)prefix {
    [self localizeView:viewController.view withLocalizationPrefix:prefix];
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.ignoreIfSurroundedByUnderscore = YES;
        self.allowLocalizationKeySpecification = YES;
    }
    
    return self;
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
