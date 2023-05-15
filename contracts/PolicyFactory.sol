// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./Policy.sol";


contract PolicyFactory {


    mapping (address => bool) insuranceCompany;

    event PolicyCreated(address indexed _policyCreated, address indexed _insuranceCompany);

    constructor()  {}

    function createPolicy(uint[] memory _policies, address[] memory _clients) external returns (address) {
        require (insuranceCompany[msg.sender]==true);
        address policy;

        bytes memory bytecode = type(Policy).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(this)));
        assembly {
            policy := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Policy(policy).initialyse(_policies, _clients, msg.sender);
        emit PolicyCreated(policy, msg.sender);
        return policy;
    }
}