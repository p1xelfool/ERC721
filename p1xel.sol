// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Context.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - Ownership which restricts token minting permissions (to the contract creator)
 *  - token ID and URI autogeneration
 *
 *
 * The account that deploys the contract will be granted ownership, via Ownable.sol
 */
contract Test10 is
    Context,
    Ownable,
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721URIStorage
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;
    string private _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;

    /**
     * MATH NOTE: Based on Ownable, modified from OZ's more complex permissions system
     * 
     * @dev Grants ownership, via Ownable.sol to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    // MATH NOTE: Consider removing this view function entirely. Do we really need a Base URI?
    //   (I suppose we can technically save 7 bytes per mint by using "ipfs://" as the base URI...)
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must be the contract Owner.
     */
    function mint(address to) public virtual onlyOwner {

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }
    
    
    
    
    
    

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId), "Test10: URI query for nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "Test10: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        // If there is no base URI
        if (bytes(base).length == 0) {
            // If there is no token URI, return a "-1" string
            if (bytes(_tokenURI).length == 0) {
                return "-1";
            }
            // Otherwise, return the token URI
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the "-1" string to the baseURI.
        return string(abi.encodePacked(base, "-1"));
    }
    
    
    /**
     * MATH NOTE: Taken from OZ/contracts/token/ERC721/extensions/ERC721URIStorage.sol
     * 
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    
    
    
    

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}