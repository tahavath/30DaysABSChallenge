//
//  MainViewController.m
//  30DaysABSChallenge
//
//  Created by KRKT on 27/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MainViewController.h"
#import "ChallengeDataProtocol.h"
#import "ChallengeAttempt.h"
#import "Commons.h"
#import "ChallengeDetailsViewController.h"

NSString *const THVMyChallengesTableViewCellId = @"THVMyChallengesTableViewCellId";
NSString *const THVShowChallengeAttempDetailsSegueId = @"showChallengeAttemptDetails";

@interface MainViewController ()

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSFetchRequest *fetchRequest;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height + self.tableView.contentOffset.y) {
		self.tableView.scrollEnabled = YES;
	} else {
		self.tableView.scrollEnabled = NO;
	}
}

#pragma mark - segue methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:THVShowChallengeAttempDetailsSegueId]) {
		if ([sender conformsToProtocol:@protocol(ChallengeDataProtocol)]) {
			ChallengeDetailsViewController *destinationVC = segue.destinationViewController;
			destinationVC.selectedChallenge = sender;
		}
	}
}

#pragma mark - table view helper methods
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	id<ChallengeDataProtocol> challengeAttemptForRow = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [challengeAttemptForRow challengeName];
	
	NSMutableString *detailTextLabelText = [NSMutableString string];
	if ([challengeAttemptForRow respondsToSelector:@selector(challengeStartDate)]) {
		[detailTextLabelText appendFormat:@"Started at: %@", [[Commons challengeDayDateFormatter] stringFromDate:[challengeAttemptForRow challengeStartDate]]];
	}
	if ([challengeAttemptForRow respondsToSelector:@selector(isReminderActive)] &&
		[challengeAttemptForRow respondsToSelector:@selector(challengeReminderTime)]) {
		
		if ([challengeAttemptForRow isReminderActive]) {
			[detailTextLabelText appendString:detailTextLabelText.length > 0 ? @", " : @""];
			[detailTextLabelText appendFormat:@"Reminder time: %@", [challengeAttemptForRow challengeReminderTime]];
		}
	}
	cell.detailTextLabel.text = detailTextLabelText;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResultsController.sections[section] objects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THVMyChallengesTableViewCellId];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THVMyChallengesTableViewCellId];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	[self configureCell:cell forRowAtIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ChallengeAttempt *selectedChallenge = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self performSegueWithIdentifier:THVShowChallengeAttempDetailsSegueId sender:selectedChallenge];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.fetchedResultsController.sections[section] indexTitle];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}

- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
	
	NSNumber *stateNumber = [[Commons challengeAttemptStateNumberFormatter] numberFromString:sectionName];
	if (stateNumber) {
		switch ([stateNumber integerValue]) {
			case THVChallengeAttemptStateActive:
				return @"Active challanges";
				break;
			case THVChallengeAttemptStateCompleted:
				return @"Completed challanges";
				break;
		}
	}
	
	return nil;
}

#pragma mark - unwind
- (IBAction)unwindToMain:(UIStoryboardSegue *)segue {
}

#pragma mark - lazy initializares
- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext sectionNameKeyPath:@"state" cacheName:nil];
		
		_fetchedResultsController.delegate = self;
		
		NSError *error = nil;
		if (![_fetchedResultsController performFetch:&error]) {
			NSLog(@"Could not fetch challenge attempts!\n%@\n%@", error.localizedDescription, error.userInfo);
		}
	}
	
	return _fetchedResultsController;
}

- (NSFetchRequest *)fetchRequest {
	if (!_fetchRequest) {
		_fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[ChallengeAttempt entityName]];
		_fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
	}
	
	return _fetchRequest;
}

@end
