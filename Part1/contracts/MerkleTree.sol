//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract
import "hardhat/console.sol";

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 public numLeaves;
    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](15);
        root = 0;
        for (uint i = 0; i < 15; i++) {
            hashes[i] = 0;
        }
        numLeaves = 8;
        index = 0;

    }
 
    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // index++;
        // uint hashsize = (numLeaves * 2) - 1;
        // if (index > numLeaves) {
        //     uint newSize = (2 * hashsize) + 1;
        //     uint256[] memory newHashes = new uint256[](newSize);
        //     for (uint i = 0; i < numLeaves; i++) {
        //         newHashes[i] = hashes[i];
        //     }
        //     hashes = newHashes;
        //     numLeaves *= 2;
        // }

        hashes[index] = hashedLeaf;
        index++;
        uint hashsize = numLeaves * 2 - 1;

        for (uint i = 0; i < hashsize - 1; i += 2) {
            uint key = (numLeaves - (i / 2)) + i;
            hashes[key] = PoseidonT3.poseidon([hashes[i], hashes[i + 1]]);
        }

        
        root = hashes[hashes.length - 1];
        return root;

    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
            
            bool x = verifyProof(a, b, c, input);
            return x && (root == input[0]);

        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
