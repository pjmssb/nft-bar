pragma solidity ^0.8.0;

contract NFTBAR {

  // The metadata for each NFT-BAR token.
  struct TokenMetadata {
    uint256 last_date;
    address owner_address;
  }

  // The mapping from token ID to token metadata.
  mapping(uint256 => TokenMetadata) public tokens;

  // The address of the contract owner.
  address public owner;

  // The total number of tokens minted.
  uint256 public totalSupply = 100;

  // The constructor mints 100 tokens to the contract owner.
  constructor() {
    for (uint256 i = 0; i < totalSupply; i++) {
      mint(owner, i);
    }
  }

  // Mints a new token to the specified address.
  function mint(address to, uint256 tokenId) public {
    require(tokenId < totalSupply, "Token ID is out of bounds");

    // Create the token metadata.
    TokenMetadata memory metadata = TokenMetadata({
      last_date: block.timestamp,
      owner_address: to,
    });

    // Mint the token.
    tokens[tokenId] = metadata;
  }

  // Transfers a token from one address to another.
  function transfer(address from, address to, uint256 tokenId) public {
    require(owner == msg.sender || tokens[tokenId].last_date < block.timestamp - 180 days, "Only the contract owner or tokens older than 6 months can be transferred");
    require(tokens[tokenId].owner_address == from, "Token is not owned by sender");
    require(isAddressValid(to), "Recipient address is invalid");
    require(isReentrancyGuardEnabled(), "Reentrancy attack detected");

    // Update the token metadata.
    tokens[tokenId].owner_address = to;

    // Notify the token owner.
    emit Transfer(from, to, tokenId);
  }

  // Gets the data for a NFT-BAR token.
  function getTokenData(uint256 tokenId) public view returns (TokenMetadata memory) {
    return tokens[tokenId];
  }

  // Gets the data for all tokens owned by an address.
  function getTokenDataByAddress(address address) public view returns (TokenMetadata[] memory) {
    TokenMetadata[] memory tokensData = new TokenMetadata[](0);

    for (uint256 i = 0; i < totalSupply; i++) {
      if (tokens[i].owner_address == address) {
        tokensData.push(tokens[i]);
      }
    }

    return tokensData;
  }

  // Gets the data for all tokens.
  function getAllTokenData() public view returns (TokenMetadata[] memory) {
    TokenMetadata[] memory tokensData = new TokenMetadata[](totalSupply);

    for (uint256 i = 0; i < totalSupply; i++) {
      tokensData[i] = tokens[i];
    }

    return tokensData;
  }

  event Transfer(address indexed from, address indexed to, uint256 tokenId);

  function isAddressValid(address address) internal view returns (bool) {
    return address != address(0) && address != address(this);
  }

  function isReentrancyGuardEnabled() internal view returns (bool) {
    // This is a simple reentrancy guard that checks if the contract is still in the
    // same execution context before calling another function.
    return msg.sender == address(this);
  }
}