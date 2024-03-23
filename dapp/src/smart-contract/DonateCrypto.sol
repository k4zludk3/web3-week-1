// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

struct Campaign {
    uint256 balance;
    bool    active;
    address author;
    string  title;
    string  description;
    string  cnpj;
    string  videoUrl;
    string  imageUrl;
}       

contract DonateCrypto {

    //the required fee as reward to the contract when is make a withdraw.
    uint256 public fee = 100; 
    uint256 public nextId = 0;

    mapping(uint256 => Campaign) public campaigns; //id => campanha

    function addCampaign(string calldata title, string calldata description, string calldata cnpj) public {
        Campaign memory newCampaign;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.cnpj = cnpj;
        newCampaign.active = true;
        newCampaign.author = msg.sender;

        nextId++;
        campaigns[nextId] = newCampaign;
    }

    function donate(uint256 id) public payable {
        require(msg.value > 0, "You must send a donation value > 0");
        require(campaigns[id].active == true, "Cannot donate to this campaign");

        campaigns[id].balance += msg.value;
    }

    function withdraw(uint256 id) public {

        Campaign memory campaign = campaigns[id];

        require(campaign.author == msg.sender, "You do not have permission");
        require(campaign.active == true, "This campaign is closed");
        require(campaign.balance > fee, "This campaign does not have enough balance");

        address payable recipient = payable(campaign.author);
        (bool success, ) = recipient.call{value: campaign.balance - fee}("");
        require(success, 'Transfer failed.');
        campaigns[id].active = false;
    }

}