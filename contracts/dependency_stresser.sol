// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice Chained modexp work; auto-flips storage: 0 -> nonzero -> 0 -> ...
/// @dev Each call mixes `tweak` into base/exp so math differs per tx.
contract ModexpWorkchain {
    uint256 public S;

    // Fixed operands (32-byte width for predictable precompile cost)
    uint256 constant BASE0     = 0x6d6974655f776f726b5f626173655f313233343536373839;
    uint256 constant EXPONENT0 = 0x0102030405060708090a0b0c0d0e0f10;
    uint256 constant MOD0      = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f; // secp256k1 p

    /// @param tweak  Arbitrary 256-bit mixer to vary the math each tx.
    /// @param rounds Number of chained modexp calls to execute (>=1).
    function step(uint256 tweak, uint256 rounds) external payable {
        assembly {
            if iszero(rounds) { revert(0, 0) }

            // Read current state once
            let s := sload(0)

            // Memory layout for modexp(0x05): [lenB][lenE][lenM][B][E][M], all 32-byte
            let m := mload(0x40)
            mstore(m, 32)
            mstore(add(m, 32), 32)
            mstore(add(m, 64), 32)

            // Prepare operands, mixing `tweak` so each tx has different math
            let base := xor(BASE0, tweak)                // change residue class
            let exponent := add(EXPONENT0, add(tweak,1)) // avoid accidental zero exponent
            let modn := MOD0

            mstore(add(m, 160), modn)

            let res := 1
            for { let i := 0 } lt(i, rounds) { i := add(i, 1) } {
                mstore(add(m, 96), base)
                mstore(add(m, 128), exponent)

                // call modexp precompile
                if iszero(call(gas(), 0x05, 0, m, 192, add(m, 224), 32)) { revert(0, 0) }
                res := mload(add(m, 224))

                // chain result -> next operands (keeps work strictly sequential)
                base := addmod(base, res, modn)
                exponent := add(exponent, 1)
            }

            // Auto-alternate: if S==0 write non-zero; else write 0
            switch iszero(s)
            case 1 { sstore(0, or(res, 1)) }
            default { sstore(0, 0) }
        }
    }
}
