#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

#import "KMLParser.h"

#import "RisksViewController.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"
#import "ClimateDownloader.h"

@interface RisksViewController () <MKMapViewDelegate>

@property (nonatomic) NSOperationQueue *processingQueue;

@property (nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic) IBOutlet UILabel *mapSelectLabel;
@property (nonatomic) IBOutlet UIView *mapTypeView;
@property (nonatomic) IBOutlet UIView *messageView;
@property (nonatomic) IBOutlet UIButton *calculateRiskButton;
@property (nonatomic) IBOutlet UIImageView *warningImageView;

@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) IBOutlet UIImageView *peg;
@property (nonatomic) IBOutlet NSLayoutConstraint *pegToBottom;

@property (nonatomic) KMLParser *kmlParser;

@property (nonatomic) NSArray *placemarkNames;

@property (nonatomic) NSArray *riskColors;

@property (nonatomic) BOOL shouldShare;

@end

@implementation RisksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeOutlets];
    
    self.map.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"economico" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    if ( url != nil )
    {
        [self processFile:url];
    }
    
    UIImage *pegImage = self.peg.image;
    UIImage *paintableImage = [pegImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.peg.image = paintableImage;
    
    [UIHelper configureDestructiveButton:self.calculateRiskButton];
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
    self.mapSelectLabel.text = NSLocalizedString(@"SELECTION PROMPT", );
    [self.calculateRiskButton setTitle:NSLocalizedString(@"CALCULATE RISK", ) forState:UIControlStateNormal];
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.peg.hidden = YES;
    self.mapTypeView.hidden = NO;
    [self.calculateRiskButton setTitle:NSLocalizedString(@"CALCULATE RISK", ) forState:UIControlStateNormal];
    [UIHelper configureDestructiveButton:self.calculateRiskButton];
    self.shouldShare = NO;
    self.warningImageView.image = [UIImage imageNamed:@"warning-red"];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ( [overlay isKindOfClass:[MKPolygon class]] )
    {

        NSInteger index = [self.map.overlays indexOfObject:overlay];
        NSString *name = self.placemarkNames[index];
        NSInteger riskNumber = [name integerValue];
        UIColor *color = self.riskColors[riskNumber];
        
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonRenderer.fillColor = [color colorWithAlphaComponent:0.4];
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

- (double)calculateRiskForProbability:(double)precipProbability intensity:(double)precipIntensity staticRisk:(double)staticRisk
{
    double normalizacionMilimetros = (precipIntensity * 25.4) / 100.0;
    double normalizacionInundabilidad = staticRisk / 10.0;
    
    double weightFlood = 0.4;
    double weightPrecip = 0.6;
    
    if ( normalizacionMilimetros > 0.4 )
    {
        if ( staticRisk < 3 )
        {
            weightFlood = 0.6;
            weightPrecip = 0.4;
        }
        
    }
    
    
    double result = (pow(normalizacionInundabilidad, 2.0) * weightFlood ) + ( weightPrecip * sqrt(normalizacionMilimetros));
    
    return MAX(0.0, MIN(1.0, result));
}

- (void)processWeatherData:(NSDictionary *)weather riskString:(NSString *)riskStr
{
    double staticRisk = [riskStr floatValue];
    NSDictionary *daily = weather[@"daily"];
    NSArray *data = daily[@"data"];
    
    double maxRisk = 0.0;
    
    if  (self.map.mapType == MKMapTypeSatellite )
    {
        maxRisk = [self calculateRiskForProbability:0.7 intensity:(85.0/25.4) staticRisk:staticRisk];
    }
    else
    {
        for ( NSDictionary *dailyData in data )
        {
            double precipProbability = [dailyData[@"precipProbability"] doubleValue];
            double precipIntensity = [dailyData[@"precipIntensity"] doubleValue];
            
            double calculatedRisk = 0;
            
            calculatedRisk = [self calculateRiskForProbability:precipProbability intensity:precipIntensity staticRisk:staticRisk];
            
            maxRisk = MAX(maxRisk,  calculatedRisk);
        }
    }
    
    double risk = maxRisk * 10.0;
    
    NSInteger index = (NSInteger) risk;
    UIColor *color = self.riskColors[MIN(index, self.riskColors.count - 1)];
    self.peg.tintColor = color;
    
    self.pegToBottom.constant = - ((risk / 10.0) * self.view.frame.size.height);
    self.peg.hidden = NO;
    self.mapTypeView.hidden = YES;
    
    [self.calculateRiskButton setTitle:NSLocalizedString(@"SHARE", ) forState:UIControlStateNormal];
    [UIHelper configureButton:self.calculateRiskButton];
    self.shouldShare = YES;
    self.warningImageView.image = [UIImage imageNamed:@"compartir-1"];
    
    [self.view layoutIfNeeded];
}

- (void)foundRisk:(NSString *)riskStr
{
    CLLocationDegrees latitude = self.map.centerCoordinate.latitude;
    CLLocationDegrees longitude = self.map.centerCoordinate.longitude;
    
    if ( self.map.mapType == MKMapTypeSatellite )
    {
        [self processWeatherData:nil riskString:riskStr];
    }
    else
    {
        [[ClimateDownloader instance] downloadLatitude:latitude
                                             longitude:longitude
                                              callback:^(NSDictionary *information, NSError *error)
         {
             if ( error == nil )
             {
                 [self processWeatherData:information riskString:riskStr];
             }
         }];
    }
}

- (void)shareThis
{
    self.messageView.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0f);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSArray *items = @[snapshotImageFromMyView];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    [self.navigationDelegate.mainNavigationController presentViewController:controller
                                                                   animated:YES
                                                                 completion:^
     {
         self.messageView.hidden = NO;
     }];
}

- (IBAction)calculateRisk:(id)sender
{
    if ( self.shouldShare )
    {
        [self shareThis];
        return;
    }
    
    NSInteger index = 0;
    BOOL foundRisk = NO;
    for ( MKPolygon *polygon in self.map.overlays )
    {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(self.map.centerCoordinate);
        MKMapPoint currentMapPoint = mapPoint;
        CGPoint polygonViewPoint = [polygonRenderer pointForMapPoint:currentMapPoint];
        
        if ( CGPathContainsPoint(polygonRenderer.path, nil, polygonViewPoint, true) )
        {
            foundRisk = YES;
            
            [self foundRisk:self.placemarkNames[index]];
        }
        ++index;
    }
    
    if ( ! foundRisk )
    {
        [UIHelper showAlertWithTitle:NSLocalizedString(@"NO RISK FOUND", )
                             message:NSLocalizedString(@"NO RISK MESSAGE", )
                   cancelButtonTitle:NSLocalizedString(@"OK", )
                    inViewController:self.navigationDelegate.mainNavigationController];
    }
}

@end
