// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {BagleToken} from "src/BagleToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 root =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 amount_to_claim = 25e18;
    uint256 amount_to_mint = 4 * amount_to_claim;

    function run() public returns (BagleToken, MerkleAirdrop) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (BagleToken, MerkleAirdrop) {
        vm.startBroadcast();
        BagleToken token = new BagleToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(root, token);
        token.mint(address(airdrop), amount_to_mint);
        vm.stopBroadcast();
        return (token, airdrop);
    }
}
