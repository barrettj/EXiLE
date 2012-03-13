//
//  BJViewController.m
//  EXiLE-Demo
//
//  Created by Barrett Jacobsen on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BJViewController.h"
#import "EXiLE.h"

@interface BJViewController ()

@end

@implementation BJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [EXILE localizeViewController:self withLocalizationPrefix:@"BJVC"];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
