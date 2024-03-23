// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/smart-contract/DonateCrypto.sol";

contract DonateCryptoScript is Script {
    DonateCrypto donateCrypto;

    function run() external {
        vm.startBroadcast(0x8b66cdcc566be19e9f4133f850b22955cce42ba06e44c6b9f2088f1eff8e3128); // Start broadcasting transactions

        // Deploy the DonateCrypto contract
        donateCrypto = new DonateCrypto();
        console.log("# ADDRESS : ", address(donateCrypto));
        // Add a new campaign
        string memory title = "Save the Ocean";
        string memory description = "Help clean the ocean.";
        string memory cnpj = "12.345.678/0001-91";
        donateCrypto.addCampaign(title, description, cnpj);

        address donor = msg.sender;
        vm.deal(donor, 10 ether);
        // Donate to the newly created campaign (campaignId = 1)
        uint256 campaignId = 1;
        uint256 donationAmount = 0.02 ether;
        donateCrypto.donate{value: donationAmount}(campaignId);

        // Assume that the contract caller is also the campaign author, so that withdraw from the campaign works
        donateCrypto.withdraw(campaignId);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
