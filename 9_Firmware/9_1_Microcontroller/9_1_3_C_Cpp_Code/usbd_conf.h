#ifndef __USBD_CONF__H__
#define __USBD_CONF__H__

#ifdef __cplusplus
extern "C" {
#endif

#include "stm32f7xx.h"
#include "stm32f7xx_hal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define USBD_MAX_NUM_INTERFACES     1U
#define USBD_MAX_NUM_CONFIGURATION  1U
#define USBD_MAX_STR_DESC_SIZ       512U
#define USBD_SELF_POWERED           1U
#define USBD_DEBUG_LEVEL            0U
#define USBD_LPM_ENABLED            0U
#define USBD_SUPPORT_USER_STRING_DESC 0U
#define USBD_CDC_INTERVAL           2000U

#define DEVICE_FS                   0

#define USBD_malloc                 USBD_static_malloc
#define USBD_free                   USBD_static_free
#define USBD_memset                 memset
#define USBD_memcpy                 memcpy
#define USBD_Delay                  HAL_Delay

#define USBD_UsrLog(...)    do {} while (0)
#define USBD_ErrLog(...)    do {} while (0)
#define USBD_DbgLog(...)    do {} while (0)

void *USBD_static_malloc(uint32_t size);
void  USBD_static_free(void *p);

void Error_Handler(void);

#ifdef __cplusplus
}
#endif

#endif
