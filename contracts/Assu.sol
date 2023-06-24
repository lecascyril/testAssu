// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Policy.sol";


contract Assu {

    address SECU;
    address owner;
    mapping (uint => address) PoliciesUser; // for a user secu code return its policies;
    mapping (address => bool) PoliciesInAssu; // check if policies is by this assurance

    event deposit(address whoDeposited, uint valueDeposited);

    constructor(address secu){
        owner = msg.sender;
        SECU = secu;
    }

    modifier onlyOwner() {
        require(owner==msg.sender);
        _;
    }

    modifier onlySecu(){
        require(SECU==msg.sender);
        _;
    }

    function modifyPolicies (address _addr, uint _actNumber, uint _policy) public onlyOwner {
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._modifyPolicies(_actNumber, _policy);
    }

    function addClient (address _addr, uint _clientsCode ) public onlyOwner{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._addClient(_clientsCode);
    }

    function removeClient (address _addr, uint _clientsCode ) public onlyOwner{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._removeClient(_clientsCode);
    }


    function reimburseClient(uint _price, uint _BRMR, uint _reimburseSecu, uint _actNumber, uint _clientsCode, address _pro) public onlySecu{
        address clientPolicy =  PoliciesUser[_clientsCode];
        uint value = Policy(clientPolicy)._getReimbursementValue(_price, _BRMR, _reimburseSecu, _actNumber, _clientsCode );
        (bool success, )= _pro.call{value: value}("");
        require (success, "reimbursement impossible, call the assurance");
    }

    function depositCotisation() payable external{
        emit deposit(msg.sender, msg.value);
    }

    function depositTreasury() payable external onlyOwner{
        emit deposit(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner{
        (bool success, )= owner.call{value: address(this).balance}("");
        require (success, "withdraw impossible");
    }

}