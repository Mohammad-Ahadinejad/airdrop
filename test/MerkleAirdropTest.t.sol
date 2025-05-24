// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {BagleToken} from "src/BagleToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    address user;
    uint256 userPK;
    uint256 amount_to_claim = 25e18;
    uint256 amount_to_mint = 4 * amount_to_claim;
    bytes32 proof1 =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proof1, proof2];
    bytes32 root =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    BagleToken token;
    MerkleAirdrop airdrop;

    address gasPayer;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (token, airdrop) = deployer.deployMerkleAirdrop();
        (user, userPK) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        bytes32 digest = airdrop.getMessageHash(user, amount_to_claim);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPK, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, amount_to_claim, proof, v, r, s);

        uint256 endingBalance = token.balanceOf(user);

        assertEq(endingBalance - startingBalance, amount_to_claim);
    }
}
