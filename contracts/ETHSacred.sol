pragma solidity 0.5.17;

import "./Sacred.sol";

contract ETHSacred is Sacred {

  constructor(
    IVerifier _verifier,
    uint256 _denomination,
    uint32 _merkleTreeHeight,
    address _operator,
    uint256 _fee
  ) Sacred(_verifier, _denomination, _merkleTreeHeight, _operator, _fee) public {

  }

  function _processDeposit() internal {
    require(msg.value == denomination, "Please send `mixDenomination` ETH along with transaction");
  }

  function _processWithdraw(address payable _recipient, address payable _relayer, uint256 _fee, uint256 _refund) internal {
    // sanity checks
    require(msg.value == 0, "Message value is supposed to be zero for ETH instance");
    require(_refund == 0, "Refund value is supposed to be zero for ETH instance");
    uint256 operatorFee = denomination * fee / 10000;
    (bool success, ) = _recipient.call.value(denomination - _fee - operatorFee)("");
    require(success, "payment to _recipient did not go thru");
    if (_fee > 0) {
      (success, ) = _relayer.call.value(_fee)("");
      require(success, "payment to _relayer did not go thru");
    }

    if (operatorFee > 0) {
      (success, ) = operator.call.value(operatorFee)("");
      require(success, "payment to operator did not go thru");
    }
  }
}
