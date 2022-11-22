// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice access control
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice libraries & utils
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice ERC1155, extensions & interfaces
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/**s
 * @title ERC1155 Token Contract for Github Achievements NFT Project
 **/

contract GANft is Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {
    /// @notice using strings for uints (token ID encoding)
    using Strings for uint256;

    /// @notice using Address for addresses extended functionality
    using Address for address;

    /// @notice the max supply for SFT and NFT, metadata file type
    string private constant METADATA_EXTENTION = ".json";

    /// @notice Mapping minted token Ids by address
    mapping(address => uint256[]) public achievements;

    mapping(address => uint256) public tickets;

    /// @notice Contract Token name and symbol
    string public name;
    string public symbol;

    /// @notice is soulbound token
    bool isSoulBound = true;

    address minter;

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
        address minter_,
        address[] memory payees_,
        uint256[] memory shares_
    ) ERC1155(uri_) PaymentSplitter(payees_, shares_) {
        name = name_;
        symbol = symbol_;
        minter = minter_;
    }

    /// @notice pauses the contract (minting and transfers)
    function pause() public virtual onlyOwner {
        _pause();
    }

    /// @notice unpauses the contract (minting and transfers)
    function unpause() public virtual onlyOwner {
        _unpause();
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
     **/
    function forge(
        uint256[] memory achievementIDs,
        uint256[] memory achievementAmount,
        bytes32 gitKeccak,
        address wallet,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public whenNotPaused {
        if (tickets[wallet] == 0) {
            tickets[wallet] = 2;
        }
        require(tickets[wallet] != 1, "GANft: No tickets available");
        require(wallet != address(0), "GANft: Address cannot be 0");
        require(
            wallet == msg.sender,
            "GANft: only owner of achievement can mint this token"
        );

        validatePermit(
            achievementIDs,
            achievementAmount,
            gitKeccak,
            wallet,
            r,
            s,
            v
        );

        for (uint256 i = 0; i < achievementIDs.length; i++) {
            uint256 achievementID = achievementIDs[i];
            uint256 amount = achievementAmount[i];
            mint(achievementID, amount, wallet);
        }
        achievements[wallet] = achievementAmount;
        tickets[wallet]--;
    }

    function validatePermit(
        uint256[] memory achievementIDs,
        uint256[] memory achievementAmount,
        bytes32 gitKeccak,
        address wallet,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal view {
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                gitKeccak,
                wallet,
                achievementIDs,
                achievementAmount
            )
        );
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 ethSigHash = keccak256(abi.encodePacked(prefix, permitHash));
        require(minter == ecrecover(ethSigHash, v, r, s), "invalid signature");
    }

    function mint(
        uint256 achievementID,
        uint256 amount,
        address wallet
    ) internal {
        if (amount > balanceOf(wallet, achievementID)) {
            _mint(
                wallet,
                achievementID,
                amount - balanceOf(wallet, achievementID),
                "0x00"
            );
            emit Minted(
                wallet,
                achievementID,
                amount - balanceOf(wallet, achievementID)
            );
        } else if (amount < balanceOf(wallet, achievementID)) {
            _burn(
                wallet,
                achievementID,
                balanceOf(wallet, achievementID) - amount
            );
        }
    }

    function buyTikects() public payable {
        uint256 amount_ = msg.value;
        require(
            amount_ >= 1e15,
            "GANft: Amount cannot be less than 0.0001 ETH"
        );
        tickets[msg.sender] = amount_ / 1e15;
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
        require(
            isSoulBound == false,
            "GANft: SouldBond Tokens are non transferrable"
        );
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
        require(
            isSoulBound == false,
            "GANft: SouldBond Tokens are non transferrable"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /// @notice before token transfer hook override
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Pausable, ERC1155Supply) {
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
