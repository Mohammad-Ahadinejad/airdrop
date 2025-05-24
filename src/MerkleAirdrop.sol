// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import {MerkleProof} from "@openzeppelin/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "@openzeppelin/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__notVerified();
    error MerkleAirdrop__alreadyClaimed();
    error MerkleAirdrop__notValidSignature();

    event ClaimedSuccessfully(address account, uint256 amount);

    struct ClaimReq {
        address account;
        uint256 amount;
    }
    bytes32 private constant CLAIMREQ_TYPE_HASH =
        keccak256("ClaimReq(address account, uint256 amount)");

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_bagleToken;

    mapping(address => bool) private s_hasClaimed;

    constructor(
        bytes32 merkleRoot,
        IERC20 bagleToken
    ) EIP712("merkle-airdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_bagleToken = bagleToken;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] memory proof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__alreadyClaimed();
        }

        bytes32 messageHash = getMessageHash(account, amount);

        if (!_isValidSignature(account, messageHash, v, r, s)) {
            revert MerkleAirdrop__notValidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (!MerkleProof.verify(proof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__notVerified();
        }
        s_hasClaimed[account] = true;
        emit ClaimedSuccessfully(account, amount);
        i_bagleToken.safeTransfer(account, amount);
    }

    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        CLAIMREQ_TYPE_HASH,
                        ClaimReq({account: account, amount: amount})
                    )
                )
            );
    }

    function _isValidSignature(
        address account,
        bytes32 mesaageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal returns (bool) {
        (address signer, , ) = ECDSA.tryRecover(mesaageHash, v, r, s);
        return account == signer;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getBagelTokenAddress() external view returns (address) {
        return address(i_bagleToken);
    }
}
