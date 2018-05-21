pragma solidity ^0.4.22;

// ----------------------------------------------------------------------------
// 'EXT' 'Example token' token contract
//
// Symbol      : EXT
// Name        : Example token
// Total supply: 1,000,000.000000000000000000
// Decimals    : 18
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ERC Token Standard #20 Interface
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
     
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Contract function to receive approval and execute function in one call
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// Owned contract
contract Owned {
    address public owner;
    address public newOwner;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier OnlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    function transferOwnership(address _newOwner) public OnlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require (msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    
}

// ERC20 Token, with the addition of symbol, name and decimals and an initial fixed supply
contract ExampleToken is ERC20Interface, Owned {
 
    using SafeMath for uint;
    
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    
    constructor() public {
        symbol = 'EXT';
        name = 'Example token';
        decimals = 18;
        _totalSupply = 1000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    // Return total supply
    function totalSupply() public constant returns(uint) {
        return _totalSupply - balances[address(0)];
    }
    
    // Get balance of token owner
    function balanceOf(address tokenOwner) public constant returns(uint balance) {
        return balances[tokenOwner];
    }
    
    // Transfer tokens from tokenOwner to another address
    function transfer(address to, uint tokens) public returns(bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    // Delegate to another address to spend tokens
    function approve(address spender, uint tokens) public returns(bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    // Transfer tokens between addresses
    function transferFrom(address from, address to, uint tokens) public returns(bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    // Get back allowed tokens to spender to tokenOwner
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    
    // If nothing is executed prevent to recieve ETH
    function () public payable {
        revert();
    }
    
    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public OnlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}