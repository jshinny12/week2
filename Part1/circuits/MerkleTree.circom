pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    
    var size = 2**n;
    component poseidon[size - 1];
    var index = 0;

    for (var i = 0; i < size; i += 2) {
        poseidon[index] = Poseidon(2);
        poseidon[index].inputs[0] <== leaves[i];
        poseidon[index].inputs[1] <== leaves[i + 1];
        index++;
    }

    var k = 0;
    for (var i = index; i < size - 1; i++) {
        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[0] <== poseidon[2 * k].out;
        poseidon[i].inputs[1] <== poseidon[2 * k + 1].out;
        k++;
    }

    root <== poseidon[size - 2].out;    
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component poseidon[n];

    poseidon[0] = Poseidon(2);
    poseidon[0].inputs[1] <== path_elements[0] - path_index[0]* (path_elements[0] - leaf);
    poseidon[0].inputs[0] <== leaf - path_index[0] * (leaf - path_elements[0]);

    

    for (var i = 1; i < n; i++) {
        poseidon[i] = Poseidon(2);
        poseidon[i].inputs[1] <== path_elements[i] - (path_index[i] * (path_elements[i] - poseidon[i-1].out));
        poseidon[i].inputs[0] <== poseidon[i-1].out - (path_index[i] * (poseidon[i-1].out - path_elements[i]));
    }

    root <== poseidon[n - 1].out;

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

}

