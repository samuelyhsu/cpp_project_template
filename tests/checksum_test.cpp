#include "checksum.hpp"
#include "crc16.h"

#include <catch2/catch_test_macros.hpp>

#include <array>
#include <cstddef>
#include <string_view>

TEST_CASE("crc16_ccitt matches published check values", "[crc16]") {
  CHECK(checksum::crc16_ccitt(std::string_view{"123456789"}) == 0x29B1);
  CHECK(checksum::crc16_ccitt(std::string_view{"A"}) == 0xB915);
}

TEST_CASE("crc16_ccitt of empty input is the initial value", "[crc16]") {
  CHECK(checksum::crc16_ccitt(std::string_view{}) == 0xFFFF);
  CHECK(checksum_crc16_ccitt(nullptr, 0) == 0xFFFF);
}

TEST_CASE("byte, text and C interfaces agree", "[crc16]") {
  constexpr std::array bytes{std::byte{0x12}, std::byte{0x34}, std::byte{0x56}};
  constexpr std::string_view text{"\x12\x34\x56"};
  const auto crc = checksum::crc16_ccitt(bytes.data(), bytes.size());
  CHECK(crc == checksum::crc16_ccitt(text));
  CHECK(crc == checksum_crc16_ccitt(bytes.data(), bytes.size()));
}
