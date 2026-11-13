#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* CRC-16/CCITT-FALSE：多项式 0x1021，初值 0xFFFF，
 * 输入输出均不反转，结果不异或。
 * size 为 0 时 data 可以为 NULL，返回初值 0xFFFF。 */
uint16_t checksum_crc16_ccitt(const void *data, size_t size);

#ifdef __cplusplus
}
#endif
