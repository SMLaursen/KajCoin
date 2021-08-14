// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract KajCoin is ERC20, Ownable {
	IERC20 public daiInstance;
	uint256 collectableDaiFees = 0;

	constructor (IERC20 _daiInstance) ERC20("KajCoin", "KAJ") Ownable(){
		daiInstance = _daiInstance;
		_mint(address(this), 10_000_000 ** uint(decimals()));
	}

	function buyKAJforDAI(uint256 daiAmount) external {
		uint256 fee = daiAmount / 1000;
		uint256 kajAmount = daiAmount - fee;
		
		require(balanceOf(address(this)) >= kajAmount, "Insufficient KAJ in contract!");

		//requires DAI Approval of daiAmount
		bool success = daiInstance.transferFrom(msg.sender, address(this), daiAmount);
		require(success, "DAI transfer failed");

		success = approve(address(this), kajAmount);
		require(success, "kaj approval failed");

		success = transferFrom(address(this), msg.sender, kajAmount);
		require(success, "kaj transfer failed");

		collectableDaiFees+= fee;
	}

	function sellKAJforDAJ(uint256 kajAmount) external {
		uint256 fee = kajAmount / 1000;
		uint256 daiAmount = kajAmount - fee;
		
		require(daiInstance.balanceOf(address(this)) - collectableDaiFees >= daiAmount, "Insufficient DAI in contract!");

		bool success = daiInstance.approve(address(this), daiAmount);
		require(success, "DAI approval failed");

		success = daiInstance.transferFrom(address(this), msg.sender, daiAmount);
		require(success, "DAI transfer failed");

		//requires KAJApproval of kajAmount
		success = transfer(address(this), kajAmount);
		require(success, "kaj transfer failed");

		collectableDaiFees+= fee;
	}

	function getCollectableFees() external view returns(uint256) {
		return collectableDaiFees;
	}

	function collectFees() external onlyOwner {
		require(collectableDaiFees > 0);

		bool success = daiInstance.approve(address(this), collectableDaiFees);
		require(success, "DAI approval failed");

		success = daiInstance.transfer(address(this), collectableDaiFees);
		require(success, "DAI transfer failed");

		collectableDaiFees = 0;
	}

}
