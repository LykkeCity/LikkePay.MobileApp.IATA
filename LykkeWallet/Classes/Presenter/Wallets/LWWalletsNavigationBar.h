//
//  LWWalletsNavigationBar.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWalletsNavigationBar : UINavigationBar



@end


@protocol LWWalletsNavigationBarDelegate

-(void) walletsNavigationBarPressedPrivateWallets;
-(void) walletsNavigationBarPressedTradingWallets;

@end