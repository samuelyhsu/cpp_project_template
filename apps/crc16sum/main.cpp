// 示例程序：逐个打印命令行参数的 CRC-16/CCITT-FALSE
#include "checksum.hpp"

#include <cstdio>
#include <string_view>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::fputs("usage: crc16sum <text>...\n"
               "       crc16sum --version\n",
               stderr);
    return 2;
  }
  if (std::string_view{argv[1]} == "--version") {
    std::puts(APP_NAME " " APP_VERSION);
    return 0;
  }
  for (int i = 1; i < argc; ++i) {
    const std::string_view arg{argv[i]};
    std::printf("%04X  %.*s\n",
                static_cast<unsigned>(checksum::crc16_ccitt(arg)),
                static_cast<int>(arg.size()), arg.data());
  }
  return 0;
}
