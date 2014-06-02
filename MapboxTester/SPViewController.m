//
//  SPViewController.m
//  MapboxTester
//
//  Created by Ryan DeVore on 6/1/14.
//  Copyright (c) 2014 Silver Pine Software. All rights reserved.
//

#import "SPViewController.h"
#import <Mapbox/Mapbox.h>

@interface SPViewController () <RMMapViewDelegate>

@property (nonatomic, strong) RMMapView* mapboxView;

- (IBAction)onChangeLocationClicked:(id)sender;
- (IBAction)onChangeLocationOutsideMapClicked:(id)sender;
- (IBAction)onZoomIn:(id)sender;
- (IBAction)onZoomOut:(id)sender;

@end

@implementation SPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RMMapboxSource* mapSource = [[RMMapboxSource alloc] initWithMapID:@"ryandevore.haded0db"];
    if (mapSource)
    {
        self.mapboxView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:mapSource];
        self.mapboxView.delegate = self;
        //self.mapboxView.showLogoBug = NO;
        self.mapboxView.hideAttribution = YES;
        self.mapboxView.showsUserLocation = YES;
        
        [self.mapboxView setZoom:10];
        
        [self.view insertSubview:self.mapboxView atIndex:0];
    }
}

- (CLLocationCoordinate2D) makeRandomCoordsInsideMapBounds
{
    CLLocationCoordinate2D coord;
    
    RMSphericalTrapezium box = self.mapboxView.latitudeLongitudeBoundingBox;
    
    double latSpan = fabs(box.northEast.latitude - box.southWest.latitude);
    double lngSpan = fabs(box.northEast.longitude - box.southWest.longitude);
    
    double latPercent = arc4random_uniform(100) / 100.0f;
    double lngPercent = arc4random_uniform(100) / 100.0f;
    
    double latDelta = latSpan * latPercent;
    double lngDelta = lngSpan * lngPercent;
    
    coord.latitude = box.southWest.latitude + latDelta;
    coord.longitude = box.southWest.longitude + lngDelta;
    
    return coord;
}

- (CLLocationCoordinate2D) makeRandomCoordsOutsideMapBounds
{
    CLLocationCoordinate2D coord;
    
    RMSphericalTrapezium box = self.mapboxView.latitudeLongitudeBoundingBox;
    
    double latSpan = fabs(box.northEast.latitude - box.southWest.latitude);
    double lngSpan = fabs(box.northEast.longitude - box.southWest.longitude);
    
    double latPercent = arc4random_uniform(100) / 100.0f;
    double lngPercent = arc4random_uniform(100) / 100.0f;
    
    double latDelta = latSpan * latPercent;
    double lngDelta = lngSpan * lngPercent;
    
    if (arc4random() % 2 == 0)
    {
        coord.latitude = box.southWest.latitude - latDelta;
    }
    else
    {
        coord.latitude = box.northEast.latitude + latDelta;
    }
    
    if (arc4random() % 2 == 0)
    {
        coord.longitude = box.southWest.longitude - lngDelta;
    }
    else
    {
        coord.longitude = box.northEast.longitude + lngDelta;
    }
    
    return coord;
}

- (IBAction)onChangeLocationClicked:(id)sender
{
    CLLocationCoordinate2D coord = [self makeRandomCoordsInsideMapBounds];
    [self replaceAnnotation:coord];
}

- (IBAction)onChangeLocationOutsideMapClicked:(id)sender
{
    CLLocationCoordinate2D coord = [self makeRandomCoordsOutsideMapBounds];
    [self replaceAnnotation:coord];
}

- (IBAction)onZoomIn:(id)sender
{
    [self.mapboxView zoomInToNextNativeZoomAt:self.mapboxView.center animated:YES];
}

- (IBAction)onZoomOut:(id)sender
{
    [self.mapboxView zoomOutToNextNativeZoomAt:self.mapboxView.center animated:YES];
}

- (void) replaceAnnotation:(CLLocationCoordinate2D)coord
{
    [self.mapboxView removeAllAnnotations];
    
    NSString* name = [NSString stringWithFormat:@"%.04f, %.04f", coord.latitude, coord.longitude];
    
    RMAnnotation* annotation = [RMAnnotation annotationWithMapView:self.mapboxView coordinate:coord andTitle:name];
    //annotation.annotationIcon = [UIImage imageNamed:@"custom_pin"];
    
    [self.mapboxView addAnnotation:annotation];
    [self.mapboxView selectAnnotation:annotation animated:YES];
    [self.mapboxView setZoom:15 atCoordinate:annotation.coordinate animated:YES];
    
    // This produces the same result
    /*
    CLLocationCoordinate2D sw;
    sw.latitude = coord.latitude - 0.03f;
    sw.longitude = coord.longitude - 0.03f;
    
    CLLocationCoordinate2D ne;
    ne.latitude = coord.latitude + 0.03f;
    ne.longitude = coord.longitude + 0.03f;
    
    [self.mapboxView zoomWithLatitudeLongitudeBoundsSouthWest:sw northEast:ne animated:YES];
    */
}

#pragma mark - RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation
{
    if ([annotation isKindOfClass:[RMUserLocation class]])
    {
        return nil;
    }
    
    RMMapLayer *marker = nil;
	
    // The bug seems to happen regardless of whether I use a built in icon or custom icon
    //marker = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
    
    marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"embassy"];
    
    marker.canShowCallout = YES;
	return marker;
}

@end