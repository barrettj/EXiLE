//
//  EXiLE.h
//
//  Created by Barrett Jacobsen on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EXILE [EasyXibLocalizationEntity shared]

#define LABEL_TEXT_SUFFIX @"_LABEL"
#define BUTTON_TEXT_SUFFIX @"_BUTTON_TEXT"
#define TEXT_FIELD_DEFAULT_TEXT_SUFFIX @"_TEXT_FIELD_DEFAULT"
#define TEXT_FIELD_PLACEHOLDER_TEXT_SUFFIX @"_TEXT_FIELD_PLACEHOLDER"
#define SEGMENTED_CONTROL_SEGMENT @"_SEGMENT_TEXT"

#define ACCESSIBILITY_LABEL_SUFFIX @"_ACCESSIBILITY_LABEL"

typedef void (^UnlocalizedStringFoundBlock)(NSString *unlocalizedString, NSString *localizationKey);

@interface EasyXibLocalizationEntity : NSObject {
    NSString *currentPrefix;
}

@property (readwrite, assign) BOOL ignoreIfSurroundedByUnderscore;
@property (readwrite, assign) BOOL allowLocalizationKeySpecification;


@property (readwrite, copy) UnlocalizedStringFoundBlock onUnlocalizedString;

- (void)localizeViewController:(UIViewController*)viewController withLocalizationPrefix:(NSString*)prefix;
- (void)localizeView:(UIView*)view withLocalizationPrefix:(NSString*)prefix;

+ (EasyXibLocalizationEntity*)shared;


@end
