pragma solidity ^0.4.18;
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract InaCoin is StandardToken {
    string public name = "INACOIN";
    string public symbol = "INA";
    uint public decimals = 18;

    mapping(address => string) public thanksMessage;

    constructor(uint _initialSupply) public {
        totalSupply_ = _initialSupply;
        balances[msg.sender] = _initialSupply;
    }

    // thanksMessage を送ると 1INAも一緒に送られる
    function thanks(address _to, string _message) public {
        transfer(_to, 1e18);
        thanksMessage[_to] = _message;
    }

    //最新の thanksMessage を見る
    function thanksMessage(address _address) public constant returns (string) {
        return thanksMessage[_address];
    }
}