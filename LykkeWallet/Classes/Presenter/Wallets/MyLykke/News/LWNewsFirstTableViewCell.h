//
//  LWNewsFirstTableViewCell.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWNewsElementModel;

@interface LWNewsFirstTableViewCell : UITableViewCell

@property (strong, nonatomic) LWNewsElementModel *element;

@property (strong, nonatomic) LWNewsElementModel *element2;

@property id delegate;


@end


@protocol  LWNewsTableViewCellDelegate


-(void) newsCellPressedElement:(LWNewsElementModel *) element;

@end