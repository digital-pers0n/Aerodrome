//
//  aerodrome_ioctl.m
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <ifaddrs.h>
#include <net/if.h>
#include "apple80211_ioctl.h"
#include "apple80211_var.h"

#include "aerwl_ioctl.h"

#import <CoreWLAN/CoreWLANTypes.h>

int get_if_name(char *name)
{
    struct ifaddrs *addrs;
    //const  char *ifname;
    
    
    
    
    getifaddrs(&addrs);
    
    int a80211_sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (a80211_sock == -1) {
        return -1;
    }
    
    for (struct ifaddrs *i = addrs; i; i = i->ifa_next )
    {
        //ifname = i->ifa_name;
        //bzero(&empty, 16);
        if ( strcmp("", i->ifa_name) )
        {
            if ( strcmp("lo0", i->ifa_name) )
            {
                if ( strcmp("gif0", i->ifa_name) )
                {
                    if ( strcmp("faith0", i->ifa_name) )
                    {
                        if ( strcmp("stf0", i->ifa_name) )
                        {
                            
                            
                            errno = 0;
                            
                            int rc = 0;
                            struct apple80211_state_data iodat;
                            struct apple80211req request;
                            
                            bzero(&request, sizeof(request));
                            strlcpy(request.req_if_name, i->ifa_name, 16);
                            request.req_type   = 19;
                            request.req_len = sizeof(iodat);
                            request.req_data   = &iodat;
                            
                            rc = ioctl (a80211_sock,
                                        SIOCGA80211,
                                        &request);
                            
                            if (rc < 0) {
                                
                                //perror("");
                                //return -1;
                                
                            }else {
                                strlcpy(g_interface_name, i->ifa_name, 16);
                                strlcpy(name, i->ifa_name, 16);
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    if(addrs){
        freeifaddrs(addrs);
    }
    if(a80211_sock){
        close(a80211_sock);
    }
    
    return 0;
}

int a80211_getset(uint32_t ioc, uint32_t type, uint32_t *valuep, void *data, size_t length)
{
    struct apple80211req cmd;
    
    
    // const char *ifname = g_interface_name;
    
    
    
    
    
    int a80211_sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (a80211_sock == -1) {
        return -1;
    }
    
    
    
    
    bzero(&cmd, sizeof(cmd));
    
    
    
    //    memcpy(cmd.req_if_name, g_interface_name, 16);
    strlcpy(cmd.req_if_name, g_interface_name, sizeof(cmd.req_if_name));
    cmd.req_type = type;
    cmd.req_val = valuep ? *valuep : 0;
    cmd.req_len = (uint32_t) length;
    cmd.req_data = data;
    errno = 0;
    int ret = ioctl(a80211_sock, ioc, &cmd, sizeof(cmd));
    
    
    if (ret < 0) {
        
        perror("");
        printf("req_type: %i\n", type);
        
    }
    
    
    
    if (valuep)
        *valuep = cmd.req_val;
    
    close(a80211_sock);
    return ret;
}


#pragma mark - power

int get_power(struct apple80211_power_data *data) {
    //SIOCGIFADDR
    return a80211_getset(SIOCGA80211, APPLE80211_IOC_POWER, NULL, data, sizeof(*data));
}

int set_power(struct apple80211_power_data *data) {
    return a80211_getset(SIOCSA80211, APPLE80211_IOC_POWER, NULL, data, sizeof(*data));
}

bool is_powered()
{
    struct apple80211_power_data data;
    bzero(&data, sizeof(data));
    get_power(&data);
    
    if(data.power_state[0] == 0){ return false; }
    
    return true;
}

bool set_power_state(bool st)
{
    struct apple80211_power_data data;
     bzero(&data, sizeof(data));
    get_power(&data);
    data.version = 1;
    
    if (st) {
        for (int i = 0; i < data.num_radios; i++)
            data.power_state[i] = 1;
        set_power(&data);
        return true;
    } else  {
        for (int i = 0; i < data.num_radios; i++)
            data.power_state[i] = 0;
        set_power(&data);
        return false;
    }
}

bool power_cycle() {
    struct apple80211_power_data data;
    bzero(&data, sizeof(data));
    //ensure(!get_power(&data));
    get_power(&data);
    //    printf("num radios %d\n", data.num_radios);
    //ensure(data.num_radios <= 4);
    data.version = 1;
    if (is_powered()) {
        for (int i = 0; i < data.num_radios; i++)
            data.power_state[i] = 0;
        set_power(&data);
        return false;
    } else {
        
        for (int i = 0; i < data.num_radios; i++)
            data.power_state[i] = 1;
        set_power(&data);
        return true;
        
    }
    
    return -1;
}

#pragma mark - State
int get_state(uint32_t *a)
{
    return a80211_getset(SIOCGA80211, APPLE80211_IOC_STATE, a, NULL, 0);
}

bool is_associated()
{
    uint32_t req = 0;
    get_state(&req);
    
    return (req == APPLE80211_S_RUN) ? true : false;
    
}

#pragma mark - Op Mode

int get_opmode(uint32_t *a)
{
    return a80211_getset(SIOCGA80211, APPLE80211_IOC_OP_MODE, a, NULL, 0);
}


bool is_ibss()
{
    uint32_t req = 0;
    get_opmode(&req);
    
    return (req == APPLE80211_M_IBSS) ? true : false;
}

#pragma mark - ssid / bssid
int get_ssid_name(char *ssid)
{
    
    
    return  a80211_getset(SIOCGA80211, APPLE80211_IOC_SSID, NULL, ssid, 32);
    
    
}

int get_bssid(struct ether_addr *bssid)
{
    return a80211_getset(SIOCGA80211, APPLE80211_IOC_BSSID, 0, bssid, sizeof(*bssid));
}

#pragma mark - connections

int disassociate()
{
    return a80211_getset(SIOCSA80211, APPLE80211_IOC_DISASSOCIATE, NULL, NULL, 0);
}

#pragma mark - channels
int get_sup_channel_data(struct apple80211_sup_channel_data *data)
{
    return a80211_getset(SIOCGA80211, APPLE80211_IOC_SUPPORTED_CHANNELS, NULL, data, sizeof(data));
    
}

CFArrayRef get_channels_list()
{
    CFMutableArrayRef channels = NULL;
    CFNumberRef string = NULL;
    //NSArray *returnArray;
    
    //CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, 14, &kCFTypeSetCallBacks);
    
    
    struct apple80211_sup_channel_data data;
    bzero(&data, sizeof(data));
    
    a80211_getset(SIOCGA80211, APPLE80211_IOC_SUPPORTED_CHANNELS, 0, &data, sizeof(data));
    
    
    channels = CFArrayCreateMutable(kCFAllocatorDefault, data.num_channels, &kCFTypeArrayCallBacks);
    
    //printf("Supported channels: ");
    for (int i = 0; i < APPLE80211_MAX_CHANNELS ; i++) {
        if (data.supported_channels[i].channel == 0) {
            ;
        } else {
            string = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &data.supported_channels[i].channel);
            // CFSetAddValue(set, string);
            CFArrayAppendValue(channels, string);
            // printf("%i ",  data.supported_channels[i].channel);
        }
    }
    
    
    ;
    return channels;
}
