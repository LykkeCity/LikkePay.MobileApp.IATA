//
//  LWPrivateWalletsManager.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 22/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWPrivateWalletModel;
@class LWPKBackupModel;

@interface LWPrivateWalletsManager : NSObject

@property (strong, nonatomic) NSArray *wallets;

-(void) loadWalletsWithCompletion:(void(^)(NSArray *)) completion;
-(void) loadWalletBalances:(NSString *) address withCompletion:(void (^)(NSArray *))completion;

-(void) loadHistoryForWallet:(NSString *) address withCompletion:(void(^)(NSArray *)) completion;

-(void) addNewWallet:(LWPrivateWalletModel *) wallet   withCompletion:(void (^)(BOOL))completion;
-(void) deleteWallet:(NSString *) address withCompletion:(void (^)(BOOL))completion;

-(void) backupPrivateKeyWithModel:(LWPKBackupModel *) model  withCompletion:(void (^)(BOOL))completion;

+ (instancetype) shared;

@end
