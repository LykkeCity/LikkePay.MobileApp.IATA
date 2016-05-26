//
//  LWPacketGraphData.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 12/05/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAuthorizePacket.h"

@class LWGraphPeriodModel;

@interface LWPacketGraphData : LWAuthorizePacket

@property (strong, nonatomic) LWGraphPeriodModel *period;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *fixingTime;

@property (strong, nonatomic) NSArray *graphValues;
@property (strong, nonatomic) NSNumber *percentChange;

@end
