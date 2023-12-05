pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Controllable is Ownable {
    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController() {
        require(controllers[_msgSender()], "Controllable: Caller is not a controller");
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {
        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }
}
