#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

#import "KMLParser.h"

#import "RisksViewController.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"


@interface RisksViewController () <MKMapViewDelegate>

@property (nonatomic) NSOperationQueue *processingQueue;
@property (nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

@property (nonatomic) IBOutlet MKMapView *map;

@property (nonatomic) KMLParser *kmlParser;

@property (nonatomic) NSArray *placemarkNames;

@property (nonatomic) NSArray *riskColors;

@end

@implementation RisksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeOutlets];
    
    self.map.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"doc" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    if ( url != nil )
    {
        [self processFile:url];
    }
}

- (NSArray *)riskColors
{
    if ( _riskColors == nil )
    {
        _riskColors = @[ [UIColor colorWithHex:@"059e4d"],
                         [UIColor colorWithHex:@"13d109"],
                         [UIColor colorWithHex:@"5eff00"],
                         [UIColor colorWithHex:@"cbff00"],
                         [UIColor colorWithHex:@"eeff00"],
                         [UIColor colorWithHex:@"ffeb00"],
                         [UIColor colorWithHex:@"ffb200"],
                         [UIColor colorWithHex:@"ff8a00"],
                         [UIColor colorWithHex:@"ff0d00"],
                         [UIColor colorWithHex:@"c40b06"]
                         ];
    }
    
    return _riskColors;
}

- (void)localizeOutlets
{
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"STANDARD", ) forSegmentAtIndex:0];
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"SATELLITE", ) forSegmentAtIndex:1];
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"HYBRID", ) forSegmentAtIndex:2];
}

- (void)processFile:(NSURL *)fileURL
{
    if ( fileURL == nil )
    {
        return;
    }
    
    self.kmlParser = [[KMLParser alloc] initWithURL:fileURL];
    [self.kmlParser parseKML];
    
    NSArray *overlays = [self.kmlParser overlays];
    NSArray *annotations = [self.kmlParser points];
    
    NSString *filename = fileURL.lastPathComponent;
    
    [self addOverlays:overlays annotations:annotations filename:filename];
    
    NSArray *placemarks = self.kmlParser.placemarksNonMutable;
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:placemarks.count];
    for ( KMLPlacemark *placemark in placemarks )
    {
        [names addObject:placemark.name ? : @"1"];
    }
    self.placemarkNames = [NSArray arrayWithArray:names];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

- (void)addOverlays:(NSArray *)overlays annotations:(NSArray *)annotations filename:(NSString *)filename
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self.map addOverlays:overlays];
         [self.map addAnnotations:annotations];
     }];
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    NSLog(@"Class is %@", NSStringFromClass([overlay class]));
    
    if ( [overlay isKindOfClass:[MKPolygon class]] )
    {

        NSInteger index = [self.map.overlays indexOfObject:overlay];
        NSString *name = self.placemarkNames[index];
        NSInteger riskNumber = [name integerValue];
        UIColor *color = self.riskColors[riskNumber];
        
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonRenderer.fillColor = [color colorWithAlphaComponent:0.6];
        polygonRenderer.strokeColor = color;
        polygonRenderer.lineWidth = 2.0;
        
        return polygonRenderer;
    }

    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.kmlParser viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSInteger index = 0;
    for ( MKPolygon *polygon in self.map.overlays )
    {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(self.map.centerCoordinate);
        MKMapPoint currentMapPoint = mapPoint;
        CGPoint polygonViewPoint = [polygonRenderer pointForMapPoint:currentMapPoint];
        
        if ( CGPathContainsPoint(polygonRenderer.path, nil, polygonViewPoint, true) )
        {
            NSLog(@"Inside Risk: %@", self.placemarkNames[index]);
            
        }
        ++index;
    }
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex )
    {
        case 0:
            self.map.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.map.mapType = MKMapTypeSatellite;
            break;
        default:
            self.map.mapType = MKMapTypeHybrid;
            break;
    }
}

@end
