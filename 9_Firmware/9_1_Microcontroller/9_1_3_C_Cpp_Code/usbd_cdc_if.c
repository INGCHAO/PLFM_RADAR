#include "usbd_cdc_if.h"

#define APP_RX_DATA_SIZE  2048
#define APP_TX_DATA_SIZE  2048

extern USBD_HandleTypeDef hUsbDeviceFS;

static uint8_t UserRxBufferFS[APP_RX_DATA_SIZE];
static uint8_t UserTxBufferFS[APP_TX_DATA_SIZE];

static int8_t CDC_Init_FS(void);
static int8_t CDC_DeInit_FS(void);
static int8_t CDC_Control_FS(uint8_t cmd, uint8_t *pbuf, uint16_t length);
static int8_t CDC_Receive_FS(uint8_t *Buf, uint32_t *Len);

USBD_CDC_ItfTypeDef USBD_Interface_fops_FS = {
  CDC_Init_FS,
  CDC_DeInit_FS,
  CDC_Control_FS,
  CDC_Receive_FS,
  NULL,
};

static int8_t CDC_Init_FS(void)
{
  USBD_CDC_SetTxBuffer(&hUsbDeviceFS, UserTxBufferFS, 0);
  USBD_CDC_SetRxBuffer(&hUsbDeviceFS, UserRxBufferFS);
  return USBD_OK;
}

static int8_t CDC_DeInit_FS(void) { return USBD_OK; }

static int8_t CDC_Control_FS(uint8_t cmd, uint8_t *pbuf, uint16_t length)
{
  (void)cmd; (void)pbuf; (void)length;
  return USBD_OK;
}

/* Called from usbd_cdc.c when host has sent bytes to device.
 * The app handler (USBHandler::processUSBData) lives in C++; call it via a
 * weak C hook so C++ can override without pulling USBHandler into this TU. */
__attribute__((weak)) void CDC_on_receive(uint8_t *Buf, uint32_t Len)
{
  (void)Buf; (void)Len;
}

static int8_t CDC_Receive_FS(uint8_t *Buf, uint32_t *Len)
{
  CDC_on_receive(Buf, *Len);
  USBD_CDC_SetRxBuffer(&hUsbDeviceFS, &Buf[0]);
  USBD_CDC_ReceivePacket(&hUsbDeviceFS);
  return USBD_OK;
}

uint8_t CDC_Transmit_FS(uint8_t *Buf, uint16_t Len)
{
  USBD_CDC_HandleTypeDef *hcdc = (USBD_CDC_HandleTypeDef *)hUsbDeviceFS.pClassDataCmsit[hUsbDeviceFS.classId];
  if (hcdc == NULL) return USBD_FAIL;
  if (hcdc->TxState != 0) return USBD_BUSY;
  USBD_CDC_SetTxBuffer(&hUsbDeviceFS, Buf, Len);
  return USBD_CDC_TransmitPacket(&hUsbDeviceFS);
}
