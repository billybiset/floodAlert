#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

#import "KMLParser.h"

#import "RisksViewController.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"


@interface RisksViewController () <MKMapViewDelegate>

@property (nonatomic) NSOperationQueue *processingQueue;

@property (nonatomic) IBOutlet MKMapView *map;
@property (nonatomic) IBOutlet UIView *menuView;
@property (nonatomic) IBOutlet UIView *menuDetailsView;
@property (nonatomic) IBOutlet UIView *mapCoverView;
@property (nonatomic) IBOutlet NSLayoutConstraint *menuViewHeight;
@property (nonatomic) IBOutlet NSLayoutConstraint *menuViewWidth;
@property (nonatomic) IBOutlet UIButton *openMenuButton;

@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UILabel *mapLabel;
@property (nonatomic) IBOutlet UILabel *waterLabel;
@property (nonatomic) IBOutlet UILabel *shareLabel;

@property (nonatomic) IBOutlet UIButton *locationDetailsButton;

@property (nonatomic) IBOutlet UIButton *dateButton;
@property (nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic) IBOutlet UISegmentedControl *waterTypeSegmentedControl;

@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSDate *currentDate;

@property (nonatomic) CGFloat squareHeight;
@property (nonatomic) NSMutableSet *loadedFiles;

@property (nonatomic) KMLParser *kmlParser;

@property (nonatomic) NSMutableDictionary *filenamesToOverlays;
@property (nonatomic) NSMutableDictionary *filenamesToAnnotations;

@end

@implementation RisksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeOutlets];
    
    self.map.delegate = self;
    
    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:@"inundacion" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self processFile:url];
     */
}


- (void)localizeOutlets
{
}
/*
    [self.shareButton setTitle:NSLocalizedString(@"SHARE",) forState:UIControlStateNormal];
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"STANDARD", ) forSegmentAtIndex:0];
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"SATELLITE", ) forSegmentAtIndex:1];
    [self.mapTypeSegmentedControl setTitle:NSLocalizedString(@"HYBRID", ) forSegmentAtIndex:2];
    [self.waterTypeSegmentedControl setTitle:NSLocalizedString(@"SURFACE WATER", ) forSegmentAtIndex:0];
    [self.waterTypeSegmentedControl setTitle:NSLocalizedString(@"FLOOD WATER", ) forSegmentAtIndex:1];
    self.dateLabel.text = NSLocalizedString(@"DATE",);
    self.locationLabel.text = NSLocalizedString(@"LOCATION",);
    self.mapLabel.text = NSLocalizedString(@"MAP",);
    self.waterLabel.text = NSLocalizedString(@"WATER",);
    self.shareLabel.text = NSLocalizedString(@"SHARE",);
}


- (NSDateFormatter *)dateFormatter
{
    if ( _dateFormatter == nil )
    {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    return _dateFormatter;
}

- (void)changeDate:(NSDate *)date
{
    [self hideMenuDetailsIfNecessary];
    
    if ( date == nil )
    {
        //Default is yesterday
        date = [[NSDate date] dateByAddingTimeInterval:-(24 * 60 * 60 * 1)];
    }
    
    if ( self.currentDate != date )
    {
        NSString *buttonText = [self.dateFormatter stringFromDate:date];
        
        [self.dateButton setTitle:buttonText forState:UIControlStateNormal];
        
        if ( self.currentDate != nil )
        {
            [self resetAnnotations];
            self.currentDate = date;
            [self loadAnnotations];
        }
        else
        {
            self.currentDate = date;
        }
    }
}

- (void)addOverlays:(NSArray *)overlays annotations:(NSArray *)annotations filename:(NSString *)filename
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         if ( [self useMemoryCaching] )
         {
             self.filenamesToOverlays[filename] = overlays;
             self.filenamesToAnnotations[filename] = annotations;
         }
         
         [self.map addOverlays:overlays];
         [self.map addAnnotations:annotations];
         
         [self.loadedFiles addObject:filename];
    }];
}
 */

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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

- (void)addOverlays:(NSArray *)overlays annotations:(NSArray *)annotations filename:(NSString *)filename
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [self.map addOverlays:[overlays subarrayWithRange:NSMakeRange(0, MIN(100, overlays.count - 1)) ]];
         [self.map addAnnotations:annotations];
         
         [self.loadedFiles addObject:filename];
     }];
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    NSLog(@"Class is %@", NSStringFromClass([overlay class]));
    
    if ( [overlay isKindOfClass:[MKPolygon class]] )
    {
        static CGFloat red = 0.1;
        static CGFloat green = 0.7;
        static CGFloat blue = 0.9;
        
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonRenderer.fillColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.6];
        polygonRenderer.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        polygonRenderer.lineWidth = 2.0;
        
        red = red + 0.07;
        green = green - 0.02;
        blue = blue - 0.05;
        
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
    for ( MKPolygon *polygon in self.map.overlays )
    {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(self.map.centerCoordinate);
        MKMapPoint currentMapPoint = mapPoint;
        CGPoint polygonViewPoint = [polygonRenderer pointForMapPoint:currentMapPoint];
        
        if ( CGPathContainsPoint(polygonRenderer.path, nil, polygonViewPoint, true) )
        {
            NSLog(@"inside");
        }
    }
}
/*
-(void)resetAnnotations
{
    [self.map removeAnnotations:self.map.annotations];
    [self.map removeOverlays:self.map.overlays];
    [self.loadedFiles removeAllObjects];
}

- (void)loadAnnotations
{
    [self mapView:self.map regionDidChangeAnimated:NO];
}

#pragma mark - Action

- (IBAction)toggleMenu:(id)sender
{
    if ( self.menuViewHeight.constant == self.squareHeight )
    {
        [self.openMenuButton setTitle:@"×" forState:UIControlStateNormal];
        [self.openMenuButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25
                         animations:^
         {
             self.menuView.backgroundColor = [UIColor whiteColor];
             
             self.menuViewWidth.constant = self.menuDetailsView.frame.size.width;
             self.menuViewHeight.constant = self.menuDetailsView.frame.size.height;
             
             [UIHelper applyCornerRadius:8.0 toView:self.menuView];
             
             [self.view layoutIfNeeded];
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.15 animations:^
              {
                  self.menuDetailsView.alpha = 1.0;
                  self.mapCoverView.alpha = 0.8;
              }];
         }];
    }
    else
    {
        [self.openMenuButton setTitle:@"+" forState:UIControlStateNormal];
        [self.openMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.15
                         animations:^
         {
             self.menuDetailsView.alpha = 0.0;
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.25 animations:^
              {
                  self.menuView.backgroundColor = [UIColor colorWithHex:@"0077cc"];
                  
                  self.menuViewWidth.constant = self.squareHeight;
                  self.menuViewHeight.constant = self.squareHeight;
                  
                  [UIHelper applyCornerRadius:self.squareHeight / 2.0 toView:self.menuView];
                  
                  self.mapCoverView.alpha = 0.0;
                  
                  [self.view layoutIfNeeded];
              }];
         }];
    }
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)segmentedControl
{
    [self hideMenuDetailsIfNecessary];
    
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

- (IBAction)waterTypeChanged:(UISegmentedControl *)segmentedControl
{
    [self hideMenuDetailsIfNecessary];
    
    switch (segmentedControl.selectedSegmentIndex )
    {
        case 0:
            [FileDownloader instance].waterType = WaterTypeSurface;
            break;
        default:
            [FileDownloader instance].waterType = WaterTypeFlood;
            break;
    }
    
    [self resetAnnotations];
    [self loadAnnotations];
}

- (IBAction)tappedBackground:(id)sender
{
    [self hideMenuDetailsIfNecessary];
}

- (IBAction)dateSelected:(id)sender
{
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.date = self.currentDate;
    
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [datePicker addTarget:self
                   action:@selector(dateChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    datePicker.backgroundColor = [UIColor principalColor];
    [UIHelper applyCornerRadius:8.0 toView:datePicker];
    [self.view addSubview:datePicker];
}

- (IBAction)genericShareSelected:(id)sender
{
    UIGraphicsBeginImageContextWithOptions(self.map.bounds.size, self.map.opaque, 0.0f);
    [self.map drawViewHierarchyInRect:self.map.bounds afterScreenUpdates:NO];
    UIImage *snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSArray *items = @[snapshotImageFromMyView];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    [self.navigationDelegate.mainNavigationController presentViewController:controller
                                                                   animated:YES
                                                                 completion:^
    {
    }];
}

- (IBAction)minusOneDay:(id)sender
{
    [self changeDate:[self.currentDate dateByAddingTimeInterval:-24*60*60]];
}

- (IBAction)plusOneDay:(id)sender
{
    [self changeDate:[self.currentDate dateByAddingTimeInterval:24*60*60]];
}

- (void)dateChanged:(UIDatePicker *)datePicker
{
    [self changeDate:datePicker.date];
    [datePicker removeFromSuperview];
}

- (void)hideMenuDetailsIfNecessary
{
    if ( self.menuViewHeight.constant != self.squareHeight )
    {
        [self toggleMenu:nil];
    }
}
*/
@end
