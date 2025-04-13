// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Refundooor{
    mapping(uint256 => uint256) private storageSlots; // Mapping for sequential storage slots

    // Charge storage slots with unique data
    function chargeStorage(uint256 startSlot, uint256 maxSlots) external {
        for (uint256 i = 0; i < maxSlots; i++) {
            storageSlots[startSlot + i] = startSlot + i + 1; // Non-zero values
        }
    }

    // Optimized fallback for refund-heavy operations
    fallback() external {
        assembly {
            let baseSlot := storageSlots.slot // Get the base slot of the mapping
            let i := 0

            for { } 1 { } {
                // Calculate the storage slot for the mapping key `i`
                let key := add(i, 0) // Start from key 0
                mstore(0x0, key)
                mstore(0x20, baseSlot)
                let slot := keccak256(0x0, 0x40)

                // Perform SLOAD to simulate accessing a cold storage location
                let value := sload(slot)

                // Reset the slot only if it's non-zero
                if iszero(iszero(value)) {
                    sstore(slot, 0)
                }

                // Increment the counter
                i := add(i, 1)

                // Adjust gas threshold to avoid running out of gas
                if lt(gas(), 50000) { stop() }
            }
        }
    }
}
