// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./Secu.sol";
import "./Policy.sol";


contract Assu {

    address SECU;
    address owner;
    mapping (address => address) PoliciesUser; // for a user return its policies;
    mapping (address => bool) PoliciesInAssu; // check if policies is by this assurance

    //Secu(SECU).truc

    // reimbureClient()

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner==msg.sender);
        _;
    }

    modifier onlySecu(){
        require(SECU==msg.sender);
        _;
    }

    function modifyPolicies (address _addr, uint[] memory _policies) public onlyOwner {
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._modifyPolicies(_policies);
    }

    function addClient (address _addr, address _addrClient ) public onlyOwner{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._addClient(_addrClient);
    }

    function removeClient (address _addr, address _addrClient ) public onlyOwner{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._removeClient(_addrClient);
    }


    function reimburseClient(uint _price, uint _actNumber, address _client) public onlySecu{
        address clientPolicy =  PoliciesUser[_client];
        uint value = Policy(clientPolicy)._getReimbursementValue(_price, _actNumber, _client);
        (bool success, )= _client.call{value: value}("");
        require (success, "reimbursement impossible, call the assurance");
    }



}