// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Policy {

    string private COMPANY_NAME;
    uint private COMPANY_IDENTIFIER;
    uint public StartContract;
    uint public EndContract;

    bool initialiser;
    address INSURANCE_ADDRESS;

    mapping(uint => uint) Policies;
    // pourcentage de remboursement sur (base de remboursement - montant remboursé sécu)

    mapping (uint => bool) Clients;

    event PoliciesChanged(uint timestamp, uint actNumber);
    event ClientChanged(uint client);

    constructor() {}

    function initialyse (uint[] memory _actNumber, uint[] memory _policies, uint[] memory _clientsCode, address _insuranceCompany) public {
        require(initialiser == false, "already initialised");
        initialiser = true;
        for (uint j=0; j<_actNumber.length; j++){
            Policies[_actNumber[j]]=_policies[j];
        }
        INSURANCE_ADDRESS = _insuranceCompany;

        for (uint i; i< _clientsCode.length; ++i){
            Clients[_clientsCode[i]] = true;
        }
    }

    modifier onlyInsurance{
        require (msg.sender== INSURANCE_ADDRESS, "only Insurance can do this");
        _;
    }

    function _modifyPolicies (uint _actNumber, uint _policy) onlyInsurance public {
        Policies[_actNumber] = _policy;
        emit PoliciesChanged(block.timestamp, _actNumber);
    }

    function _addClient (uint _secuCode ) public onlyInsurance{
        require(Clients[_secuCode]==false, "already a client");
        Clients[_secuCode]=true;
        emit ClientChanged(_secuCode);
    }

    function _removeClient (uint _clientsCode ) public onlyInsurance{
        require(Clients[_clientsCode]==true, "not a client");
        Clients[_clientsCode]=false;
        emit ClientChanged(_clientsCode);
    }

    function _getReimbursementValue(uint _price, uint _BRMR, uint _actNumber, uint _client) public view returns (uint){
        require (Clients[_client]==true, "not a client");
        require(block.timestamp > StartContract && block.timestamp <= EndContract, "not in time");
        uint value = _BRMR * Policies[_actNumber];
        return value < _price? value: _price;
    }

}
