// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice access control
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice libraries & utils
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice ERC1155, extensions & interfaces
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

/**s
 * @title ERC1155 Token Contract for Github Achievements NFT Project
 * @notice This contract is meant to serve for both Semi- and Non- fungible tokens as part of the  Github Achievements NFT project
 * @author ghadimhawej.eth | bitspent.eth
 **/
contract GANft is
    Ownable,
    ERC1155Pausable,
    ERC1155Supply,
    ERC1155Burnable
{
    /// @notice using strings for uints (token ID encoding)
    using Strings for uint256;

    /// @notice using Address for addresses extended functionality
    using Address for address;

    /// @notice the max supply for SFT and NFT, metadata file type
    string private constant METADATA_EXTENTION = ".json";

     /// @notice The rate of minting per tokenId
    mapping(uint256 => uint256) public mintPrice;

    /// @notice Mapping minted token Ids by address
    mapping(address => mapping(uint256 => bool)) hasMintedToken;

    /// @notice Contract Token name and symbol
    string public name;
    string public symbol;

    /// @notice Max token Id that can be minted;
    uint8 public maxId;

    /// @notice is soulbound token
    bool isSoulBound = true;

    /// @notice Event triggered when minting occurs
    event Minted(
        address indexed account,
        uint256 indexed tokenId,
        uint256 indexed amount
    );

    /**
     * @notice constructor
     * @param name_ the token name
     * @param symbol_ the token symbol
     * @param uri_ token metadata URI
     **/
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint8 maxId_,
        uint256[] memory mintCostPerTokenId_
    ) ERC1155(uri_) {
        name = name_;
        symbol = symbol_;
        maxId = maxId_;
        _initialAddTokens(maxId_, mintCostPerTokenId_);
    }

    /// @notice pauses the contract (minting and transfers)
    function pause() public virtual onlyOwner {
        _pause();
    }

    /// @notice unpauses the contract (minting and transfers)
    function unpause() public virtual onlyOwner {
        _unpause();
    }

    /// @notice change max token Id
    function incrementMaxId(uint256 mintPrice_)
        public
        onlyOwner
    {
        maxId++;
        mintPrice[maxId] = mintPrice_;
    }

    /**
     * @notice changes the mint price of an already existing token ID
     * @param tokenId_ id of token
     * @param tokenId_ new mint price of specified token ID
     **/
    function changeMintPriceOfTokenId(uint256 tokenId_, uint256 newMintPrice)
        public
        onlyOwner
    {
        require(
            newMintPrice != mintPrice[tokenId_],
            "GANft: Mint Price should be different than the previous price"
        );
        mintPrice[tokenId_] = newMintPrice;
    }

    /**
     * @notice sets the base URI for token types
     * @param _uri token metadata URI
     **/
    function setURI(string memory _uri) external onlyOwner {
        require(
            keccak256(abi.encodePacked(super.uri(0))) !=
                keccak256(abi.encodePacked(_uri)),
            "GANft: INVALID_URI"
        );
        _setURI(_uri);
    }

    /**
     * @notice gets the URI per token ID
     * @param tokenId token type ID to return proper URI
     **/
    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(exists(tokenId), "GANft: NONEXISTENT_TOKEN");
        return
            string(
                abi.encodePacked(
                    super.uri(0),
                    tokenId.toString(),
                    METADATA_EXTENTION
                )
            );
    }

    /**
     * @notice mints tokens based on parameters
     * @param to_ address of the user minting
     * @param tokenId_ id of token to be minted
     **/
    function mint(
        address to_,
        uint256 tokenId_
    ) public payable whenNotPaused {
        uint256 received = msg.value;
        uint8 amount_ = 1;
        require(to_ != address(0), "GANft: Address cannot be 0");
        require(to_ == msg.sender, "GANft: only owner of achievement can mint this token");
        require(
            received == mintPrice[tokenId_],
            "GANft: Ether sent is not the right amount"
        );
        require(tokenId_ <= maxId, "GANft: Token id doesn't exist");

        require(!hasMintedToken[to_][tokenId_], "GANft: Token has already been minted");

        _mint(to_, tokenId_, amount_, "0x00");
        hasMintedToken[to_][tokenId_] = true;
        emit Minted(to_, tokenId_, amount_);
    }

       /**
     * @notice mints tokens based on parameters
     * @param to_ address of the user minting
     * @param tokenIds_ ids of tokens to be minted
     **/
    function mintBatch(
        address to_,
        uint256[] memory tokenIds_
    ) public payable whenNotPaused {
        uint256 received = msg.value;
         uint8 amount_ = 1;

         require(to_ != address(0), "GANft: Address cannot be 0");
        require(to_ == msg.sender, "GANft: only owner of achievement can mint this token");
        
         for (uint256 i = 0; i < tokenIds_.length; i++) {
             require(
            received == mintPrice[tokenIds_[i]],
            "GANft: Ether sent is not the right amount"
        );
             require(tokenIds_[i] <= maxId, "GANft: Token id doesn't exist");
             require(!hasMintedToken[to_][tokenIds_[i]], "GANft: Token has already been minted");

             _mint(to_, tokenIds_[i], amount_, "0x00");
             hasMintedToken[to_][tokenIds_[i]] = true;
              emit Minted(to_, tokenIds_[i], amount_);
        }

    }



    /**
     * @notice checks if an address minted the token
     * @param minter address user minting nft
     * @param tokenId_ token to check for
     **/
    function checkIfMinted(address minter, uint256 tokenId_)
        public
        view
        returns (bool)
    {
        return  hasMintedToken[minter][tokenId_];
    }

      /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
         require(isSoulBound == false, "GANft: SouldBond Tokens are non transferrable");
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        require(isSoulBound == false, "GANft: SouldBond Tokens are non transferrable");
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }


    /**
     * @notice add initial token ids with their respective supplies
     * @param maxId_ list of token ids to be added
     * @param mintCostPerTokenId_ mint price per token Id
     **/
    function _initialAddTokens(
        uint8 maxId_,
        uint256[] memory mintCostPerTokenId_
    ) private {
        require(
            maxId_ + 1 == mintCostPerTokenId_.length,
            "GANft: IDs/MintCost arity mismatch"
        );

        for (uint256 i = 0; i < maxId_ + 1; i++) {
            mintPrice[i] = mintCostPerTokenId_[i];
        }
    }

    /// @notice before token transfer hook override
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Pausable, ERC1155Supply, ERC1155) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /// @notice EIP165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
