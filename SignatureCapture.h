#import <UIKit/UIKit.h>

@interface SignatureCapture : UIView

- (id)initWithFrame:(CGRect)aFrame backgroundImage:(NSString*)backgroundImage;

- (void)clear;
- (UIImage*)getImageRepresentation;
- (NSString*)getStringRepresentation;

@property bool hasContent;

@end
