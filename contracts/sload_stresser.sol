contract ColdSLOADStresser {
    // Using a large mapping to simulate unique cold SLOADs
    mapping(uint256 => uint256) private randomSlots;

    fallback() external payable {
        assembly {
            let i := 0
            for { } 1 { } {
                // Access unique slots using a sequential counter
                let slot := add(i, randomSlots.slot) // Ensure unique access
                let value := sload(slot) // Perform cold SLOAD
                i := add(i, 1)
            }
        }
    }
}
