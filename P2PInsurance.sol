pragma solidity ^0.4.18;

contract V12Insurance {

  struct Insured {
    uint premiumValue;
    uint coverageValue;
    bool claimMade;
    uint mobileNumber;
    uint index;
  }
  
  mapping(address => Insured) private insureds;
  address[] public insuredAddress;

  event LogInsureUser   (address indexed userAddress, uint index, uint premiumValue, uint coverageValue, bool claimMade, uint mobileNumber);
  event LogUpdateInsureUser(address indexed userAddress, uint index, uint premiumValue, uint coverageValue, bool claimMade, uint mobileNumber);
  
  function isInsured(address userAddress)
    public 
    constant
    returns(bool isIndeed) 
  {
    if(insuredAddress.length == 0) return false;
    return (insuredAddress[insureds[userAddress].index] == userAddress);
  }

  function insureUser(uint mobileNumber, uint coverageValue) public payable  
    returns(uint index)
  {
    address userAddress;
    userAddress = msg.sender;
    uint premiumValue;
    premiumValue = msg.value;
    address insuranceCarrier;
    insuranceCarrier = 0xa1882ca5f3299215289e619746a08d9E1E231a4E;
    if(isInsured(userAddress)) revert(); 
    insureds[userAddress].mobileNumber = mobileNumber;
    insureds[userAddress].premiumValue   = premiumValue;
    insureds[userAddress].coverageValue = coverageValue*(10**18);
    insureds[userAddress].claimMade = false;
    insureds[userAddress].index     = insuredAddress.push(userAddress)-1;
    insuranceCarrier.transfer(premiumValue/20);
    emit LogInsureUser(
        userAddress, 
        insureds[userAddress].index, 
        premiumValue,
        coverageValue,
        false,
        mobileNumber);
    return insuredAddress.length-1;
  }

  function getUser(address userAddress)
    public 
    constant
    returns(uint mobileNumber, uint premiumValue, uint coverageValue,    
    bool claimMade, uint index)
  {
    if(!isInsured(userAddress)) revert(); 
    return(
      insureds[userAddress].mobileNumber, 
      insureds[userAddress].premiumValue, 
      insureds[userAddress].coverageValue,
      insureds[userAddress].claimMade,
      insureds[userAddress].index);
  } 
  
  function Claim (uint claimValue) 
    public
    returns(bool success) 
  {
    address userAddress;
    userAddress = msg.sender;
    uint maxClaim;
    uint reducedClaimValue;
    uint payoutValue;
    uint remainingCoverageValue;
    if(!isInsured(userAddress) || insureds[userAddress].coverageValue == 0) revert('User not insured or insurance cover exhausted'); 
    
    reducedClaimValue = claimValue*8*(10**18)/10;
    maxClaim = insureds[userAddress].coverageValue;
    if (reducedClaimValue <=maxClaim) { payoutValue = reducedClaimValue;}
    else {payoutValue = maxClaim;}
    userAddress.transfer(payoutValue);
    remainingCoverageValue = maxClaim-payoutValue;
    
    insureds[userAddress].coverageValue = remainingCoverageValue;
    insureds[userAddress].claimMade = true;
    emit LogUpdateInsureUser(
        userAddress, 
        insureds[userAddress].index, 
        insureds[userAddress].premiumValue,
        remainingCoverageValue,
        true,
        insureds[userAddress].mobileNumber);
    return true;
  }

  function getUserCount() 
    public
    constant
    returns(uint count)
  {
    return insuredAddress.length;
  }

  function getUserAtIndex(uint index)
    public
    constant
    returns(address userAddress)
  {
    return insuredAddress[index];
  }

}


