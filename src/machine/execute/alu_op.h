#ifndef ALU_OP_H
#define ALU_OP_H

#include <QMetaType>
#include <cstdint>
using std::uint8_t;

namespace machine {

enum class AluOp : uint8_t {
    ADD = 0b0000,
    SLL = 0b0001,
    SLT = 0b0010,
    SLTU = 0b0011,
    XOR = 0b0100,
    SR = 0b0101,
    OR = 0b0110,
    AND = 0b0111,
    // RVV Vector Operations
    VADD_VV = 0b1000, // Vector-vector addition
    VADD_VX = 0b1001, // Vector-scalar addition
    VADD_VI = 0b1010, // Vector-immediate addition
    VMUL_VV = 0b1011, // Vector-vector multiplication (dot product)
    VSETVL = 0b1100,  // Set vector length
    VLW_V = 0b1101,   // Vector load word
    VSW_V = 0b1110,   // Vector store word
};

}

Q_DECLARE_METATYPE(machine::AluOp)

#endif // ALU_OP_H
