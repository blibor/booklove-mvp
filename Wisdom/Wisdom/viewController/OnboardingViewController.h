//
//  OnboardingViewController.h
//  Wisdom
//
//  Created by Sztanyi Szabolcs on 23/09/15.
//  Copyright © 2015 Zappdesigntemplates. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OnboardingCategory) {
    OnboardingCategoryClassic,
    OnboardingCategoryMystery,
    OnboardingCategoryBiography,
    OnboardingCategoryTravel,
    OnboardingCategoryScience,
    OnboardingCategoryHumanities,
    OnboardingCategoryFiction
};

@class OnboardLabel, RatingButton, PopupView;

@interface OnboardingViewController : UIViewController <UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet OnboardLabel *classicLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *biographyLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *mysteryLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *scienceLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *travelLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *humanitiesLabel;
@property (nonatomic, weak) IBOutlet OnboardLabel *fictionLabel;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *notLikelyLabel;
@property (nonatomic, weak) IBOutlet UILabel *likelyLabel;
@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet PopupView *popupView;
@property (nonatomic, weak) IBOutlet UIView *buttonsContainerView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *travelLeadingConstraint;

@property (nonatomic, strong) IBOutletCollection(RatingButton) NSArray *ratingButtons;

- (IBAction)ratingButtonPressed:(RatingButton*)button;

@end
