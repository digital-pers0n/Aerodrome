//
//  aerwl_ioctl.h
//  Aerodrome
//
//  Created by Terminator on 8/21/16.
//
//

#ifndef aerwl_ioctl_h
#define aerwl_ioctl_h
#include <stdio.h>
#include <net/ethernet.h>

static char g_interface_name[16];

int get_if_name(char *nm);

bool power_cycle();
bool set_power_state(bool state);
bool is_powered();

int get_state(uint32_t *state);
bool is_associated();

int get_opmode(uint32_t *mode);
bool is_ibss();

int get_ssid_name(char *name);
int get_bssid(struct ether_addr *addr);

int disassociate();

CFArrayRef get_channels_list();



#endif /* aerwl_ioctl_h */
