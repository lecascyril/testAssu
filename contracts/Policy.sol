// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Policy {

    string private COMPANY_NAME;
    uint private COMPANY_IDENTIFIER;
    uint public StartContract;
    uint public EndContract;

    bool initialiser;
    address INSURANCE_ADDRESS;

    uint[] Policies;
    // reimbursement per acts
    // Policy[132] is the percentage of reimbursement of act code 132 for example

    mapping (address => bool) Clients;

    event PoliciesChanged(uint timestamp);
    event ClientChanged(address client);

    constructor() {}

    function initialyse (uint[] memory _policies, address[] memory _clients, address _insuranceCompany) public {
        require(initialiser == false, "already initialised");
        initialiser = true;
        Policies = _policies;
        INSURANCE_ADDRESS = _insuranceCompany;

        for (uint i; i< _clients.length; ++i){
            Clients[_clients[i]] = true;
        }
    }

    modifier onlyInsurance{
        require (msg.sender== INSURANCE_ADDRESS, "only Insurance can do this");
        _;
    }

    function _modifyPolicies (uint[] memory _policies) onlyInsurance public {
        Policies = _policies;
        emit PoliciesChanged(block.timestamp);
    }

    function _addClient (address _addr ) public onlyInsurance{
        require(Clients[_addr]==false, "already a client");
        Clients[_addr]=true;
        emit ClientChanged(_addr);
    }

    function _removeClient (address _addr ) public onlyInsurance{
        require(Clients[_addr]==true, "not a client");
        Clients[_addr]=false;
        emit ClientChanged(_addr);
    }

    function _getReimbursementValue(uint _price, uint _actNumber, address _client) public view returns (uint){
        require (Clients[_client]==true, "not a client");
        require(block.timestamp > StartContract && block.timestamp <= EndContract, "not in time");
        return Policies[_actNumber]*_price;
    }

}
