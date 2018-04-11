pragma solidity ^0.4.21;

contract MediaContract {

  struct Media {
    address creator;
    uint mediaId;
    uint priceIndividual;
    uint priceCompany;
    // TODO: Add stakeholders
    // TODO: Add other things
  }
  
  enum State { Requested, Confirmed, Inactive }

  Media[] private mediaList;
  mapping (uint => Media) private mediaIdMap;
  mapping (address => uint[]) private owns;
  mapping (address => (uint => string)) public encryptedMediaMap;
  mapping (address => bool) private isCompany;
  mapping (address => bool) private isCreator;
  mapping (address => mapping (mediaId => State)) private txnState;
  
  event InitBuy(address buyer, uint media);
  event AbortBuy(address buyer, uint media);
  event ConfirmBuy(address buyer, uint media);
  event MediaSent(address buyer, uint media);
  event MediaReceived(address buyer, uint media);

  function MediaContract() public {
  }

  function isNewUser(address user) view private returns (bool) {
    return (isCreator[user].length ==  0);
  }

  function hasSeenMedia(address user, uint testMediaId) view private returns (bool) {
    require(mediaIdMap[testMediaId].length == 1);
    uint[] userOwned = owns[user];
    for(uint i = 0; i < userOwned.length; i++) {
      if (userOwned[i] == testMediaId) {
        return true;
      }
    }
    return false;
  }

  function availableMedia() view public returns (Media[]) {
    address user = msg.sender;
    if (isNewUser(user)) {
      isCreator[user] = false;
      // TODO: generate random no.
      isCompany[user] = false;
    }
    require(isCreator[user]);
    Media[] retMedia;
    for(uint i = 0; i < mediaList.length; i++) {
      if (!hasSeenMedia(user, mediaList[i])) {
        retMedia.push(mediaList[i]);
      }
    }
    return retMedia;
  }

  function addMedia(uint newMediaId, uint newPriceIndividual, uint newPriceCompany) public {
    address user = msg.sender;
    if (isNewUser(user)) {
      isCreator[user] = true;
    }
    require(isCreator[user]);
    Media newEntry = Media({
      creator: user,
      mediaId: newMediaId,
      priceIndividual: newPriceIndividual,
      priceCompany; newPriceCompany
    });
    mediaList.push(newEntry);
    mediaIdMap[newMediaId] = newEntry;
  }

  function initBuy(uint mediaId) public { // TODO: add public key here
    require(mediaIdMap[mediaId].length == 1);
    require(msg.value == 2 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    address buyer = msg.sender;
    txnState[buyer][mediaId] = State.Requested;
    emit InitBuy(buyer, mediaId);
  }

  function confirmBuy(uint mediaId, address buyer) public {
    require(mediaIdMap[mediaId].length == 1);
    require(txnState[buyer][media.mediaId] = State.Requested);
    require(msg.sender == mediaIdMap[mediaId].creator);
    require(msg.value == 2 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    txnState[buyer][mediaId] = State.Confirmed;
    emit ConfirmBuy(buyer, mediaId);
  }

  function abortBuy(uint mediaId) public {
    require(mediaIdMap[mediaId].length == 1);
    address buyer = msg.sender;
    require(txnState[buyer][mediaId] == State.Requested);
    txnState[buyer][mediaId] = State.Inactive;
    buyer.transfer(2 * mediaIdMap[media].priceIndividual); // FIXME: priceCompany
    emit AbortBuy(buyer, mediaId);
  }

  function sendEncryptedMedia(uint mediaId, address buyer, string encryptedMedia) public {
    require(mediaIdMap[mediaId].length == 1);
    require(msg.sender == mediaIdMap[mediaId].creator);
    require(txnState[buyer][media.mediaId] == State.Confirmed || txnState[buyer][media.mediaId] == State.Sent);
    txnState[buyer][mediaId] = State.Sent;
    encryptedMediaMap[buyer][mediaId] = encryptedMedia;
    emit MediaSent(buyer, mediaId);
  }

  function ConfirmReceipt(uint mediaId) public {
    require(mediaIdMap[mediaId].length == 1);
    address buyer = msg.sender;
    address seller == mediaIdMap[mediaId].creator;
    require(txnState[buyer][mediaId] == State.Sent);
    txnState[buyer][mediaId] = State.Inactive;
    buyer.transfer(mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    seller.transfer(3 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    owns[buyer].push(mediaId);
    emit MediaReceived(buyer, mediaId);
  }
}
