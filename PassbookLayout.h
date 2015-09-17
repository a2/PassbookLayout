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

typedef struct PassMetrics {
    /// Size of a state of a pass
    CGSize size;
    
    /// Amount of "pixels" of overlap between this pass and others.
    CGFloat overlap;
} PassMetrics;

typedef struct PassbookLayoutMetrics {
    /// Normal is the real size of the pass, the "full screen" display of it.
    PassMetrics normal;
    
    /// Collapsed is when
    PassMetrics collapsed;
    
    /// The size of the bottom stack when a pass is selected and all others are stacked at bottom
    CGFloat bottomStackedTotalHeight;
    
    /// The visible size of each cell in the bottom stack
    CGFloat bottomStackedHeight;
} PassbookLayoutMetrics;

typedef struct PassbookLayoutEffects {
    /// How much of the pulling is translated into movement on the top. An inheritance of 0 disables this feature (same as bouncesTop)
    CGFloat inheritance;
    
    /// Allows for bouncing when reaching the top
    BOOL bouncesTop;
    
    /// Allows the cells get "stuck" on the top, instead of just scrolling outside
    BOOL sticksTop;
    
} PassbookLayoutEffects;

@interface PassbookLayout : UICollectionViewLayout

@property (nonatomic,assign) PassbookLayoutMetrics metrics;
@property (nonatomic,assign) PassbookLayoutEffects effects;

@end

NS_ASSUME_NONNULL_END
