// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Policy.sol";
import "./Secu.sol";


contract Assu {

    address SECU;
    address owner;
    mapping (uint => address) PoliciesUser; // for a user secu code return its policies;
    mapping (address => bool) PoliciesInAssu; // check if policies is by this assurance
    mapping (uint => bool) Insured;

    address[] allPolicies;

    // add admin stuff for user
    // add admin stuff for creating contract

    event InsuredChanged(uint client);
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

    modifier onlyOwnerOuSecu(){
        require(SECU==msg.sender || owner==msg.sender);
        _; 
    }

    function reimburseInsured(uint _price, uint _BRMR, uint _reimburseSecu, uint _actNumber, uint _clientsCode, address _pro) public onlySecu{
        address clientPolicy =  PoliciesUser[_clientsCode];
        uint value = Policy(clientPolicy)._getReimbursementValue(_price, _BRMR, _reimburseSecu, _actNumber );
        (bool success, )= _pro.call{value: value}("");
        require (success, "reimbursement impossible, call the assurance");
    }

// policies stuff

    function modifyPolicies (address _addr, uint _actNumber, uint _policy) public onlyOwner {
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Policy(_addr)._modifyPolicies(_actNumber, _policy);
    }


    function createNewPolicyContract(uint[] memory _actNumber, uint[] memory _policies, uint[] memory _clients) external onlyOwner{
        address newPolicy = Secu(SECU).createPolicy( _actNumber, _policies);
        PoliciesInAssu[newPolicy]=true;
        allPolicies.push(newPolicy);

        for(uint i; i<_clients.length;i++){
            addInsured(newPolicy,_clients[i]);
        }
    }


// assuré stuff

    function addInsured (address _addr, uint _secuCode ) public onlyOwnerOuSecu{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        Secu(SECU).removeInsured(_secuCode);
        Secu(SECU).updateUser(_secuCode, address(this));
        PoliciesUser[_secuCode]=_addr;
        Insured[_secuCode]=true;
        emit InsuredChanged(_secuCode);    
    }

    function removeInsured (address _addr, uint _secuCode ) public onlyOwnerOuSecu{
        require(PoliciesInAssu[_addr]== true, "not a policy we have");
        require(Insured[_secuCode]==true, "not a client");
        delete PoliciesUser[_secuCode];
        delete Insured[_secuCode];
        Secu(SECU).updateUser(_secuCode, address(0));
        emit InsuredChanged(_secuCode);    
    }

// money stuff

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

    function getPolicy(uint _secuCode) onlyOwnerOuSecu public view returns (address){
        return PoliciesUser[_secuCode];
    }

}