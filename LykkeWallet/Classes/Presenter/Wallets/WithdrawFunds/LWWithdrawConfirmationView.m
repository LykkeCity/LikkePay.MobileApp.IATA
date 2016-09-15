//
//  LWWithdrawConfirmationView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 31.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWWithdrawConfirmationView.h"
#import "LWAssetInfoTextTableViewCell.h"
#import "LWPinKeyboardView.h"
#import "LWLoadingIndicatorView.h"
#import "LWAuthManager.h"
#import "LWConstants.h"
#import "LWValidator.h"
#import "LWCache.h"
#import "Macro.h"
#import "UIView+Navigation.h"


@interface LWWithdrawConfirmationView ()<UITableViewDataSource, LWPinKeyboardViewDelegate> {
    LWPinKeyboardView *pinKeyboardView;
    BOOL               isRequested;
        UIView *shadowView;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView           *topView;
@property (weak, nonatomic) IBOutlet UIView           *bottomView;
@property (weak, nonatomic) IBOutlet UITableView      *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar  *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIButton         *placeOrderButton;
@property (weak, nonatomic) IBOutlet UILabel          *waitingLabel;
@property (weak, nonatomic) IBOutlet LWLoadingIndicatorView *waitingImageView;

@property (weak, nonatomic) IBOutlet UIView *touchCatchView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;


#pragma mark - Properties

@property (weak, nonatomic) id<LWWithdrawConfirmationViewDelegate> delegate;


#pragma mark - Utils

- (void)requestOperation;
- (void)cancelOperation;
- (void)updateView;
- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name;

@end


@implementation LWWithdrawConfirmationView

static int const kDescriptionRows = 2;
static float const kPinProtectionHeight = 444;
static float const kNoPinProtectionHeight = 356;


-(void) awakeFromNib
{
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClicked:)];
    [self.touchCatchView addGestureRecognizer:gesture];
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        _topViewHeightConstraint.constant=520;
    }

}

#pragma mark - General

+ (LWWithdrawConfirmationView *)modalViewWithDelegate:(id<LWWithdrawConfirmationViewDelegate>)delegate {
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWWithdrawConfirmationView"
                                                  owner:self options:nil] objectAtIndex:0];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view sizeToFit];
    
    LWWithdrawConfirmationView *result = (LWWithdrawConfirmationView *)view;
    [result setDelegate:delegate];
    [result updateView];
    return result;
}


#pragma mark - Actions

- (void)cancelClicked:(id)sender {
    [self cancelOperation];
}

- (IBAction)confirmClicked:(id)sender {
    [self requestOperation];
}


#pragma mark - Utils

- (void)requestOperation {
    [self setLoading:YES withReason:Localize(@"withdraw.funds.modal.waiting")];
    [self.delegate requestOperationWithHud:NO];
}

- (void)pinRejected {
    [self setLoading:NO withReason:@""];
    if (pinKeyboardView) {
        [pinKeyboardView pinRejected];
    }
}

- (void)cancelOperation {
    [self.delegate cancelClicked];
    [self hide];
}

- (void)updateView {

    
//    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.backgroundColor=nil;
    
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.opaque = NO;
    
    BOOL const shouldSignOrder = [LWCache instance].shouldSignOrder;
    if (shouldSignOrder) {
        pinKeyboardView = [LWPinKeyboardView new];
        pinKeyboardView.delegate = self;
        pinKeyboardView.hidden = !shouldSignOrder;
        [pinKeyboardView updateView];
        [self.bottomView addSubview:pinKeyboardView];
        pinKeyboardView.frame=self.bottomView.bounds;
        pinKeyboardView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    else {
        if (pinKeyboardView) {
            [pinKeyboardView removeFromSuperview];
            pinKeyboardView = nil;
        }
    }
  
    if(shouldSignOrder==NO)
        self.topViewHeightConstraint.constant=kNoPinProtectionHeight;

//    self.topViewHeightConstraint.constant = (shouldSignOrder ? kPinProtectionHeight : kNoPinProtectionHeight);
    self.placeOrderButton.hidden = shouldSignOrder;
    
    self.waitingLabel.text = Localize(@"withdraw.funds.modal.waiting");
    [self.navigationItem setTitle:Localize(@"withdraw.funds.modal.title")];
    
    [LWValidator setButton:self.placeOrderButton enabled:YES];
    
    [self.placeOrderButton setTitle:Localize(@"withdraw.funds.modal.button")
                           forState:UIControlStateNormal];

    
    NSString *cancelTitle = Localize(@"withdraw.funds.modal.cancel");
    [self setCancelButtonWithTitle:cancelTitle
                        navigation:self.navigationItem
                            target:self
                          selector:@selector(cancelClicked:)];
    
    self.placeOrderButton.hidden = NO;
    
    [self registerCellWithIdentifier:@"LWAssetInfoTextTableViewCellIdentifier"
                                name:@"LWAssetInfoTextTableViewCell"];
    
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setLoading:NO withReason:@""];
}

- (void)setLoading:(BOOL)loading withReason:(NSString *)reason {
    isRequested = loading;
    
    self.navigationItem.leftBarButtonItem.enabled = !loading;
    self.placeOrderButton.hidden = loading;
    self.waitingLabel.hidden = !loading;
    self.waitingLabel.text = reason;
    
    if (pinKeyboardView) {
        pinKeyboardView.hidden = loading;
    }
    
    [self.waitingImageView setLoading:loading];
}

- (void)registerCellWithIdentifier:(NSString *)identifier name:(NSString *)name {
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (CGFloat)calculateRowHeightForText:(NSString *)text {
    CGFloat const kDefaultRowHeight = 50.0;
    CGFloat const kTopBottomPadding = 8.0;
    CGFloat const kLeftRightPadding = 26.0 * 2.0;
    CGFloat const kTitleWidth = 116.0;
    CGFloat const kDescriptionWidth = self.tableView.frame.size.width - kLeftRightPadding - kTitleWidth;
    
    UIFont *font = [UIFont fontWithName:kFontRegular size:kAssetDetailsFontSize];
    CGSize const size = CGSizeMake(kDescriptionWidth, CGFLOAT_MAX);
    CGRect rect = [text boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    
    CGFloat const cellHeight = MAX(kDefaultRowHeight, rect.size.height + kTopBottomPadding * 2.0);
    return cellHeight;
}

- (NSString *)dataByCellRow:(NSInteger)row {
    NSString *const values[kDescriptionRows] = {
        self.bitcoinString,
        self.amountString
    };
    return values[row];
}

-(void) hide
{
    [UIView animateWithDuration:0.5 animations:^{
        shadowView.alpha=0;
        self.iPadNavShadowView.alpha=0;
        self.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height*1.5);
    } completion:^(BOOL finished){
            [self.iPadNavShadowView removeFromSuperview];
            [shadowView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

-(void) show
{
    shadowView=[[UIView alloc] initWithFrame:self.superview.bounds];
    shadowView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.5];
    shadowView.alpha=0;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.superview insertSubview:shadowView belowSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        shadowView.alpha=1;
        self.iPadNavShadowView.alpha=1;
    }];
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kDescriptionRows;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const titles[kDescriptionRows] = {
        [self.assetId isEqualToString:@"BTC"]?@"Bitcoin address":@"Colored coin address",//     Localize(@"withdraw.funds.modal.cell.address"),
        Localize(@"withdraw.funds.modal.cell.amount")
    };
    
    NSString *const values[kDescriptionRows] = {
        self.bitcoinString,
        self.amountString
    };
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LWAssetInfoTextTableViewCellIdentifier"];
    
    LWAssetInfoTextTableViewCell *textCell = (LWAssetInfoTextTableViewCell *)cell;
    textCell.titleLabel.text = titles[indexPath.row];
    textCell.descriptionLabel.text = values[indexPath.row];
    
    //[cell setWhitePalette];
    //cell.titleLabel.text = titles[indexPath.row];
    //cell.detailLabel.text = values[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *text = [self dataByCellRow:indexPath.row - 1];
//    if (text) {
//        return [self calculateRowHeightForText:text];
//    }
//    return 0.0;
//}


#pragma mark - LWPinKeyboardViewDelegate

- (void)pinEntered:(NSString *)pin {
    [self.delegate checkPin:pin];
}

- (void)pinCanceled {
    [self hide];
    [self.delegate cancelClicked];
}

- (void)pinAttemptEnds {
    [self hide];
    [self.delegate noAttemptsForPin];
}

-(void) dealloc
{
    
}

@end
