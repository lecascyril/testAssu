// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./PolicyFactory.sol";
import "./Policy.sol";
import "./Assu.sol";


contract Secu is PolicyFactory {

    address SECU_ADDRESS;

    mapping (uint => address) insuranceCompanyForUSer; // with secu code of a user, we can find the address of the insurance company
    mapping (address => bool) isPro; // check if address is of a professionnal
    
    mapping(uint => uint[2]) PoliciesBySecu; // 2 index : base de remboursement et pourcentage de base


    constructor()  {
        SECU_ADDRESS=msg.sender;
    }

    function updateUser(address _proAddress, bool _isPro) public {
        require(msg.sender==SECU_ADDRESS, "you cant change pro status");
        isPro[_proAddress]=_isPro;
    }


    function updateUser(uint _clientsCode, address _oldInsurance) public {
        require (insuranceCompany[msg.sender]==true);
        require ( insuranceCompanyForUSer[_clientsCode]==_oldInsurance);
        insuranceCompanyForUSer[_clientsCode]=msg.sender;
    }

    function reimburseUser(uint _price, uint _actNumber, uint _clientsCode) public {
        require(isPro[msg.sender]==true, "you're not a pro");
        uint value= reimburseBySecu( _price, _actNumber, _clientsCode, msg.sender);
        if(insuranceCompanyForUSer[_clientsCode]!=address(0)){
            reimburseByMutuelle( _price, PoliciesBySecu[_actNumber][0]-value, _actNumber, _clientsCode, msg.sender);
        }
    }

    function reimburseBySecu(uint _price, uint _actNumber, uint _clientsCode, address _proAddress) private returns(uint){
        uint value = PoliciesBySecu[_actNumber][0]*PoliciesBySecu[_actNumber][1];
        require(_price >= value, "cant pay more than what was payed");
        (bool success, )= _proAddress.call{value: value}("");
        require (success, "reimbursement impossible, call the secu");
        return value;
        // mettre un event
    } 

    function reimburseByMutuelle(uint _price, uint _BRMR, uint _actNumber, uint _clientsCode, address _proAddress) private{
        address insuranceCompany = insuranceCompanyForUSer[_clientsCode];
        Assu(insuranceCompany).reimburseClient( _price, _BRMR, _actNumber, _clientsCode, _proAddress);
    }

    function modifyPolicies (uint _actNumber, uint[2] memory _policies)  public {
        require(SECU_ADDRESS==msg.sender);
        PoliciesBySecu[_actNumber] = _policies;
    }
}