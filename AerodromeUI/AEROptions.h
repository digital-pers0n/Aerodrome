//
//  AEROptions.h
//  Aerodrome
//
//  Created by Terminator on 7/26/16.
//
//

#ifndef AEROptions_h
#define AEROptions_h


#endif /* AEROptions_h */
#define AERNETWORK_STATUS_DEFAULT @"Wi-Fi: On"
#define AERNETWORK_STATUS_SCAN @"Wi-Fi: Looking For Networks"
#define AERNETWORK_STATUS_ACTIVE @"Wi-Fi: Running"
#define AERNETWORK_STATUS_OFF @"Wi-Fi: Off"

#define AERPOWER_SWITCH_ON @"Switch Wi-Fi On"
#define AERPOWER_SWITCH_OFF @"Switch Wi-Fi Off"

#define AERICON_STATUS_OFF @"status-off"
#define AERICON_STATUS_30 @"status-30"
#define AERICON_STATUS_50 @"status-50"
#define AERICON_STATUS_100 @"status-100"
#define AERICON_STATUS_IBSS @"status-ibss"
#define AERICON_STATUS_IDLE @"status-idle"

#define AERICON_SIGNAL_0 @"signal-0"
#define AERICON_SIGNAL_1 @"signal-1"
#define AERICON_SIGNAL_2 @"signal-2"
#define AERICON_SIGNAL_3 @"signal-3"





/* 100x - items, 101x - alternate items, 102x - hidden auxiliary items, 11xx - main separator, 90x - dynamic separators */
typedef enum : NSUInteger {
    AERMenuStatus           = 1000,
    AERMenuDisconnect       = 1001,
    AERMenuPowerSwitch      = 1002,
    AERMenuFirstSeparator   = 1100,
    AERMenuNoNetworks       = 1020,
    AERMenuSecondSeparator  =  900,
    AERMenuThirdSeparator   =  901,
    AERMenuDevices          = 1021,
    AERMenuCreateIBSS       = 1003,
    AERMenuCreateIBSSAlt    = 1013,
    AERMenuManualJoin       = 1004,
    AERMenuShowScanDiagAlt  = 1014,
    AERMenuPreferences      = 1005,
    AERMenuFourthSeparator  = 1101,
    AERMenuQuit             = 1006,
    AERMenuRestart          = 1016,
} AERMenuItemsTags;



// Preferences

#define PREFS_NETWORKS_KEY @"PreviousNetworks"
#define PREFS_REMEMBER_PREVIOUS_NETWORKS_KEY @"RememberPreviousNetworks"
#define PREFS_SECURITY_BINARY @"/usr/bin/security"

