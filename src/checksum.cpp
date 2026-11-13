#include "checksum.hpp"

#include "crc16.h"

#include <cstddef>
#include <cstdint>
#include <string_view>

namespace checksum {

std::uint16_t crc16_ccitt(const std::byte *data, std::size_t size) noexcept {
  return checksum_crc16_ccitt(data, size);
}

std::uint16_t crc16_ccitt(std::string_view text) noexcept {
  return checksum_crc16_ccitt(text.data(), text.size());
}

} // namespace checksum
