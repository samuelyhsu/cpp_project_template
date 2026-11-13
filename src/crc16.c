#include "crc16.h"

#include <stddef.h>
#include <stdint.h>

uint16_t checksum_crc16_ccitt(const void *data, size_t size) {
  const uint8_t *bytes = data;
  // 用 unsigned 运算：uint16_t 参与运算时会被提升为有符号的 int
  unsigned crc = 0xFFFFU;
  for (size_t i = 0; i < size; ++i) {
    crc ^= (unsigned)bytes[i] << 8U;
    for (int bit = 0; bit < 8; ++bit) {
      crc = ((crc & 0x8000U) ? (crc << 1U) ^ 0x1021U : crc << 1U) & 0xFFFFU;
    }
  }
  return (uint16_t)crc;
}
