//
//  ChosenChallengeConfigurationViewController.h
//  30DaysABSChallenge
//
//  Created by KRKT on 27/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeDataProtocol.h"

@interface ChosenChallengeConfigurationViewController : UIViewController

@property (nonatomic) id<ChallengeDataProtocol> selectedChallenge;
- (IBAction)saveButtonTapped:(id)sender;

@end
