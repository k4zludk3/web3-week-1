//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from 'forge-std/Test.sol';
import {DonateCrypto} from '../src/smart-contract/DonateCrypto.sol';

contract DonateCryptoTest is Test{

    DonateCrypto public dc;
    uint256 public initialCampaignId;
    //8b66cdcc566be19e9f4133f850b22955cce42ba06e44c6b9f2088f1eff8e3128

    function setUp() public{
        dc = new DonateCrypto();
        dc.addCampaign("Save the Trees", "Help plant tress", "00.000.000/0001-00");
        initialCampaignId = dc.nextId();
    }

    function testAddCampaign() public {
        string memory title = "Clean the Oceans";
        string memory description = "A campaign to clean the oceans";
        string memory cnpj = "00.000.000/0002-00";

        uint256 campaignIdBefore = dc.nextId();
        dc.addCampaign(title, description, cnpj);
        uint256 campaignIdAfter = dc.nextId();

        assertTrue(campaignIdBefore != campaignIdAfter, "Campaign ID do not match");

        (uint256 balance, bool active, address author, string memory retrvTitle, string memory retrvDescription, , ,) = dc.campaigns(campaignIdAfter);

        assertTrue(active, "Campaign is not active");
        assertEq(retrvTitle, title, "Titles do not match");
        assertEq(balance, 0, "Initial balance is not zero");
    }

    function testDonationIncreasesBalance() public{
        uint256 donationAmount = 1 ether;
        address donor = address(0x1);
        
        vm.deal(donor, donationAmount); //Sets an address' balance
        //Sets the call's 'msg.sender' to be the input address 
        vm.startPrank(donor); 
        dc.donate{value: donationAmount}(initialCampaignId);
        console.log("# initialCampaignId : ", initialCampaignId);
        vm.stopPrank(); 
        (uint256 balance, , , , , , , ) = dc.campaigns(initialCampaignId);
        assertEq(balance, donationAmount);
    }

    function testDonateToNonexistentCampaign() public {
        uint256 nonexistentCampaignId = dc.nextId() + 999; // Assuming this ID doesn't exist
        vm.expectRevert("Cannot donate to this campaign");
        dc.donate{value: 1 ether}(nonexistentCampaignId);
    }

    function testWithdrawalByNonAuthor() public {
        address nonAuthor = address(0x2);
        vm.deal(nonAuthor, 10 ether);
        vm.startPrank(nonAuthor);

        vm.expectRevert("You do not have permission");
        dc.withdraw(initialCampaignId);

        vm.stopPrank();
    }


}