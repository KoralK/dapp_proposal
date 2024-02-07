// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address public owner;
    uint256 private counter;
    mapping(uint256 => Proposal) private proposal_history;
    mapping(address => bool) private voted;

    struct Proposal {
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool is_active;
    }

    constructor() {
        owner = msg.sender;
        voted[msg.sender] = true; // Initial vote from owner to start
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isActive() {
        require(proposal_history[counter].is_active, "Proposal not 
active");
        _;
    }

    modifier newVoter() {
        require(!voted[msg.sender], "Already voted");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function createProposal(string calldata description, uint256 
totalVoteToEnd) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(description, 0, 0, 0, 
totalVoteToEnd, true);
    }

    function vote(uint8 choice) external isActive newVoter {
        Proposal storage proposal = proposal_history[counter];
        voted[msg.sender] = true;
        if (choice == 1) proposal.approve++;
        else if (choice == 2) proposal.reject++;
        else if (choice == 0) proposal.pass++;
        
        // Evaluate proposal state and possibly deactivate
        if (proposal.approve + proposal.reject + proposal.pass >= 
proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    function terminateProposal() external onlyOwner isActive {
        proposal_history[counter].is_active = false;
    }

    function isVoted(address _address) public view returns (bool) {
        return voted[_address];
    }

    function getCurrentProposal() external view returns (Proposal memory) 
{
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns (Proposal 
memory) {
        return proposal_history[number];
    }
}
