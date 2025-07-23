// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Refundooor {
    mapping(uint256 => uint256) private storageSlots;

    /// @notice Pre‑fill `maxSlots` keys starting at `startKey`
    function chargeStorage(uint256 startKey, uint256 maxSlots) external {
        for (uint256 i = 0; i < maxSlots; i++) {
            storageSlots[startKey + i] = startKey + i + 1;
        }
    }

    /// @notice Clears exactly MAX_LOOPS slots unconditionally (no checks)
    fallback() external {
        assembly {
            // cache the mapping’s base slot
            let base := storageSlots.slot
            mstore(0x20, base)

            // MAX_LOOPS * ~5,109 gas/iter ≈ 45 000 000 gas
            let MAX_LOOPS := 8805

            for { let i := 0 } lt(i, MAX_LOOPS) { i := add(i, 1) } {
                // compute storage slot for key = i
                mstore(0x0, i)
                let s := keccak256(0x0, 0x40)
                // unconditionally write zero
                sstore(s, 0)
            }
        }
    }
}
