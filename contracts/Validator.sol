// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Validate {

    function isValidLine(uint8[5] calldata line) internal pure returns (bool) {
        
        if(isRowValid(line) || isColValid(line) || isMainDiagonalValid(line) || isAntiDiagonalValid(line)){
            return true;
        }
        else{
            return false;
        }
    }


    function isRowValid (uint8[5] calldata line) internal pure returns (bool){
         uint8 row = line[0] / 5;

        for (uint256 i = 1; i < 5; i++) {
            if (line[i] / 5 != row) {
            return false;
            }
        }
        
         return true;
    }

    function isColValid (uint8[5] calldata line) internal pure returns (bool){
        uint8 col  = line[0] % 5 ;

        for(uint256 i = 1 ; i < 5 ; i++){
            if(line[i] % 5 != col) return false;
        }

        return true;
    }

    function isMainDiagonalValid(uint8[5] calldata line) internal pure returns (bool){
        for (uint256 i = 0; i < 5; i++) {
            if (line[i] % 6 != 0) return false;
    }
        return true;
    }

    function isAntiDiagonalValid(uint8[5] calldata line) internal pure returns (bool) {
        for (uint256 i = 0; i < 5; i++) {
        uint8 idx = line[i];
        if (idx % 4 != 0 || idx == 0 || idx == 24) {
            return false;
        }
        }
        return true;
    }
}


