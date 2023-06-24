// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Policy.sol";
import "./Assu.sol";


contract Secu {

    address SECU_ADDRESS;

    mapping (uint => address) insuranceCompanyForUSer; // with secu code of a user, we can find the address of the insurance company
    mapping (address => bool) isPro; // check if address is of a professionnal
    mapping (address => bool) insuranceCompany; // check if address is one of assu smart contract
    mapping (uint => uint[2]) PoliciesBySecu; // 2 index : base de remboursement et pourcentage de base


    event reimbursedSecu(uint SecuCode, uint value);
    event PolicyCreated(address indexed _policyCreated, address indexed _insuranceCompany);

    constructor()  {
        SECU_ADDRESS=msg.sender;
    }

    function updatePro(address _proAddress, bool _isPro) public {
        require(msg.sender==SECU_ADDRESS, "you cant change pro status");
        isPro[_proAddress]=_isPro;
    }

    function updateAssureur(address _assuAddress, bool _isAssu) public {
        require(msg.sender==SECU_ADDRESS, "you cant change assu status");
        insuranceCompany[_assuAddress]=_isAssu;
    }

    function updateUser(uint _clientsCode) public {
        require (insuranceCompany[msg.sender]==true);
        insuranceCompanyForUSer[_clientsCode]=msg.sender;
    }

    function reimburseUser(uint _price, uint _actNumber, uint _clientsCode) public {
        require(isPro[msg.sender]==true, "you're not a pro");
        uint value= reimburseBySecu( _price, _actNumber, _clientsCode, msg.sender);
        if(insuranceCompanyForUSer[_clientsCode]!=address(0) && _price-value > 0 ){
            reimburseByMutuelle( _price, PoliciesBySecu[_actNumber][0]-value, value, _actNumber, _clientsCode, msg.sender);
        }
    }

    function reimburseBySecu(uint _price, uint _actNumber, uint _clientsCode, address _proAddress) private returns(uint){
        uint value = PoliciesBySecu[_actNumber][0]*PoliciesBySecu[_actNumber][1];
        if(_price < value){
            value = _price;
        }
        (bool success, )= _proAddress.call{value: value}("");
        require (success, "reimbursement impossible, call the secu");
        emit reimbursedSecu(_clientsCode, value);
        return value;
    } 

    function reimburseByMutuelle(uint _price, uint _BRMR, uint _reimburseSecu, uint _actNumber, uint _clientsCode, address _proAddress) private{
        address insuranceCompanyUser = insuranceCompanyForUSer[_clientsCode];
        Assu(insuranceCompanyUser).reimburseClient( _price, _BRMR, _reimburseSecu, _actNumber, _clientsCode, _proAddress);
    }

    function modifyPolicies (uint _actNumber, uint[2] memory _policies)  public {
        require(SECU_ADDRESS==msg.sender);
        PoliciesBySecu[_actNumber] = _policies;
    }


    function createPolicy(uint[] memory _actNumber, uint[] memory _policies, uint[] memory _clients) external returns (address) {
        require (insuranceCompany[msg.sender]==true);
        address policy;

        bytes memory bytecode = type(Policy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(this)));
        assembly {
            policy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Policy(policy).initialyse(_actNumber, _policies, _clients, msg.sender);
        emit PolicyCreated(policy, msg.sender);
        return policy;
    }


}