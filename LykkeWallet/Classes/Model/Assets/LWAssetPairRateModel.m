//
//  LWAssetPairRateModel.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 04.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetPairRateModel.h"


@implementation LWAssetPairRateModel


#pragma mark - LWJSONObject

- (instancetype)initWithJSON:(id)json {
    self = [super initWithJSON:json];
    if (self && ![json isKindOfClass:[NSNull class]]) {
        _identity    = [json objectForKey:@"Id"];
        _bid         = [json objectForKey:@"Bid"];
        _ask         = [json objectForKey:@"Ask"];
        _pchng       = [json objectForKey:@"PChng"];
        _expTimeout  = [json objectForKey:@"ExpTimeOut"];
        _lastChanges = [json objectForKey:@"ChngGrph"];
        _inverted    = [[json objectForKey:@"Inverted"] boolValue];
        
        if(_inverted)
        {
            [self invert];
            _inverted=YES;
        }
    }
    return self;
}

-(void) invert
{
    _inverted=!_inverted;
    if(_bid.floatValue!=0)
        _bid=@(1.0/_bid.floatValue);
    if(_ask.floatValue!=0)
        _ask=@(1.0/_ask.floatValue);
    NSMutableArray *newLastChanges=[[NSMutableArray alloc] init];
    for(NSNumber *n in _lastChanges)
    {
        [newLastChanges addObject:@(1.0-n.floatValue)];
    }
    _lastChanges=newLastChanges;
    
    
}

@end
