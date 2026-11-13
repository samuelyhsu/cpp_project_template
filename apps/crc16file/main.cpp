// 示例程序：逐个打印文件内容的 CRC-16/CCITT-FALSE
#include "checksum.hpp"

#include <cstdio>
#include <fstream>
#include <sstream>
#include <string>
#include <string_view>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    std::fputs("usage: crc16file <file>...\n"
               "       crc16file --version\n",
               stderr);
    return 2;
  }
  if (std::string_view{argv[1]} == "--version") {
    std::puts(APP_NAME " " APP_VERSION);
    return 0;
  }
  int status = 0;
  for (int i = 1; i < argc; ++i) {
    std::ifstream file{argv[i], std::ios::binary};
    if (!file) {
      std::fprintf(stderr, APP_NAME ": cannot open %s\n", argv[i]);
      status = 1;
      continue;
    }
    std::ostringstream content;
    content << file.rdbuf();
    const std::string data = content.str();
    std::printf("%04X  %s\n",
                static_cast<unsigned>(checksum::crc16_ccitt(data)), argv[i]);
  }
  return status;
}
