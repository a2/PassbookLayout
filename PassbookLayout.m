//
//  PassbookLayout.m
//  Passbooks
//
//  Created by Jose Luis Canepa on 3/3/14.
//  Copyright (c) 2014 Jose Luis Canepa. All rights reserved.
//

#import "PassbookLayout.h"

#if CGFLOAT_IS_DOUBLE
    #define floorcg(x) floor(x)
    #define ceilcg(x) ceil(x)
#else
    #define floorcg(x) floorf(x)
    #define ceilcg(x) ceilf(x)
#endif

@implementation PassbookLayout

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultValues];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultValues];
    }
    
    return self;
}

- (void)setDefaultValues
{
    _normalSize = CGSizeMake(320, 420);
    _normalOverlap = 0;
    _collapsedSize = CGSizeMake(320, 96);
    _collapsedOverlap = 32;
    _bottomStackedHeight = 8;
    _bottomStackedTotalHeight = 32;
    _inheritance = 0.2;
    _sticksTop = YES;
    _bouncesTop = YES;
}

#pragma mark - Private Helpers

- (CGRect)frameForSelectedPass
{
    const CGRect bounds = self.collectionView.bounds;

    CGRect frame;
    frame.size = _normalSize;
    frame.origin.x = (bounds.size.width - frame.size.width) / 2.0;
    frame.origin.y = bounds.origin.y + (bounds.size.height - frame.size.height) / 2.0;
    return frame;
}

- (CGRect)frameForUnselectedPassAtIndexPath:(NSIndexPath *)indexPath selectedIndexPath:(NSIndexPath *)selectedIndexPath isHidden:(out BOOL *)outHidden
{
    const CGRect bounds = self.collectionView.bounds;

    CGRect frame;
    frame.size = _collapsedSize;
    frame.origin.x = (bounds.size.width - _normalSize.width) / 2.0;
    frame.origin.y = bounds.origin.y + bounds.size.height - _bottomStackedTotalHeight + _bottomStackedHeight * (indexPath.item - selectedIndexPath.item);

    if (outHidden) {
        *outHidden = frame.origin.y > bounds.origin.y + bounds.size.height;
    }

    return frame;
}

- (CGRect)frameForPassAtIndexPath:(NSIndexPath *)indexPath isHidden:(out BOOL *)outHidden
{
    const CGRect bounds = self.collectionView.bounds;
    const NSInteger count = [self.collectionView numberOfItemsInSection:0];

    BOOL hidden = NO;

    CGRect frame;
    frame.origin.x = (bounds.size.width - _normalSize.width) / 2.0;
    frame.origin.y = indexPath.item * (_collapsedSize.height - _collapsedOverlap);

    // The default size is the normal size
    frame.size = _collapsedSize;

    if (_bouncesTop && bounds.origin.y < 0 && _inheritance > 0) {
        // Bouncy effect on top (works only on constant invalidation)
        if (indexPath.section == 0 && indexPath.item == 0) {
            // Keep stuck at top
            frame.origin.y = bounds.origin.y * _inheritance / 2.0;
            frame.size.height = _collapsedSize.height - bounds.origin.y * (1 + _inheritance);
        } else {
            // Displace in stepping amounts factored by resitatnce
            frame.origin.y -= bounds.origin.y * indexPath.item * _inheritance;
            frame.size.height -= bounds.origin.y * _inheritance;
        }
    } else if (_sticksTop && bounds.origin.y > 0 && frame.origin.y < bounds.origin.y) {
        if (count > indexPath.item + 1 && (indexPath.item + 1) * (_collapsedSize.height - _collapsedOverlap) < bounds.origin.y) {
            hidden = YES;
        }

        // Stick to top
        frame.origin.y = bounds.origin.y;
    }

    // Edge case: if it's the last cell, display in full height to avoid any issues.
    if (indexPath.item == [self.collectionView numberOfItemsInSection:indexPath.section] - 1) {
        frame.size = _normalSize;
    }

    if (outHidden) {
        *outHidden = hidden;
    }

    return frame;
}

- (NSRange)rangeOfVisibleCellsInRect:(CGRect)rect
{
    const NSInteger count = [self.collectionView numberOfItemsInSection:0];

    NSInteger min = floorcg(rect.origin.y / (_collapsedSize.height - _collapsedOverlap));
    NSInteger max = ceilcg((rect.origin.y + rect.size.height) / (_collapsedSize.height - _collapsedOverlap));

    if (max > count) {
        max = count;
    }

    if (min < 0) {
        min = 0;
    } else if (min > max) {
        min = max;
    }

    return NSMakeRange(min, max - min);

}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];

    if ([self.collectionView numberOfSections] != 1) {
        NSLog(@"PassbookLayout currenly supports single-section collection views only.");
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.zIndex = indexPath.item;

    NSArray <NSIndexPath *>*selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];

    if ([selectedIndexPaths.firstObject isEqual:indexPath]) {
        // Layout selected cell (normal size)
        attributes.frame = [self frameForSelectedPass];
    } else if (selectedIndexPaths.count) {
        // Layout unselected cell (bottom-stuck)
        BOOL hidden;
        attributes.frame = [self frameForUnselectedPassAtIndexPath:indexPath selectedIndexPath:selectedIndexPaths[0] isHidden:&hidden];
        attributes.hidden = hidden;
    } else {
        // Layout collapsed cells (collapsed size)
        BOOL hidden;
        attributes.frame = [self frameForPassAtIndexPath:indexPath isHidden:&hidden];
        attributes.hidden = hidden;
    }

    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSRange range = [self rangeOfVisibleCellsInRect:rect];
    NSMutableArray <UICollectionViewLayoutAttributes *>*cells = [NSMutableArray arrayWithCapacity:range.length];

    for (NSUInteger i = range.location; i < range.location + range.length; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [cells addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }

    return cells;
}

- (CGSize)collectionViewContentSize
{
    const CGRect bounds = self.collectionView.bounds;
    const NSInteger count = [self.collectionView numberOfItemsInSection:0];

    return CGSizeMake(bounds.size.width, count * (_collapsedSize.height - _collapsedOverlap));
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - Accessors

- (void)setNormalSize:(CGSize)normalSize
{
    if (CGSizeEqualToSize(normalSize, _normalSize)) {
        return;
    }

    _normalSize = normalSize;
    [self invalidateLayout];
}

- (void)setNormalOverlap:(CGFloat)normalOverlap
{
    if (normalOverlap == _normalOverlap) {
        return;
    }

    _normalOverlap = normalOverlap;
    [self invalidateLayout];
}

- (void)setCollapsedSize:(CGSize)collapsedSize
{
    if (CGSizeEqualToSize(collapsedSize, _collapsedSize)) {
        return;
    }

    _collapsedSize = collapsedSize;
    [self invalidateLayout];
}

- (void)setCollapsedOverlap:(CGFloat)collapsedOverlap
{
    if (collapsedOverlap == _collapsedOverlap) {
        return;
    }

    _collapsedOverlap = collapsedOverlap;
    [self invalidateLayout];
}

- (void)setBottomStackedTotalHeight:(CGFloat)bottomStackedTotalHeight
{
    if (bottomStackedTotalHeight == _bottomStackedHeight) {
        return;
    }

    _bottomStackedTotalHeight = bottomStackedTotalHeight;
    [self invalidateLayout];
}

- (void)setBottomStackedHeight:(CGFloat)bottomStackedHeight
{
    if (bottomStackedHeight == _bottomStackedHeight) {
        return;
    }

    _bottomStackedHeight = bottomStackedHeight;
    [self invalidateLayout];
}

- (void)setInheritance:(CGFloat)inheritance
{
    if (inheritance == _inheritance) {
        return;
    }

    _inheritance = inheritance;
    [self invalidateLayout];
}

- (void)setBouncesTop:(BOOL)bouncesTop
{
    if (bouncesTop == _bouncesTop) {
        return;
    }

    _bouncesTop = bouncesTop;
    [self invalidateLayout];
}

- (void)setSticksTop:(BOOL)sticksTop
{
    if (sticksTop == _sticksTop) {
        return;
    }

    _sticksTop = sticksTop;
    [self invalidateLayout];
}

@end
