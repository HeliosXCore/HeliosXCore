#pragma once
#include <fmt/core.h>
#include <stdexcept>

#define ERROR_MSG(MSG) fmt::format("{} Source {}:{}", (MSG), __FILE__, __LINE__)
#define RUNTIME_ERROR(MSG) throw std::runtime_error(ERROR_MSG(MSG))

#ifndef DISABLE_ASSERT
#define ASSERT(CONDITION, F, ...)                                        \
    {                                                                    \
        if (!(CONDITION))                                                \
            RUNTIME_ERROR(fmt::format("Assertion: " #F, ##__VA_ARGS__)); \
    }
#else
#define ASSERT(CONDITION, F)
#endif