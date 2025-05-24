// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract Interaction is Script {

    error ClaimAirdropScript__InvalidSignatureLength();

    MerkleAirdrop private airdrop;
    address private claimingAccount;
    uint256 private amount;
    bytes32  proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32  proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proof1, proof2];

    /*
    forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
    cast call 0xdaE97900D4B184c5D2012dcdB658c008966466DD "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545  
    cast wallet sign --no-hash <HASH> --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    */
   
   bytes private SIGNATURE = hex"f5ab060f78600071b81ee6015d7ac86bde1588f6059cdb3f56a2f56ecb295ed265eb829c50f0e6bed8f7e0a166403797de85ae8b6a0f14fce2bf4f8bb09559341b";

    function run() external {
        address airdropAddr = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        airdrop = MerkleAirdrop(airdropAddr);
        claimAirdrop();
    }

    function claimAirdrop() public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        airdrop.claim(claimingAccount,amount,proof,v,r,s);
        vm.stopBroadcast();
    }

        function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }



}
