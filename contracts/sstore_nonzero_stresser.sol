// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Refundooor {
    mapping(uint256 => bytes32) private storageSlots;

    // Charge storage with dummy values (non-zero)
    function chargeStorage(uint256 startSlot, uint256 maxSlots) external {
        for (uint256 i = 0; i < maxSlots; i++) {
            storageSlots[startSlot + i] = bytes32(uint256(0x1337 + i));
        }
    }

    fallback() external {
        assembly {
            let baseSlot := storageSlots.slot
            let i := 0

            for {} 1 {} {
                // Compute storage slot: keccak256(abi.encodePacked(i, baseSlot))
                mstore(0x00, i)
                mstore(0x20, baseSlot)
                let slot := keccak256(0x00, 0x40)

                // Write a new non-zero value: (base constant + i)
                // This avoids SLOAD and avoids writing zero
                sstore(slot, add(0xDEADBEEF, i))

                // Increment
                i := add(i, 1)

                // Stop early to avoid running out of gas
                if lt(gas(), 20000) { stop() }
            }
        }
    }
}
