//
//  DemoOfOpenUDIDViewController.m
//  Demo1OfOpenUDID
//
//  Created by developer on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DemoOfOpenUDIDViewController.h"
#import "LXF_OpenUDID.h"

@interface DemoOfOpenUDIDViewController ()

@end

@implementation DemoOfOpenUDIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)getIdBtnPressed:(id)sender
{
    NSString *openUDID = [LXF_OpenUDID value];
    openUDIDLabel.text = openUDID;
    NSLog(@"%@",openUDID);
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
    NSString *titleStr = [ud objectForKey:@"titleKey"]; 
    titleLabel.text = titleStr;

}

@end
