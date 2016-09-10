//
//  AERHelperPreferences.m
//  Aerodrome
//
//  Created by Terminator on 8/23/16.
//
//

#import "AERHelperPreferences.h"
#import "AEROptions.h"
#import "NSDictionary+AERNetwork.h"

@implementation AERHelperPreferences

+(id)sharedPreferences
{
    static AERHelperPreferences *prefs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prefs = [[AERHelperPreferences alloc] init];
        
    });
    
    return prefs;
}

-(BOOL)shouldRememberNetworks
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_REMEMBER_PREVIOUS_NETWORKS_KEY];
}




-(NSDictionary *)findNetwork:(NSDictionary *)network
{
    NSArray * defaults = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY] copyItems:YES];
    for (NSDictionary *a in defaults) {
        if (/*[[a bssid] isEqualToString:[network bssid]] && */[[a ssid] isEqualToString:[network ssid]]) {
            return a;
        }
    }
    return nil;
}

-(void)addNetowrkToList:(NSDictionary *)network withPassword:(NSString *)pass
{
    
    NSArray *networks = [NSArray new];
    NSDictionary *stored;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY]) {
        [[NSUserDefaults standardUserDefaults] setObject:networks forKey:PREFS_NETWORKS_KEY];
        
    }
    
    if([pass length] > 0){
        
        [self addNetworkToKeychain:network password:pass];
    }
    
    
    stored = [self findNetwork:network];
    
    if (stored) {
        
        
        if (![[self findInKeychain:network] isEqualToString:pass]) {
            
            
            [self removeNetworkFromList:network];
        } else {
            
            return;
        }
        
    }
    
    networks = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY];
    
    networks =  [networks arrayByAddingObject:@{@"SSID_STR": [network ssid],
                                                @"BSSID" : [network bssid],
                                                @"SSID" : [network ssidData],
                                                @"SECURITY" : [network securityString],
                                                //@"Value": pass ? [pass dataUsingEncoding:NSUTF8StringEncoding] : [NSNull null]
                                                }];
    
    [[NSUserDefaults standardUserDefaults] setObject:networks forKey:PREFS_NETWORKS_KEY];
    
    
}


-(void)removeNetworkFromList:(NSDictionary *)network
{
    
    NSMutableArray *networks = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:PREFS_NETWORKS_KEY] copyItems:YES];
    
    
    
    
    int index = 0;
    for(NSDictionary * a in networks){
        
        if (/*[[a bssid] isEqualToString:[network bssid]] &&*/ [[a ssid] isEqualToString:[network ssid]]) {
            [networks removeObjectAtIndex:index];
            
            [[NSUserDefaults standardUserDefaults] setObject:networks forKey:PREFS_NETWORKS_KEY];
            
            
            return;
        }
        
        index++;
    }
    
    
    
    
}

-(NSString *)makePSK:(NSString *)ssid andPassword:(NSString *)pass
{
    //
    //    NSString *name = @"--ssid=", *password = @"--password=";
    //
    //    name = [name stringByAppendingString:ssid];
    //    password = [password stringByAppendingString:pass];
    //
    //
    //    NSTask   * task;
    //    NSString *path = PREFS_AIRPORT_BINARY;
    //    NSArray *args = @[@"--psk", name, password];
    //
    //    NSPipe *outPipe = [[NSPipe alloc] init];
    //    task = [[NSTask alloc] init];
    //
    //    [task setStandardInput:[NSPipe pipe]];
    //    [task setStandardOutput:outPipe];
    //    [task setStandardError: [NSPipe pipe]];
    //
    //
    //
    //    [task setLaunchPath:path];
    //    [task setArguments:args];
    //    [task launch];
    //
    //
    //    NSData *data = [[outPipe fileHandleForReading]
    //                    readDataToEndOfFile];
    //    [task waitUntilExit];
    //
    //    NSString *aString = [[NSString alloc] initWithData:data
    //                                              encoding:NSUTF8StringEncoding];
    return  pass;
    
}

-(NSString *)findInKeychain:(NSDictionary *)network
{
    NSString
    
    *binary = PREFS_SECURITY_BINARY,
    *option = @"find-generic-password";
    
    
    NSTask   * task;
    
    NSArray *args = @[option, @"-a", [network ssid], @"-w"];
    
    NSPipe *outPipe = [[NSPipe alloc] init];
    NSPipe *errorPipe = [[NSPipe alloc] init];
    task = [[NSTask alloc] init];
    //
    //[task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:outPipe];
    [task setStandardError:errorPipe];
    //
    //
    //
    [task setLaunchPath:binary];
    [task setArguments:args];
    [task launch];
    //
    //
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    
    if ([errorData length] > 0) {
        return nil;
    }
    //
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    aString = [aString stringByReplacingCharactersInRange:NSMakeRange([aString length] - 1, 1) withString:@""];
    
    return aString;
}

-(void)addNetworkToKeychain:(NSDictionary *)network password:(NSString *)password
{
    
    NSString *isPresent = [self findInKeychain:network];
    
    if ([isPresent isEqualToString:password]) {
        return;
    }
    NSString
    
    *binary = PREFS_SECURITY_BINARY,
    *option = @"add-generic-password",
    *account = [NSString stringWithFormat:@"-a \"%@\"", [network ssid]],
    *kind = @"-D \"Wi-Fi Password\"",
    *service = @"-s Aerodrome",
    *label = [NSString stringWithFormat:@"-l \"%@\"", [network ssid]],
    *access = isPresent ? @"" : [NSString stringWithFormat:@"-T %@",  PREFS_SECURITY_BINARY],
    *pass = [NSString stringWithFormat:@"-w %@", password],
    *update = isPresent ? @"-U" : @"";
    
    NSString *command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ &",
                         binary, option, account, kind, service, label, access, pass, update];
    
    system([command UTF8String]);
}

-(void)removeNetworkFromKeychain:(NSDictionary *)network
{
    
    NSString
    
    *binary = PREFS_SECURITY_BINARY,
    *option = @"delete-generic-password",
    *account = [NSString stringWithFormat:@"-a \"%@\"", [network ssid]];
    
    system([[NSString stringWithFormat:@"%@ %@ %@ &", binary, option, account] UTF8String]);
}



@end
