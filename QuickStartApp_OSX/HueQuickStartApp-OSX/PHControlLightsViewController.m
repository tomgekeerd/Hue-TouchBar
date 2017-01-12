/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import <HueSDK_OSX/HueSDK.h>
#import "AppDelegate.h"

#define MAX_HUE 65535

@interface PHControlLightsViewController ()
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeIdLabel;
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeIpLabel;
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeLastHeartbeatLabel;
@end

@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    [self noLocalConnection];
}

- (void)localConnection{
    [self loadConnectedBridgeValues];
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeIdLabel.stringValue = NSLocalizedString(@"Not connected", @"");
    [self.bridgeIdLabel setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.stringValue = cache.bridgeConfiguration.ipaddress;
        
        // Set the identifier of the bridge
        self.bridgeIdLabel.stringValue = cache.bridgeConfiguration.bridgeId;
        
        // Check if we are connected to the bridge right now
        if (NSAppDelegate.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.stringValue = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            
        } else {
            self.bridgeLastHeartbeatLabel.stringValue = NSLocalizedString(@"Waiting...", @"");
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [NSAppDelegate searchForBridgeLocal];
}

@end
