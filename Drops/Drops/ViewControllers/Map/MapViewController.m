#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

#import "MapViewController.h"
#import "FileDownloader.h"

#import "UIColor+Drops.h"
#import "UIHelper.h"

#import "KMLParser.h"

@interface MapViewController () <MKMapViewDelegate>

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

@property (nonatomic) KMLParser *kmlParser;
@property (nonatomic) CGFloat squareHeight;
@property (nonatomic) NSMutableSet *loadedFiles;

@property (nonatomic) NSMutableDictionary *filenamesToOverlays;
@property (nonatomic) NSMutableDictionary *filenamesToAnnotations;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.processingQueue = [NSOperationQueue new];
    self.filenamesToOverlays = [NSMutableDictionary new];
    self.filenamesToAnnotations = [NSMutableDictionary new];
    
    self.loadedFiles = [NSMutableSet new];
    
    self.map.delegate = self;
    
    self.squareHeight = self.menuViewHeight.constant;
    [UIHelper applyCornerRadius:self.squareHeight / 2.0 toView:self.menuView];
    
    [self changeDate:nil];
    [self localizeOutlets];
}

- (void)localizeOutlets
{
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
         self.filenamesToOverlays[filename] = overlays;
         self.filenamesToAnnotations[filename] = annotations;
         
         [self.map addOverlays:overlays];
         [self.map addAnnotations:annotations];
         
         [self.loadedFiles addObject:filename];
    }];
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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer = [self.kmlParser rendererForOverlay:overlay];
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [self.kmlParser viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationDegrees latitude = self.map.centerCoordinate.latitude;
    CLLocationDegrees longitude = self.map.centerCoordinate.longitude;

    NSString *locationString = [NSString stringWithFormat:@"%f, %f",
                                latitude,
                                longitude];
    
    [self.locationDetailsButton setTitle:locationString forState:UIControlStateNormal];
    
    [self.processingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^
    {
        NSString *filename = [[FileDownloader instance] filenameForDate:self.currentDate
                                                               latitude:latitude
                                                              longitude:longitude
                                                                 zipped:NO];
        
        if ( ! [self.loadedFiles containsObject:filename] )
        {
            NSLog(@"Loading %@", filename);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
             {
                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view
                                                           animated:YES];
                 hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
                 hud.backgroundView.color = [UIColor colorWithWhite:0.f alpha:.2f];
                 hud.label.text = NSLocalizedString(@"PROCESSING", nil);
             }];
            
            NSArray *overlays = self.filenamesToOverlays[filename];
            NSArray *annotations = self.filenamesToAnnotations[filename];
            
            if ( overlays != nil || annotations != nil )
            {
                NSLog(@"File %@ was in memory", filename);
                [self addOverlays:overlays annotations:annotations filename:filename];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^
                 {
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 }];
            }
            else
            {
                [[FileDownloader instance] downloadForDate:self.currentDate
                                                  latitude:latitude
                                                 longitude:longitude
                                                  callback:^(NSURL *fileURL, NSError *error)
                 {
                     if ( error == nil )
                     {
                         [self processFile:fileURL];
                     }
                     else
                     {
                         [[NSOperationQueue mainQueue] addOperationWithBlock:^
                          {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                          }];
                     }
                 }];
            }
            
        }
    }]];
}

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

@end

/*
 // Walk the list of overlays and annotations and create a MKMapRect that
 // bounds all of them and store it into flyTo.
 MKMapRect flyTo = MKMapRectNull;
 for (id <MKOverlay> overlay in overlays)
 {
 if (MKMapRectIsNull(flyTo))
 {
 flyTo = [overlay boundingMapRect];
 }
 else
 {
 flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
 }
 }
 
 for (id <MKAnnotation> annotation in annotations)
 {
 
 MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
 MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
 
 if (MKMapRectIsNull(flyTo))
 {
 flyTo = pointRect;
 }
 else
 {
 flyTo = MKMapRectUnion(flyTo, pointRect);
 }
 }
 
 // Position the map so that all overlays and annotations are visible on screen.
 self.map.visibleMapRect = flyTo;
 */
