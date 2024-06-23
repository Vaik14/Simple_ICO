//  SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract TOKEN is Ownable {
    ///////////////////
    // Errors
    ///////////////////
    error TOKEN__ZeroAddress();
    error TOKEN__AlreadyMinted();

    ///////////////////
    // State Variables
    ///////////////////
    string public s_name;
    string public s_symbol;
    uint8 public decimals;
    bool s_mintAllowed = true;
    uint256 public s_totalSupply;
    uint256 public s_Max_Tokens;
    bool public s_burn_available;
    uint256 public s_burn_interval;
    uint256 public s_lastBurn;
    uint256 public deployedAt;

    //Tokenomics
    address public s_AddressForSale;
    uint256 public s_AllocationForSale;

    address public s_AddressForBurn;
    uint256 public s_AllocationForBurn;

    address public s_AddressForReserve;
    uint256 public s_AllocationForReserve;

    ///////////////////
    // Events
    ///////////////////
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    event Mint(address indexed to, uint256 value);

    ///////////////////
    // Mappings
    ///////////////////
    /// @dev Mapping address with number of tokens
    mapping(address => uint256) public balanceOf;
    /// @dev Mapping allowance given by a user to another
    mapping(address => mapping(address => uint256)) public allowance;

    ///////////////////
    // Functions
    ///////////////////
    constructor() {
        s_symbol = "TOKEN-X";
        s_name = "TOKEN-X";
        decimals = 18;
        s_Max_Tokens = 40_000_000 * 10 ** uint256(decimals);
        s_burn_interval = 90 days;
        s_burn_available = false;
        deployedAt = block.timestamp;
        s_lastBurn = block.timestamp;

        // Tokens Allocation
        s_AllocationForSale = 15_000_000 * 10 ** uint256(decimals);
        s_AllocationForBurn = 2_500_000 * 10 ** uint256(decimals);
        s_AllocationForReserve = 22_500_000 * 10 ** uint256(decimals);
    }

    /**
     * @dev this function is used to burn 5% of tokens of allocation for burn & can only be called once every 90 days
     */
    function burnFivePercentEveryThreeMonths() public {
        require(
            (block.timestamp) > (s_lastBurn + s_burn_interval), "This function can only be called once every 90 days"
        );
        require(msg.sender == s_AddressForBurn, "Caller should be the allocated acount for burn");
        uint256 burnAmout = (s_AllocationForBurn * 5) / 100;
        s_lastBurn = block.timestamp;
        burn(burnAmout);
    }

    /**
     * @param BurnAddress: Address on which the allocated funds for burn will be send
     */
    function mintForBurn(address BurnAddress) external onlyOwner {
        if (s_AddressForBurn != address(0)) {
            revert TOKEN__AlreadyMinted();
        }
        if (BurnAddress == address(0)) {
            revert TOKEN__ZeroAddress();
        }
        s_AddressForBurn = BurnAddress;
        _mint(BurnAddress, s_AllocationForBurn);
    }

    /**
     * @param SaleAddress: Address on which the allocated funds for initial public or private sales.
     */
    function mintForSale(address SaleAddress) external onlyOwner {
        if (s_AddressForSale != address(0)) {
            revert TOKEN__AlreadyMinted();
        }
        if (SaleAddress == address(0)) {
            revert TOKEN__ZeroAddress();
        }
        s_AddressForSale = SaleAddress;
        _mint(SaleAddress, s_AllocationForSale);
    }

    function mintForReserve(address ReserveAddress) external onlyOwner {
        if (s_AddressForReserve != address(0)) {
            revert TOKEN__AlreadyMinted();
        }
        if (ReserveAddress == address(0)) {
            revert TOKEN__ZeroAddress();
        }
        s_AddressForReserve = ReserveAddress;
        _mint(ReserveAddress, s_AllocationForSale);
    }

    /**
     * @param _to: address to which funds will be assigned
     * @param _value: The number of funds which will be assigned
     */
    function _mint(address _to, uint256 _value) public onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert TOKEN__ZeroAddress();
        }
        require(s_Max_Tokens >= s_totalSupply + _value, "Max supply reached!!!");
        require(s_mintAllowed, "Max supply reached!!");
        balanceOf[_to] += _value;
        s_totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Mint(_to, _value);
        return true;
    }

    /**
     * @param _to: address to which funds will be transfered from the callers account
     * @param _value: The number of funds which will be send from senders to receivers account
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @param _spender: address to which is given permission to spend funds on behave of assigner
     * @param _value: The number of funds which will be assigned
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * @param _from: Address from which the funds are spend
     * @param _to: The number of funds which will be transfered
     * @param _value : The number of funds which will be spend
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @param _value: The number of funds which will be destroyed
     */
    function burn(uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "You don't have enough balance!!");
        require(_value > 0, "You can't burn zero funds");
        balanceOf[msg.sender] -= _value;
        s_totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * @param _from: Address from which the funds are spend
     * @param _to: The number of funds which will be transfered
     * @param _value : The number of funds which will be spend
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        if (_to == address(0)) {
            revert TOKEN__ZeroAddress();
        }

        require(balanceOf[_from] >= _value, "You don't have enough funds");
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint256 balanceBeforeTransfer = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        assert(balanceBeforeTransfer == (balanceOf[_from] + balanceOf[_to]));
    }
}
