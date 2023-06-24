// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract Policy {

    string private COMPANY_NAME;
    uint private COMPANY_IDENTIFIER;
    uint public StartContract;
    uint public EndContract;

    bool initialiser;
    address INSURANCE_ADDRESS;

    mapping(uint => uint) Policies;
    // pourcentage de remboursement sur (base de remboursement - montant remboursé sécu)

    event PoliciesChanged(uint timestamp, uint actNumber);

    constructor() {}

    modifier onlyInsurance{
        require (msg.sender== INSURANCE_ADDRESS, "only Insurance can do this");
        _;
    }

    function initialyse (uint[] memory _actNumber, uint[] memory _policies, address _insuranceCompany) public {
        require(initialiser == false, "already initialised");
        initialiser = true;
        for (uint j=0; j<_actNumber.length; j++){
            Policies[_actNumber[j]]=_policies[j];
        }
        INSURANCE_ADDRESS = _insuranceCompany;
    }

    function _modifyPolicies (uint _actNumber, uint _policy) onlyInsurance public {
        Policies[_actNumber] = _policy;
        emit PoliciesChanged(block.timestamp, _actNumber);
    }

    function _getReimbursementValue(uint _price, uint _BRMR, uint _reimburseSecu, uint _actNumber) public view returns (uint){
        require(block.timestamp > StartContract && block.timestamp <= EndContract, "not in time");
        uint value = _BRMR * Policies[_actNumber];
        return value + _reimburseSecu < _price? value: _price - _reimburseSecu; 
    }

}
