// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./PolicyFactory.sol";
import "./Policy.sol";
import "./Assu.sol";


contract Secu is PolicyFactory {

    address SECU_ADDRESS;

    mapping (address => address) insuranceCompanyForUSer; // with address of a user, we can find the address of the insurance company
    mapping (address => uint ) InsuranceNumber; // numero d'assurance a partir d'une address
    
    uint[] PoliciesBySecu;


    constructor()  {
        SECU_ADDRESS=msg.sender;
    }


    function updateUser(address _user, address _oldInsurance) public {
        require (insuranceCompany[msg.sender]==true);
        require ( insuranceCompanyForUSer[_user]==_oldInsurance);
        insuranceCompanyForUSer[_user]=msg.sender;
    }

    function reimburseUser(uint _price, uint _actNumber, address _client) public {
        reimburseBySecu( _price, _actNumber, _client);
        if(insuranceCompanyForUSer[_client]!=address(0)){
            reimburseByMutuelle( _price, _actNumber, _client);
        }
    }

    function reimburseBySecu(uint _price, uint _actNumber, address _client) private{
        uint value = _price * PoliciesBySecu[_actNumber];
        (bool success, )= _client.call{value: value}("");
        require (success, "reimbursement impossible, call the secu");
    } 

    function reimburseByMutuelle(uint _price, uint _actNumber, address _client) private{
        address insuranceCompany = insuranceCompanyForUSer[_client];
        Assu(insuranceCompany).reimburseClient( _price, _actNumber, _client);
    }

    function modifyPolicies (uint[] memory _policies)  public {
        require(SECU_ADDRESS==msg.sender);
        PoliciesBySecu = _policies;
    }
}