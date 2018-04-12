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
  
  enum State { Requested, Confirmed, Sent, Inactive }

  uint[] private mediaList;
  mapping (uint => Media) private mediaIdMap;
  mapping (address => uint[]) private owns;
  mapping (address => mapping (uint => string)) public encryptedMediaMap;
  mapping (address => bool) private isNewUser;
  mapping (address => bool) private isCompany;
  mapping (address => bool) private isCreator;
  mapping (address => mapping (uint => State)) private txnState;
  
  event InitBuy(address buyer, uint media);
  event AbortBuy(address buyer, uint media);
  event ConfirmBuy(address buyer, uint media);
  event MediaSent(address buyer, uint media);
  event MediaReceived(address buyer, uint media);

  function MediaContract() public {
  }

  function hasSeenMedia(address user, uint testMediaId) view private returns (bool) {
    require(mediaIdMap[testMediaId].mediaId > 0);
    for(uint i = 0; i < owns[user].length; i++) {
      if (owns[user][i] == testMediaId) {
        return true;
      }
    }
    return false;
  }

  function availableMedia() view public returns (uint[]) {
    address user = msg.sender;
    if (isNewUser[user]) {
      isCreator[user] = false;
      // TODO: generate random no.
      isCompany[user] = false;
      isNewUser[user] = false;
    }
    require(!isCreator[user]);
    uint[] retMedia;
    for(uint i = 0; i < mediaList.length; i++) {
      if (!hasSeenMedia(user, mediaList[i])) {
        retMedia.push(mediaList[i]);
      }
    }
    return retMedia;
  }

  function addMedia(uint newMediaId, uint newPriceIndividual, uint newPriceCompany) public {
    require(newMediaId > 0);
    require(mediaIdMap[newMediaId].mediaId == 0);
    address user = msg.sender;
    if (isNewUser[user]) {
      isCreator[user] = true;
      isNewUser[user] = false;
    }
    require(isCreator[user]);
    mediaIdMap[newMediaId] = Media({
      creator: user,
      mediaId: newMediaId,
      priceIndividual: newPriceIndividual,
      priceCompany: newPriceCompany
    });
    mediaList.push(newMediaId);
  }

  function initBuy(uint mediaId) public { // TODO: add public key here
    require(mediaIdMap[mediaId].mediaId > 0);
    require(msg.value == 2 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    address buyer = msg.sender;
    txnState[buyer][mediaId] = State.Requested;
    emit InitBuy(buyer, mediaId);
  }

  function confirmBuy(uint mediaId, address buyer) public {
    require(mediaIdMap[mediaId].mediaId > 0);
    require(txnState[buyer][mediaId] == State.Requested);
    require(msg.sender == mediaIdMap[mediaId].creator);
    require(msg.value == 2 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    txnState[buyer][mediaId] = State.Confirmed;
    emit ConfirmBuy(buyer, mediaId);
  }

  function abortBuy(uint mediaId) public {
    require(mediaIdMap[mediaId].mediaId > 0);
    address buyer = msg.sender;
    require(txnState[buyer][mediaId] == State.Requested);
    txnState[buyer][mediaId] = State.Inactive;
    buyer.transfer(2 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    emit AbortBuy(buyer, mediaId);
  }

  function sendEncryptedMedia(uint mediaId, address buyer, string encryptedMedia) public {
    require(mediaIdMap[mediaId].mediaId > 0);
    require(msg.sender == mediaIdMap[mediaId].creator);
    require(txnState[buyer][mediaId] == State.Confirmed || txnState[buyer][mediaId] == State.Sent);
    txnState[buyer][mediaId] = State.Sent;
    encryptedMediaMap[buyer][mediaId] = encryptedMedia;
    emit MediaSent(buyer, mediaId);
  }

  function ConfirmReceipt(uint mediaId) public {
    require(mediaIdMap[mediaId].mediaId > 0);
    address buyer = msg.sender;
    address seller = mediaIdMap[mediaId].creator;
    require(txnState[buyer][mediaId] == State.Sent);
    txnState[buyer][mediaId] = State.Inactive;
    buyer.transfer(mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    // TODO: give to stakeholders
    seller.transfer(3 * mediaIdMap[mediaId].priceIndividual); // FIXME: priceCompany
    owns[buyer].push(mediaId);
    emit MediaReceived(buyer, mediaId);
  }
}
