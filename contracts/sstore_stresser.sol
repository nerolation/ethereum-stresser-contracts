// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Refundooor {
    mapping(uint256 => uint256) private storageSlots; // Mapping for sequential storage slots

    // Charge storage slots with unique data
    function chargeStorage(uint256 startSlot, uint256 maxSlots) external {
        for (uint256 i = 0; i < maxSlots; i++) {
            storageSlots[startSlot + i] = startSlot + i + 1; // Non-zero values
        }
    }

    // Fallback that only empties storage slots (no sload)
    fallback() external {
        assembly {
            let baseSlot := storageSlots.slot
            let i := 0

            // Loop infinitely, stopping if we run below a gas threshold
            for { } 1 { } {
                // Calculate the slot for the key `i`
                mstore(0x00, i)
                mstore(0x20, baseSlot)
                let slot := keccak256(0x00, 0x40)

                // Unconditionally zero out the slot
                sstore(slot, 0)

                // Increment
                i := add(i, 1)

                // Stop when we're low on gas
                if lt(gas(), 50000) { stop() }
            }
        }
    }
}
