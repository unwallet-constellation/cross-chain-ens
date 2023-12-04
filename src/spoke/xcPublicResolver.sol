// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPSenderBase.sol";

contract xcPublicResolver is CCIPSenderBase {
    uint256 private immutable COIN_TYPE;

    constructor(uint256 coinType, address _router, uint64 _destinationChainSelector, address _receiverAddress, address _feeToken) 
        CCIPSenderBase(_router, _destinationChainSelector, _receiverAddress, _feeToken) {
            COIN_TYPE = coinType;
        }

    receive() external payable {}

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param a The address to set.
     */
    function setAddr(
        bytes32 node,
        address a
    ) external {
        setAddr(node, COIN_TYPE, addressToBytes(a));
    }

    function setAddr(
        bytes32 node,
        uint256 coinType,
        bytes memory a
    ) public {
        _sendMessage(
            bytes4(keccak256("setAddr(bytes32,uint256,bytes)")),
            abi.encode(node, coinType, a)
        );
    }

    /**
     * Sets the name associated with an ENS node, for reverse records.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     */
    function setName(
        bytes32 node,
        string calldata newName
    ) public {
        _sendMessage(
            this.setName.selector,
            abi.encode(node, newName)
        );
    }

    /**
     * Sets an interface associated with a name.
     * Setting the address to 0 restores the default behaviour of querying the contract at `addr()` for interface support.
     * @param node The node to update.
     * @param interfaceID The EIP 165 interface ID.
     * @param implementer The address of a contract that implements this interface for this node.
     */
    function setInterface(
        bytes32 node,
        bytes4 interfaceID,
        address implementer
    ) public {
        _sendMessage(
            this.setInterface.selector,
            abi.encode(node, interfaceID, implementer)
        );
    }

    /**
     * @dev Approve a delegate to be able to updated records on a node.
     */
    function approve(bytes32 node, address delegate, bool approved) public {
        _sendMessage(
            this.approve.selector,
            abi.encode(node, delegate, approved)
        );
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        _sendMessage(
            this.setApprovalForAll.selector,
            abi.encode(operator, approved)
        );
    }

    /**
     * Increments the record version associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     */
    function clearRecords(bytes32 node) public {
        _sendMessage(
            this.clearRecords.selector,
            abi.encode(node)
        );
    }

    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}
