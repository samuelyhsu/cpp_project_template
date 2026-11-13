#pragma once

#include <cstddef>
#include <cstdint>
#include <string_view>

namespace checksum {

// 算法与 C 接口 checksum_crc16_ccitt（crc16.h）相同
std::uint16_t crc16_ccitt(const std::byte *data, std::size_t size) noexcept;
std::uint16_t crc16_ccitt(std::string_view text) noexcept;

} // namespace checksum
