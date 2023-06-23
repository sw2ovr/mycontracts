pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract MultisigContract {
    address private owner;
    uint private signatureThreshold;
    uint private countApprovers;
    mapping (address => bool) private approvers;
    mapping (address => uint) private lastTransferTime;
    uint private constant transferLockTime = 1 days; // Período de bloqueo de transferencias (1 día en este ejemplo)
    
    constructor(address[] memory _approvers, uint _signatureThreshold) {
        require(_approvers.length > 0, "At least one approver is required.");
        require(_signatureThreshold > 0 && _signatureThreshold <= _approvers.length, "Invalid signature threshold.");
        
        owner = msg.sender;
        signatureThreshold = _signatureThreshold;
        
        for (uint i = 0; i < _approvers.length; i++) {
            approvers[_approvers[i]] = true;
        }
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }
    
    modifier onlyApprover() {
        require(approvers[msg.sender], "Only approved wallet can call this function.");
        _;
    }
    
    modifier transferAllowed() {
        require(lastTransferTime[msg.sender] + transferLockTime < block.timestamp, "Transfer not allowed yet.");
        _;
    }
    
    function transferEther(address payable _to, uint _amount) external onlyApprover transferAllowed {
        require(address(this).balance >= _amount, "Insufficient contract balance.");
        _to.transfer(_amount);
        lastTransferTime[msg.sender] = block.timestamp;
    }
    
    function transferERC20(address _tokenAddress, address _to, uint _amount) external onlyApprover transferAllowed {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient token balance.");
        token.transfer(_to, _amount);
        lastTransferTime[msg.sender] = block.timestamp;
    }
    
    function transferERC721(address _tokenAddress, address _to, uint256 _tokenId) external onlyApprover transferAllowed {
        IERC721 token = IERC721(_tokenAddress);
        require(token.ownerOf(_tokenId) == address(this), "Contract does not own the token.");
        token.transferFrom(address(this), _to, _tokenId);
        lastTransferTime[msg.sender] = block.timestamp;
    }
    
        function changeSignatureThreshold(uint _newThreshold) external onlyOwner {
        require(_newThreshold > 0 && _newThreshold <= countApprovers, "Invalid signature threshold.");
        signatureThreshold = _newThreshold;
    }
    
    function addApprover(address _approver) external onlyOwner {
        approvers[_approver] = true;
        countApprovers++;
    }
    
    function removeApprover(address _approver) external onlyOwner {
        require(countApprovers > signatureThreshold, "Cannot remove approver. Signature threshold will be violated.");
        require(_approver != owner, "Cannot remove contract owner.");
        approvers[_approver] = false;
        countApprovers--;
    }
}