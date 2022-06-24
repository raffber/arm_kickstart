#include "config_version.h"
#include "hal.h"
#include "stdbool.h"
#include "stdint.h"

#define NODE_ID 1

// TODO: change if your reset handler is not called this way
void Reset_Handler(void) {
}

__attribute__((section(".app_main"))) volatile static const uint32_t entry_point = (uint32_t) &Reset_Handler;

__attribute__((section(".app_crc"))) volatile static const uint32_t crc = 0;

__attribute__((section(".app_header"))) volatile static const uint16_t app_header[] = {
    PRODUCT_ID,
    NODE_ID,
    VERSION_MAJOR,
    VERSION_MINOR,
    VERSION_BUILD,
    0x0000,
    0xFFFF,
    0xFFFF,

    0xFFFF,
    0xFFFF,
    0xFFFF,
    0xFFFF,
    0xFFFF,
    0xFFFF,
    0xFFFF,
    0xFFFF,
};

// TODO: you need to install target specific startup, which calls this functin
int main() {
    (void) crc;
    (void) entry_point;
    (void) app_header;

    hal_init();

    while (true) {
    }
}