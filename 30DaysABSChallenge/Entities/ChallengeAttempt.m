//
//  ChallengeAttempt.m
//  30DaysABSChallenge
//
//  Created by KRKT on 27/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "ChallengeAttempt.h"
#import "Challenge.h"
#import "ChallengeDayAttempt.h"
#import "NSDate+THVDateAdditions.h"
#import "LocalNotificationsManager.h"

@implementation ChallengeAttempt

#pragma mark - ChallengeDataProtocol methods
- (NSString *)challengeName {
	return [[self challenge] name];
}

- (NSNumber *)numberOfDaysInChallenge {
	return [[self challenge] numberOfDays];
}

- (NSArray <ChallengeDayDataProtocol> *)daysListOfChallenge {
	return (NSArray <ChallengeDayDataProtocol> *)[[self challengeDayAttemptsList] array];
}

- (NSNumber *)currentDayNumber {
	return [self currentDay];
}

- (BOOL)isCompleted {
	return [[self state] integerValue] == THVChallengeAttemptStateCompleted;
}

- (NSDate *)challengeStartDate {
	return [self startDate];
}

- (BOOL)isReminderActive {
	return [[self reminderActive] boolValue];
}

- (NSString *)challengeReminderTime {
	return [self reminderTime];
}

- (ChallengeDayAttempt *)nearestChallengeDayForDate:(NSDate *)date {
	for (ChallengeDayAttempt *day in [self challengeDayAttemptsList]) {
		if ([[day reminderDateTime] timeIntervalSinceDate:date] > 0 && ![day.completed boolValue]) {
			return day;
		}
	}
	
	return nil;
}

- (void)scheduleNextNotification {
	if (self.reminderActive && self.reminderTime) {
		ChallengeDayAttempt *nextDay = [self nearestChallengeDayForDate:[NSDate date]];
		if (!nextDay) {
//			DEBUG
//			NSLog(@"There are no more days for this challenge");
			[[LocalNotificationsManager sharedInstance] cancelScheduledNotificationForChallengeAttemptURI:[[self objectID] URIRepresentation]];
			return;
		}
		
		NSURL *challengeURI = [[self objectID] URIRepresentation];
		NSURL *dayURI = [[nextDay objectID] URIRepresentation];
		
		[[LocalNotificationsManager sharedInstance] scheduleNotificationWithChallengeAttemptURI:challengeURI challengeDayAttemptURI:dayURI alertDateTime:[nextDay reminderDateTime] challengeName:[self challengeName] dayType:[nextDay dayTypeName]];
	} else {
		[[LocalNotificationsManager sharedInstance] cancelScheduledNotificationForChallengeAttemptURI:[[self objectID] URIRepresentation]];
	}
}

- (BOOL)isDelayed {
	ChallengeDayAttempt *firstNotCompletedDay = [self getFirstNotCompletedChallengeDay];
	if (!firstNotCompletedDay) {
		return NO;
	}
	
	if ([firstNotCompletedDay.dayAttemptDate timeIntervalSinceDate:[[NSDate date] thv_dateWithoutTime]] >= 0) {
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)isChallengeDayPendingCompletion {
	ChallengeDayAttempt *firstNotCompletedDay = [self getFirstNotCompletedChallengeDay];
	if (!firstNotCompletedDay) {
		return NO;
	}
	
	if ([self.reminderActive boolValue] && ![self.reminderTime isEqualToString:@""] && [[firstNotCompletedDay reminderDateTime] timeIntervalSinceNow] < 0) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark - helper methods
- (ChallengeDayAttempt *)getFirstNotCompletedChallengeDay {
	for (ChallengeDayAttempt *day in self.challengeDayAttemptsList) {
		if (![day.completed boolValue]) {
			return day;
		}
	}
	return nil;
}

@end
