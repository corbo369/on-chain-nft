// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/access/Ownable.sol";

contract BlastBall is Ownable {

    struct Draft {
        uint8 pick;
        address[] drafters; // reorg to order
        // STRUCTURE FOR DRAFT DATA
    }

    // immutable player pool

    uint256 public immutable ENTRY_FEE;

    uint256 public draftIndex;

    uint256 public drafterIndex;

    mapping(uint256 => Draft) internal drafts;

    mapping(uint256 => mapping(address => bool)) public containsDrafter;

    modifier noDoubleEntry() {
        require(!containsDrafter[draftIndex][msg.sender], "No Double Entries");
        containsDrafter[draftIndex][msg.sender] = true;
        _;
    }

    modifier verifyDrafter(uint256 index, address drafter) {
        require(drafts[index].drafters[(drafts[index].pick % 12) - 1] == drafter);
        _;
    }

    constructor(uint256 _fee /* PROVIDE PLAYER POOL */) {
        ENTRY_FEE = _fee;
    }

    function joinCurrentDraft() external payable noDoubleEntry {
        require(msg.value == ENTRY_FEE, "Invalid Entry Fee");

        if (drafterIndex == 0) {
            address[] memory emptyDrafters = new address[](12);
            emptyDrafters[0] = msg.sender;
            drafts[draftIndex] = Draft(0, emptyDrafters);
            drafterIndex++;
        } else if (drafterIndex < 11) {
            drafts[draftIndex].drafters[drafterIndex] = msg.sender;
            drafterIndex++;
        } else {
            // ADD RANDOMIZER
            drafts[draftIndex].drafters[11] = msg.sender;
            drafts[draftIndex].pick = 1;
            drafterIndex = 0;
            draftIndex++;
        }
    }

    function makePick(uint256 index) external verifyDrafter(index, msg.sender) {
        // LOGIC FOR PICKING PLAYER
        drafts[draftIndex].pick++;
    }
}
