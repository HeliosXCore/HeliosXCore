#pragma once
#include <stdint.h>
#include <string>
#include <memory>
#include <fstream>
#include <fmt/core.h>

union Instruction {
    uint32_t instructions[2];
    uint8_t padding[8];
};

class Memory {
   public:
    Memory(uint32_t base_addr, uint32_t size)
        : base_addr(base_addr), size(size) {
        mem = std::make_unique<char>(size);
        next_ack = 0;
        next_data = 0;
    }

    void load(std::string filename) {
        std::ifstream in(filename, std::ios::binary);
        if (!in.is_open()) {
            fmt::print(stderr, "Cannot open file {}\n", filename);
            exit(1);
        } else {
            // Read file content into memory
            in.read(mem.get(), size);
            in.close();
        }
    }
    void load(uint32_t addr, const char *buf, size_t n) {
        for (int i = 0; i < n; i++) {
            auto ptr = mem.get();
            ptr[addr + i - base_addr] = buf[i];
        }
    }

    void apply(uint32_t wb_cycle, uint32_t wb_we, uint32_t wb_addr,
               uint32_t wb_data, uint8_t wb_sel, uint32_t &ack_o,
               uint32_t &data_o) {
        uint32_t sel = 0;
        if (wb_sel & 0x8) {
            sel |= 0xff000000;
        }
        if (wb_sel & 0x4) {
            sel |= 0x00ff0000;
        }
        if (wb_sel & 0x2) {
            sel |= 0x0000ff00;
        }
        if (wb_sel & 0x1) {
            sel |= 0x000000ff;
        }

        ack_o = next_ack && wb_cycle;
        data_o = next_data;
        next_data = wb_data;
        next_ack = 0;

        if (wb_cycle) {
            if (wb_we) {
                if (sel == 0xffffffffu) {
                    *(uint32_t *)(mem.get() + wb_addr - base_addr) = wb_data;
                } else {
                    uint32_t old_data =
                        *(uint32_t *)(mem.get() + wb_addr - base_addr);
                    uint32_t new_data = (old_data & ~sel) | (wb_data & sel);
                    *(uint32_t *)(mem.get() + wb_addr - base_addr) = new_data;
                }
            }

            next_ack = 1;
            next_data = *(uint32_t *)(mem.get() + wb_addr - base_addr);
#ifdef DEBUG
            fmt::println(
                "[DEBUG] wb_cycle: {}, wb_we: {}, wb_addr: 0x{:x}, wb_data: "
                "0x{:x}, wb_sel: 0x{:x}, ack_o: {}, data_o: 0x{:x}",
                wb_cycle, wb_we, wb_addr, wb_data, wb_sel, ack_o, data_o);
#endif
        }
    }

    void fetch(uint32_t cycle, uint32_t pc, Instruction &inst_o,
               uint32_t &inst_valid_o) {
        inst_valid_o = cycle && next_ack;
        inst_o = next_inst;
        next_ack = 0;
        if (cycle) {
            next_ack = 1;
            next_inst = *(Instruction *)(mem.get() + pc - base_addr);
        }
    }

    uint32_t &operator[](const uint32_t addr) {
        return *(uint32_t *)(mem.get() + addr - base_addr);
    }

    std::unique_ptr<char> mem;
    uint32_t base_addr;
    uint32_t size;
    int next_ack;
    uint32_t next_data;
    Instruction next_inst;
};