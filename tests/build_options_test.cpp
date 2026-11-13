#include <catch2/catch_test_macros.hpp>

// 在 release preset 下运行才有意义：debug 构建本来就不定义 NDEBUG
TEST_CASE("assert stays enabled in every build type", "[build]") {
#ifdef NDEBUG
  FAIL("NDEBUG is defined, so assert is compiled out");
#else
  SUCCEED("NDEBUG is not defined");
#endif
}
