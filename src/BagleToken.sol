// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {ERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract BagleToken is ERC20, Ownable {
    constructor() ERC20("BagleToken", "Bagle") Ownable(msg.sender) {}

    function mint(address account, uint256 value) external onlyOwner {
        super._mint(account, value);
    }
}
