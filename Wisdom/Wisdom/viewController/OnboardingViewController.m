//
//  OnboardingViewController.m
//  Wisdom
//
//  Created by Sztanyi Szabolcs on 23/09/15.
//  Copyright © 2015 Zappdesigntemplates. All rights reserved.
//

#import "OnboardingViewController.h"
#import "OnboardLabel.h"
#import "RatingButton.h"
#import "OnboardingDataSource.h"
#import "ImageCollectionViewCell.h"
#import "PopupView.h"
#import "StoryboardManager.h"
#import "MainContainerViewController.h"
#import "ParseDownloadManager.h"
#import "OnboardingFlowLayout.h"

@interface OnboardingViewController ()
@property (nonatomic) OnboardingCategory currentlySelectedCategory;
@property (nonatomic, strong) OnboardingDataSource *imagesDataSource;
@property (nonatomic, strong) OnboardingFlowLayout *onboardingFlowLayout;
@end

@implementation OnboardingViewController

- (IBAction)ratingButtonPressed:(RatingButton*)button
{
    [button setSelected:YES];

    [self.imagesDataSource setRating:button.tag forCategory:self.currentlySelectedCategory];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showNextCategory];
    });
}

- (void)showMainView
{
    MainContainerViewController *mainContainerViewController = [StoryboardManager mainContainerViewController];
    [self presentViewController:mainContainerViewController animated:YES completion:nil];
}

- (void)showNextCategory
{
    switch (self.currentlySelectedCategory) {
        case OnboardingCategoryCrime:
            [self loadCategory:OnboardingCategoryClassic];
            break;
        case OnboardingCategoryClassic:
            [self loadCategory:OnboardingCategoryBiography];
            break;
        case OnboardingCategoryBiography:
            [self loadCategory:OnboardingCategoryScience];
            break;
        case OnboardingCategoryScience:
            [self loadCategory:OnboardingCategoryTravel];
            break;
        case OnboardingCategoryTravel:
            [GeneralSettings setOnboardingCompleted:YES];

            // send user ratings
            [self uploadUserCategorySelections:self.imagesDataSource.savedCategoriesArray];
            [self showMainView];
            break;
        default:
            break;
    }
}

- (void)uploadUserCategorySelections:(NSArray*)ratingsArray
{
    NSInteger maxValue = 0;

    for (BookGenre *genre in ratingsArray) {
        if (genre.selectedRating >= maxValue) {
            maxValue = genre.selectedRating;
            [GeneralSettings setFavoriteCategory:genre.genreName];
        }
    }

    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"categorySelections"] = self.imagesDataSource.ratingsDictionary;
    [currentUser saveInBackground];
}

- (void)loadCategory:(OnboardingCategory)category
{
    self.currentlySelectedCategory = category;

    switch (category) {
        case OnboardingCategoryCrime:
            [self.crimeLabel setActive:YES];
            [self.classicLabel setActive:NO];
            [self.biographyLabel setActive:NO];
            [self.scienceLabel setActive:NO];
            [self.travelLabel setActive:NO];
            break;
        case OnboardingCategoryClassic:
            [self.crimeLabel setActive:NO];
            [self.classicLabel setActive:YES];
            [self.biographyLabel setActive:NO];
            [self.scienceLabel setActive:NO];
            [self.travelLabel setActive:NO];
            break;
        case OnboardingCategoryBiography:
            [self.crimeLabel setActive:NO];
            [self.classicLabel setActive:NO];
            [self.biographyLabel setActive:YES];
            [self.scienceLabel setActive:NO];
            [self.travelLabel setActive:NO];
            break;
        case OnboardingCategoryScience:
            [self.crimeLabel setActive:NO];
            [self.classicLabel setActive:NO];
            [self.biographyLabel setActive:NO];
            [self.scienceLabel setActive:YES];
            [self.travelLabel setActive:NO];
            break;
        case OnboardingCategoryTravel:
            [self.crimeLabel setActive:NO];
            [self.classicLabel setActive:NO];
            [self.biographyLabel setActive:NO];
            [self.scienceLabel setActive:NO];
            [self.travelLabel setActive:YES];
            break;
        default:
            break;
    }

    [self reloadImagesForCategory:category];
    [self changeTitleAccordingToCategory:category];
    [self resetButtons];
}

- (void)reloadImagesForCategory:(OnboardingCategory)category
{
    [self.collectionView reloadData];

    [self.view layoutIfNeeded];
}

- (void)changeTitleAccordingToCategory:(OnboardingCategory)category
{
    switch (category) {
        case OnboardingCategoryCrime:
            self.titleLabel.text = @"How likely are you to read a Crime book in the next time?";
            break;
        case OnboardingCategoryClassic:
            self.titleLabel.text = @"How likely are you to read a Classic book in the next time?";
            break;
        case OnboardingCategoryBiography:
            self.titleLabel.text = @"How likely are you to read a Biography book in the next time?";
            break;
        case OnboardingCategoryScience:
            self.titleLabel.text = @"How likely are you to read a Science book in the next time?";
            break;
        case OnboardingCategoryTravel:
            self.titleLabel.text = @"How likely are you to read a Travel book in the next time?";
            break;
        default:
            break;
    }
}

- (void)resetButtons
{
    for (RatingButton *button in self.ratingButtons) {
        [button setSelected:NO];
    }
}

#pragma mark - collectionView methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    UIImage *image = [self.imagesDataSource imagesArrayForOnboardingCategory:self.currentlySelectedCategory][indexPath.row];
    cell.imageView.image = image;

    cell.imageView.layer.cornerRadius = 4.0;

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imagesDataSource imagesArrayForOnboardingCategory:self.currentlySelectedCategory].count;
}

#pragma mark - view methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imagesDataSource = [[OnboardingDataSource alloc] init];
    [self customisation];

    self.onboardingFlowLayout = [[OnboardingFlowLayout alloc] init];
    self.collectionView.collectionViewLayout = self.onboardingFlowLayout;

    [self downloadQuotesInTheBackground];
}

- (void)downloadQuotesInTheBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        ParseDownloadManager *downloadManager = [[ParseDownloadManager alloc] init];
        [downloadManager downloadQuotes];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - customisation
- (void)customisation
{
    self.view.backgroundColor = [UIColor backgroundColor];
    [self customiseLabels];
    [self customiseCenterPopup];
    [self customiseRatingButtons];
    [self customiseSidePopups];

    self.collectionView.backgroundColor = [UIColor clearColor];

    [self loadCategory:OnboardingCategoryCrime];
}

- (void)customiseLabels
{
    [self.crimeLabel setActive:YES];
    [self.classicLabel setActive:NO];
    [self.biographyLabel setActive:NO];
    [self.scienceLabel setActive:NO];
    [self.travelLabel setActive:NO];

    self.titleLabel.textColor = [UIColor grayColorWithValue:55.0];

    self.notLikelyLabel.textColor = [UIColor globalGreenColor];
    self.likelyLabel.textColor = [UIColor globalGreenColor];
}

- (void)customiseCenterPopup
{
    self.separatorView.backgroundColor = [[UIColor grayColorWithValue:151.0] colorWithAlphaComponent:0.2];
    self.popupView.backgroundColor = [UIColor whiteColor];
}

- (void)customiseRatingButtons
{
    [self resetButtons];
    self.buttonsContainerView.backgroundColor = [UIColor clearColor];
}

- (void)customiseSidePopups
{

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
