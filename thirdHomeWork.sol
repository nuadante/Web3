// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";



contract CrowdFund {
    
    struct Campaign {
        address creator;
        uint256 goal;
        uint32 starting;
        uint32 ending;
        uint256 totalContribution;
        bool claimed;
    }

    event BeginCampaign(uint256 id, address indexed creator, uint256 goal, uint32 startAt, uint32 endAt);
    event CancelCampaign(uint256 id);
    event ContributeToCampaign(uint256 indexed id, address indexed contributor, uint256 amount);
    event WithdrawFromCampaign(uint256 indexed id, address indexed contributor, uint256 amount);
    event ClaimFunds(uint256 indexed id, uint256 amount);
    event Refund(uint256 indexed id, address indexed contributor, uint256 amount);

    IERC20 public immutable token;
    uint256 public campaignID;

    mapping(uint256 => Campaign) public campaignList;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    constructor(address _token) {
        token = IERC20(_token);
    }


    modifier _beginbeginCampaign(uint256 _goal, uint32 _starting, uint32 _ending){
        require(_starting >= block.timestamp, "starting must be in the future");
        require(_ending >= _starting, "ending must be after start at");
        require(_ending <= block.timestamp + 90 days, "Max ending is 90 days");
        require(_goal > 0, "Goal have to greater than 0");
        _;

    }

    function beginCampaign(uint256 _goal, uint32 _starting, uint32 _ending) external _beginbeginCampaign( _goal, _starting, _ending){


        campaignID += 1;
        campaignList[campaignID] = Campaign({
            creator: msg.sender,
            goal: _goal,
            starting: _starting,
            ending: _ending,
            totalContribution: 0,
            claimed: false
        });

        emit BeginCampaign(campaignID, msg.sender, _goal, _starting, _ending);

    }

    function cancelCampaign(uint256 _id) external {
    
        Campaign memory campaign = campaignList[_id];

        require(campaign.creator == msg.sender, "Only creator can cancel");
        require(block.timestamp < campaign.starting, "Campaign already started");

        delete campaignList[_id];

        emit CancelCampaign(_id);

    }

    function contributeToCampaign(uint256 _id, uint256 _amount) external {
     
        Campaign storage campaign = campaignList[_id];

        require(block.timestamp >= campaign.starting, "Campaign not started");
        require(block.timestamp <= campaign.ending, "Campaign already ended");

        campaign.totalContribution += _amount;
        contributions[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit ContributeToCampaign(_id, msg.sender, _amount);

    }

    function withdrawFromCampaign(uint256 _id, uint256 _amount) external {

        Campaign storage campaign = campaignList[_id];

        require(block.timestamp >= campaign.starting, "Campaign not started");
        require(block.timestamp <= campaign.ending, "Campaign already ended");

        uint256 callerContribution = contributions[_id][msg.sender];

        require(callerContribution >= _amount, "Not enough contribution");

        contributions[_id][msg.sender] -= _amount;
        campaign.totalContribution -= _amount;
        token.transfer(msg.sender, _amount);

        emit WithdrawFromCampaign(_id, msg.sender, _amount);

    }

    function claimFunds(uint256 _id) external {

        Campaign storage campaign = campaignList[_id];

        require(msg.sender == campaign.creator, "Only creator can claim.");
        require(block.timestamp > campaign.ending, "Campaign not ended yet.");
        require(campaign.totalContribution >= campaign.goal, "Goal not reached. That is why you can not withdraw contributions.");
        require(!campaign.claimed, "Funds already claimed.");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.totalContribution);

        emit ClaimFunds(_id, campaign.totalContribution);

    }

    function getRefund(uint256 _id) external {
      
        Campaign storage campaign = campaignList[_id];

        require(block.timestamp > campaign.ending, "Campaign not ended yet.");
        require(campaign.totalContribution < campaign.goal, "Goal reached. That is why you can not get refund.");

        uint256 callerContribution = contributions[_id][msg.sender];
        
        require(callerContribution > 0, "No contribution to refund.");

        contributions[_id][msg.sender] = 0;
        campaign.totalContribution -= callerContribution;
        token.transfer(msg.sender, callerContribution);

        emit Refund(_id, msg.sender, callerContribution);

    }

}