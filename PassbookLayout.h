//
//  PassbookLayout.h
//  Passbooks
//
//  Created by Jose Luis Canepa on 3/3/14.
//  Copyright (c) 2014 Jose Luis Canepa. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for PassbookLayout.
FOUNDATION_EXPORT double PassbookLayoutVersionNumber;

//! Project version string for PassbookLayout.
FOUNDATION_EXPORT const unsigned char PassbookLayoutVersionString[];

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface PassbookLayout : UICollectionViewLayout

/// Normal is the real size of the pass, the "full screen" display of it.
@property (nonatomic, assign) IBInspectable CGSize normalSize;

/// Amount of "pixels" of overlap between this pass and others.
@property (nonatomic, assign) IBInspectable CGFloat normalOverlap;

/// Collapsed is when the cards stack at the bottom of the screen.
@property (nonatomic, assign) IBInspectable CGSize collapsedSize;

/// Amount of "pixels" of overlap between this pass and others.
@property (nonatomic, assign) IBInspectable CGFloat collapsedOverlap;

/// The size of the bottom stack when a pass is selected and all others are
/// stacked at bottom.
@property (nonatomic, assign) IBInspectable CGFloat bottomStackedTotalHeight;

/// The visible size of each cell in the bottom stack.
@property (nonatomic, assign) IBInspectable CGFloat bottomStackedHeight;

/// How much of the pulling is translated into movement on the top.
/// An inheritance of 0 disables this feature (same as bouncesTop)
@property (nonatomic, assign) IBInspectable CGFloat inheritance;

/// Allows for bouncing when reaching the top
@property (nonatomic, assign) IBInspectable BOOL bouncesTop;

/// Allows the cells get "stuck" on the top, instead of just scrolling outside
@property (nonatomic, assign) IBInspectable BOOL sticksTop;

@end

NS_ASSUME_NONNULL_END
