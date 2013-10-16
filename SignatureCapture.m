#import "SignatureCapture.h"
#import <QuartzCore/QuartzCore.h>

@implementation SignatureCapture {
    UIBezierPath *path;
    CGPoint previousPoint;
    NSMutableArray *paths;
    NSMutableArray *currentPath;
}

@synthesize hasContent;

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        // Create a path to connect lines
        path = [UIBezierPath bezierPath];
        
        paths = [[NSMutableArray alloc] init];
        hasContent = NO;
        // Capture touches
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)aFrame backgroundImage:(NSString*)backgroundImage {
    self = [self initWithFrame:aFrame];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [backgroundImageView setImage:[UIImage imageNamed: backgroundImage]];
    [self addSubview:backgroundImageView];
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [path moveToPoint:currentPoint];
        currentPath = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:currentPoint]];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
        [currentPath addObject:[NSValue valueWithCGPoint:midPoint]];
        [currentPath addObject:[NSValue valueWithCGPoint:currentPoint]];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        if (currentPath != nil) {
            [paths addObject: currentPath];
            hasContent = YES;
        }
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}

- (void)clear {
    path = [UIBezierPath bezierPath];
    paths = [[NSMutableArray alloc] init];
    [self setNeedsDisplay];
}

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [path stroke];
}

- (UIImage*)getImageRepresentation {
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (NSString*)getStringRepresentation {
    
    NSString *retString = @"";
    for (NSArray *pathArray in paths) {
        bool firstPoint = YES;
        for(NSValue *pointValue in pathArray){
            CGPoint point = [pointValue CGPointValue];
            if (firstPoint) {
                firstPoint = NO;
                retString = [retString stringByAppendingFormat:
                             @"s:%f,%f;", point.x, point.y];
            } else {
                retString = [retString stringByAppendingFormat:
                             @"p:%f,%f;", point.x, point.y];
            }
        }
    }
    return retString;
    
}

@end
