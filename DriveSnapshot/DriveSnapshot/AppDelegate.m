//
//  AppDelegate.m
//  DriveSnapshot
//
//  Created by Jovi on 9/28/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import "AppDelegate.h"
#import <ShadowstarKit/ShadowstarKit.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate{
    IBOutlet NSTextField *lbTip;
    NSMutableDictionary *_dictDriveInfo;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _dictDriveInfo = [[NSMutableDictionary alloc] init];
    [[SSDiskManager sharedManager] setDiskChangedBlock:^(DADiskRef disk, SSDiskNotification_Type type) {
        if(eSSDiskNotification_DiskAppeared != type){
            return;
        }
        NSString *bsdName = [SSDiskManager bsdnameForDiskRef:disk];
        if (nil == bsdName) {
            return;
        }
        NSMutableDictionary *dictData = [[NSMutableDictionary alloc]initWithDictionary:CFBridgingRelease(DADiskCopyDescription(disk))];
        NSString *strMediaUUID = [NSString stringWithFormat:@"%@",[dictData objectForKey:(NSString *)kDADiskDescriptionMediaUUIDKey]];
        NSString *strVolumeUUID = [NSString stringWithFormat:@"%@",[dictData objectForKey:(NSString *)kDADiskDescriptionVolumeUUIDKey]];
        NSString *strVolumePath = [NSString stringWithFormat:@"%@",[dictData objectForKey:(NSString *)kDADiskDescriptionVolumePathKey]];
        
        [dictData setObject:strMediaUUID forKey:(NSString *)kDADiskDescriptionMediaUUIDKey];
        [dictData setObject:strVolumeUUID forKey:(NSString *)kDADiskDescriptionVolumeUUIDKey];
        [dictData setObject:strVolumePath forKey:(NSString *)kDADiskDescriptionVolumePathKey];
        [_dictDriveInfo setValue:[dictData copy] forKey:bsdName];
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

-(IBAction)takeDriveSnapshots_click:(id)sender{
    [lbTip setStringValue:@""];
    NSString *snapshotName = [NSString stringWithFormat:@"DiveSnapshot_%ld.plist", time(NULL)];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    if (0 < [paths count]) {
        NSString* desktopPath = [paths objectAtIndex:0];
        NSString *savePath = [NSString stringWithFormat:@"%@/%@",desktopPath,snapshotName];
        NSArray *infos = [_dictDriveInfo allValues];
        [infos writeToFile:savePath atomically:YES];
        [lbTip setStringValue:[NSString stringWithFormat:@"The drive snapshot has been saved at:  %@",savePath]];
    }
}

@end
