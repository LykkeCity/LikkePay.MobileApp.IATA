//
//  LWGenerateKeyPresenter.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthComplexPresenter.h"


@interface LWGenerateKeyPresenter : LWAuthComplexPresenter

@property BOOL flagSkipIntro;
@property id delegate;

@end

@protocol LWGenerateKeyPresenterDelegate

-(void) generateKeyPresenterFinished:(LWGenerateKeyPresenter *) presenter;

@end
