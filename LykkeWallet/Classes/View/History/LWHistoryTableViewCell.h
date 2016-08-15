//
//  LWHistoryTableViewCell.h
//  LykkeWallet
//
//  Created by Alexander Pukhov on 10.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "TKTableViewCell.h"
#import "LWBaseHistoryItemType.h"


#define kHistoryTableViewCell           @"LWHistoryTableViewCell"
#define kHistoryTableViewCellIdentifier @"LWHistoryTableViewCellIdentifier"


@interface LWHistoryTableViewCell : TKTableViewCell {
    
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIImageView *operationImageView;
@property (weak, nonatomic) IBOutlet UILabel     *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel     *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;

@property LWHistoryItemType type;

@property BOOL showBottomLine;

@property (strong, nonatomic) NSNumber *volume;

-(void) update;

@end
