#import "SCHAbstractRenderer.h"


@class SCHAbstractPoint;
@class SCHPaintInfo;


@interface SCHFastLinearRenderer : SCHAbstractRenderer

- (instancetype)init;

- (void)preDraw:(CGContextRef)c;

- (void)drawPoint:(CGContextRef)c PaintInfo:(SCHSeriesPaintInfo *)pinfo
               X1:(CGFloat)x1 X2:(CGFloat)x2 Point:(SCHAbstractPoint *)p;

@end
