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
  
  enum State { Created, Locked, Inactive }

  Media[] private mediaList;
  mapping (uint => bool) private mediaExists;
  mapping (address => Media[]) private owns;
  mapping (address => bool) private isCompany;
  mapping (address => bool) private isCreator;
  mapping (address => mapping (mediaId => State)) private txnState;
  
  event InitBuy(address buyer, Media media);

  function MediaContract() public {
  }

  function isNewUser(address user) view private returns (bool) {
    return (isCreator[user].length ==  0);
  }

  function hasSeenMedia(address user, Media testMedia) view private returns (bool) {
    require(mediaExists(testMedia).length == 1);
    Media[] userOwned = owns[user];
    for(uint i = 0; i < userOwned.length; i++) {
      if (userOwned[i] == testMedia) {
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
    require(!isCreator[user]);
    Media newEntry = Media({
      creator: user,
      mediaId: newMediaId,
      priceIndividual: newPriceIndividual,
      priceCompany; newPriceCompany
    });
    mediaList.push(newEntry);
    mediaExists[newEntry] = 1;
  }

  function initiateBuy(Media media) public {
    address user = msg.sender;
    txnState[user][media.mediaId] = State.Created;
    // TODO: lockin amount
    emit InitBuy(user, media);
  }
}
