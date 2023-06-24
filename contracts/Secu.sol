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

// admin stuff

    function updatePro(address _proAddress, bool _isPro) public {
        require(msg.sender==SECU_ADDRESS, "you cant change pro status");
        isPro[_proAddress]=_isPro;
    }

    function updateAssureur(address _assuAddress, bool _isAssu) public {
        require(msg.sender==SECU_ADDRESS, "you cant change assu status");
        insuranceCompany[_assuAddress]=_isAssu;
    }

    function updateUser(uint _clientsCode, address _newCompany) public {
        require(msg.sender == SECU_ADDRESS || insuranceCompany[msg.sender]==true );
        insuranceCompanyForUSer[_clientsCode]=_newCompany;
    }

    function removeInsured(uint _secuCode) public {
        require(msg.sender == SECU_ADDRESS || insuranceCompany[msg.sender]==true );
        address oldAssuCompany=insuranceCompanyForUSer[_secuCode];
        if(oldAssuCompany != address(0)){
            address oldPolicy = Assu(oldAssuCompany).getPolicy(_secuCode);
            Assu(oldAssuCompany).removeInsured(oldPolicy, _secuCode);
        }
    }

    function modifySecuPolicies (uint _actNumber, uint[2] memory _policies)  public {
        require(SECU_ADDRESS==msg.sender);
        PoliciesBySecu[_actNumber] = _policies;
    }

// reimburse stuff

    function reimburseUser(uint _price, uint _actNumber, uint _clientsCode) public {
        require(isPro[msg.sender]==true, "you're not a pro");
        uint value= reimburseBySecu( _price, _actNumber, _clientsCode, msg.sender);
        if(insuranceCompanyForUSer[_clientsCode]!=address(0) && _price > value ){
            reimburseByMutuelle( _price, PoliciesBySecu[_actNumber][0]-value, value, _actNumber, _clientsCode, msg.sender);
        }
    }

    function reimburseBySecu(uint _price, uint _actNumber, uint _secuCode, address _proAddress) private returns(uint){
        uint value = (PoliciesBySecu[_actNumber][0]*PoliciesBySecu[_actNumber][1])/100;
        if(_price < value){
            value = _price;
        }
        (bool success, )= _proAddress.call{value: value}("");
        require (success, "reimbursement impossible, call the secu");
        emit reimbursedSecu(_secuCode, value);
        return value;
    } 

    function gettruc(uint _secuCode)public view returns(address){
        return insuranceCompanyForUSer[_secuCode];
    }

    function reimburseByMutuelle(uint _price, uint _BRMR, uint _reimburseSecu, uint _actNumber, uint _secuCode, address _proAddress) private {
        address insuranceCompanyUser = insuranceCompanyForUSer[_secuCode];
        Assu(insuranceCompanyUser).reimburseInsured( _price, _BRMR, _reimburseSecu, _actNumber, _secuCode, _proAddress);
    }

    function addSecuTreasury() public payable{
    }

// factory callable by insurance company

    function createPolicy(uint[] memory _actNumber, uint[] memory _policies) external returns (address) {
        require (insuranceCompany[msg.sender]==true);
        address policy;

        bytes memory bytecode = type(Policy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(this)));
        assembly {
            policy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Policy(policy).initialyse(_actNumber, _policies, msg.sender);

        /* remove client to old contracts and link to new insurance company, useless with assu
        for(uint i; i<_clients.length;i++){
            removeInsured(_clients[i]);
            insuranceCompanyForUSer[_clients[i]]= policy;
        } */

        emit PolicyCreated(policy, msg.sender);
        return policy;
    }


}