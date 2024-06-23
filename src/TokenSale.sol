//  SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface ERC20 {
    function totalSupply() external view returns (uint256 theTotalSupply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TokenSale {
    address TOKENAddress;

    ERC20 public token;

    address USDTTokenAddress;

    ERC20 public usdt;

    address payable public s_owner;
    uint256 public s_tokensOnSale;
    uint256 public s_preSaleStartTime;
    uint256 public s_phaseOne;
    uint256 public s_phaseTwo;
    uint256 public s_phaseThree;
    uint256 public s_ICO_End;

    uint256 public s_pricePhaseOne = 25;
    uint256 public s_pricePhaseTwo = 30;
    uint256 public s_pricePhaseThree = 40;
    uint256 public constant DENOMINATOR = 100;

    uint256 public s_soldToken;
    uint256 public s_amountRaisedUSDT;

    bool public s_presaleStatus;

    struct user {
        uint256 s_usdt_spend;
        uint256 s_token_balance;
    }

    mapping(address => user) public users;

    event TokenBought(address indexed _user, uint256 indexed _amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _TOKENAddress, address _USDTTokenAddress) {
        s_owner = payable(msg.sender);
        s_preSaleStartTime = block.timestamp;
        s_phaseOne = block.timestamp;
        s_phaseTwo = block.timestamp + 10 days;
        s_phaseThree = block.timestamp + 20 days;
        s_ICO_End = block.timestamp + 30 days;
        s_presaleStatus = true;
        token = ERC20(_TOKENAddress);
        usdt = ERC20(_USDTTokenAddress);
        s_tokensOnSale = 5000000 * 10 ** 18;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only Owner can call this function");
        _;
    }

    function tokensLeftForSale() public view returns (uint256) {
        return (s_tokensOnSale - s_soldToken);
    }

    function buyTokens(uint256 usdtAmount, address receiver) public {
        require(s_presaleStatus == true, "Sale has not started yet!!!");
        require(block.timestamp < s_ICO_End, "Sale has end");
        require(s_soldToken <= s_tokensOnSale);
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");
        uint256 numberOfTokens;
        if (block.timestamp < s_phaseTwo) {
            numberOfTokens = (usdtAmount / s_pricePhaseOne) * DENOMINATOR;
        } else if (block.timestamp > (s_phaseOne) && block.timestamp < (s_phaseThree)) {
            numberOfTokens = (usdtAmount / s_pricePhaseTwo) * DENOMINATOR;
        } else {
            numberOfTokens = (usdtAmount / s_pricePhaseThree) * DENOMINATOR;
        }

        require(token.transfer(receiver, numberOfTokens), "Token transfer failed");
        s_soldToken += numberOfTokens;
        s_amountRaisedUSDT += usdtAmount;
        users[msg.sender].s_usdt_spend += usdtAmount;
        users[msg.sender].s_token_balance += numberOfTokens;

        emit TokenBought(msg.sender, numberOfTokens);
    }

    function stopSale() public onlyOwner {
        require(s_presaleStatus == true, "First start the sale to call this function");
        s_presaleStatus = false;
    }

    function startSale() public onlyOwner {
        require(s_presaleStatus == false, "First stop the sale to call this function");
        s_presaleStatus = true;
    }

    function withdrawTokens() public onlyOwner {
        require(s_presaleStatus == false, "Stop sale to withdraw tokens");
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "Contract doesn't have any tokens to withdraw");
        require(token.transfer(s_owner, tokenBalance), "Token transfer failed!!");
    }

    function withdrawUSDT() public onlyOwner {
        uint256 USDTbalance = usdt.balanceOf(address(this));
        require(USDTbalance > 0, "Contract doesn't have any tokens to withdraw");
        require(usdt.transfer(s_owner, USDTbalance), "USDT transfer failed!!");
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(s_owner, newOwner);
        s_owner = newOwner;
    }
}
