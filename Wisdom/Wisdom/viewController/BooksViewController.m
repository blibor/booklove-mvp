//
//  BooksViewController.m
//  Wisdom
//
//  Created by Sztanyi Szabolcs on 29/09/15.
//  Copyright © 2015 Zappdesigntemplates. All rights reserved.
//

#import "BooksViewController.h"
#import "BooksCollectionViewCell.h"
#import "BookCollectionObject.h"
#import "Parse.h"
#import "BookObject.h"
#import "LoadingImageView.h"
#import "ParseDownloadManager.h"
#import "ParseLocalStoreManager.h"
#import "BooksFlowLayout.h"
#import "BookGenre.h"
#import <Haneke/UIImageView+Haneke.h>
#import "AppDelegate.h"
#import "MainContainerViewController.h"

#define TRANSFORM_CELL_VALUE CGAffineTransformMakeScale(0.9, 0.9)
#define ANIMATION_SPEED 0.2

@interface BooksViewController ()
@property (nonatomic, strong) NSArray *booksArray;
@property (nonatomic, strong) ParseDownloadManager *downloadManager;
@property (nonatomic, strong) BooksFlowLayout *flowLayout;
@property (nonatomic) BOOL isfirstTimeTransform;
@end

@implementation BooksViewController

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBooksForDate:(NSDate*)date
{
    self.selectedDate = date;
    [self loadBooks];
}

- (void)loadBooksForGenre:(BookGenre*)genre
{
    self.selectedGenre = genre;
    [self loadBooks];
}

- (void)loadBooks
{
    [self.downloadManager downloadBooksForDate:self.selectedDate genre:self.selectedGenre withCompletionBlock:^(NSArray *books, NSString *errorMessage) {
        [self.collectionView hideLoadingIndicator];
        if (books) {
            self.booksArray = [books copy];
        } else {
            if (errorMessage) {

            }
        }
        [self.collectionView reloadData];
    }];
}

- (BookGenre*)selectedGenre
{
    if (!_selectedGenre) {
        _selectedGenre = [[BookGenre alloc] init];
        _selectedGenre.genreName = [GeneralSettings favoriteCategory];
    }

    return _selectedGenre;
}

- (NSMutableArray*)objectsToDisplay
{
    return [self.booksArray mutableCopy];
}

- (IBAction)bookFlipButtonPressed:(UIButton*)button
{
    UIView *aSuperview = [button superview];
    while (![aSuperview isKindOfClass:[BooksCollectionViewCell class]]) {
        aSuperview = [aSuperview superview];
    }

    BooksCollectionViewCell *cell = (BooksCollectionViewCell*)aSuperview;
    [cell flipToShowNormalView];
}

- (IBAction)bookmarkButtonPressed:(UIButton*)button
{
    UIView *aSuperview = [button superview];
    while (![aSuperview isKindOfClass:[BooksCollectionViewCell class]]) {
        aSuperview = [aSuperview superview];
    }

    BooksCollectionViewCell *cell = (BooksCollectionViewCell*)aSuperview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

    BookObject *book = self.objectsToDisplay[indexPath.row];

    if ([[ParseLocalStoreManager sharedManager] isBookSavedLocally:book]) {
        [[ParseLocalStoreManager sharedManager] removeObjectFromLocalStore:book];
    } else {
        [[ParseLocalStoreManager sharedManager] storeBookObjectLocally:book];
    }

    [cell.booksDetailView setupViewWithBookObject:book];
}

#pragma mark - collectionView methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BooksCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    BookObject *book = self.objectsToDisplay[indexPath.row];

    cell.titleLabel.text = book.bookTitle;

    if ([book isRecommended]) {
        cell.recommendWrapperView.alpha = 1.0;
        cell.recommendSeparatorLineView.alpha = 1.0;
        cell.recommendedByView.titleLabel.text = book.recommendedByUser.name;
        [cell.recommendedByView.recommendedView hnk_setImageFromURL:[NSURL URLWithString:book.recommendedByUser.imageURL]];
    } else {
        cell.recommendWrapperView.alpha = 0.0;
        cell.recommendSeparatorLineView.alpha = 0.0;
    }

    cell.subtitleLabel.text = book.sentence;
    [cell.bookCoverImageView hnk_setImageFromURL:[NSURL URLWithString:book.imageURL]];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objectsToDisplay.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BooksCollectionViewCell *cell = (BooksCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    if (!cell.cellFlipped) {
        BookObject *book = self.objectsToDisplay[indexPath.row];
        [cell flipToShowDetailViewWithBookObject:book];
    }
}

- (void)loadImagesForVisibleRows
{
    NSArray *visibleRows = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexpath in visibleRows) {
        if (indexpath.row < [self objectsToDisplay].count )
        {
            BaseImageModel *object = self.objectsToDisplay[indexpath.row];
            if (!object.image) {
                [self startImageDownloadForObject:object atIndexPath:indexpath];
            }
        }
    }
}

- (void)updateTableViewCellAtIndexPath:(NSIndexPath *)indexPath image:(UIImage *)image
{
    BooksCollectionViewCell *cell = (BooksCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        BookObject *book = self.objectsToDisplay[indexPath.row];
        book.image = image;
        cell.bookCoverImageView.image = image;
    }
}

- (ParseDownloadManager*)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [[ParseDownloadManager alloc] init];
    }

    return _downloadManager;
}

#pragma mark - view methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.isfirstTimeTransform = YES;

    self.flowLayout = [BooksFlowLayout layoutConfiguredWithCollectionView:self.collectionView
                                                                 itemSize:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - 40.0, CGRectGetHeight(self.collectionView.frame) - 60.0)
                                                        minimumLineSpacing:0];

    self.recommendedByLabel.text = @"";
    self.collectionTitleLabel.text = @"";

    [self.collectionView showLoadingIndicator];

    // opening from a collection
    if (self.selectedCollectionObject)
    {
        self.collectionViewTopBorderLayoutConstraint.constant = 40.0;
        [self.view layoutIfNeeded];

        [self.downloadManager downloadBooksForCollectionID:self.selectedCollectionObject.objectID withCompletionBlock:^(NSArray *books, NSString *errorMessage) {
            [self.collectionView hideLoadingIndicator];
            if (books) {
                self.booksArray = [books copy];
            } else {
                if (errorMessage) {
                    // handle error here
                }
            }

            self.backButton.hidden = NO;
            self.recommendedByLabel.hidden = NO;
            self.collectionTitleLabel.hidden = NO;

            self.collectionTitleLabel.text = self.selectedCollectionObject.title;
            self.recommendedByLabel.text = [self.selectedCollectionObject author];
            
            [self.collectionView reloadData];
        }];
    }
    else
    {
        if (self.bookToDiplay) { // displayed from library
            self.collectionViewTopBorderLayoutConstraint.constant = 40.0;
            [self.view layoutIfNeeded];

            [self.collectionView hideLoadingIndicator];
            self.booksArray = @[self.bookToDiplay];
            self.backButton.hidden = NO;
            self.recommendedByLabel.hidden = YES;
            self.collectionTitleLabel.hidden = YES;
            [self.collectionView reloadData];
        } else {
            [self loadBooks];
            self.backButton.hidden = YES;
            self.recommendedByLabel.hidden = YES;
            self.collectionTitleLabel.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
