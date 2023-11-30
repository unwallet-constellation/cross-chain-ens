// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../interfaces/ENS.sol";
import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

/**
 * A registrar that allocates subdomains to the first person to claim them.
 */
contract FIFSRegistrar is CCIPReceiver {
    ENS ens;
    bytes32 rootNode;
    address private ccipSender; // Used as a sender override in modifier authorised

    struct CCIPPayload {
        address caller;
        bytes4 func;
        bytes params;
    }

    modifier only_owner(bytes32 label) {
        address currentOwner = ens.owner(
            keccak256(abi.encodePacked(rootNode, label))
        );
        require(currentOwner == address(0x0) || currentOwner == _getMsgSender());
        _;
    }

    modifier authenticateCCIP(Client.Any2EVMMessage memory _any2EvmMessage) {
        uint64 sourceChainSelector = _any2EvmMessage.sourceChainSelector;
        address sender = abi.decode(_any2EvmMessage.sender, (address)); // abi-decoding of the sender address
        require(isWhitelisted(sourceChainSelector, sender), "Not whitelisted");
        _;
    }

    /**
     * Constructor.
     * @param ensAddr The address of the ENS registry.
     * @param node The node that this registrar administers.
     */
    constructor(ENS ensAddr, bytes32 node, address _router) CCIPReceiver(_router) {
        ens = ensAddr;
        rootNode = node;
    }

    /// handle a received message from spoke chain
    function _ccipReceive(
        Client.Any2EVMMessage memory _any2EvmMessage
    ) internal override authenticateCCIP(_any2EvmMessage){
        CCIPPayload memory message = abi.decode(_any2EvmMessage.data, (CCIPPayload)); // abi-decoding of the sent string message

        ccipSender = message.caller;
        bytes4 func = message.func;

        if (func == this.register.selector) {
            (bytes32 label, address owner) = abi.decode(message.params, (bytes32, address));
            register(label, owner);
        } else {
            revert("Unknown function selector");
        }

        // Message memory detail = Message(sourceChainSelector, sender, message);
        // emit MessageReceived(messageId, sourceChainSelector, sender, message);
    }

    /**
     * Register a name, or change the owner of an existing registration.
     * @param label The hash of the label to register.
     * @param owner The address of the new owner.
     */
    function register(bytes32 label, address owner) public only_owner(label) {
        ens.setSubnodeOwner(rootNode, label, owner);
    }

    function _getMsgSender() internal view returns (address) {
        if (msg.sender == getRouter()) {
            return ccipSender;
        }
        return msg.sender;
    }

    function isWhitelisted(uint64 _sourceChainSelector, address _sender) public view returns (bool) {
        return true;
    }
}