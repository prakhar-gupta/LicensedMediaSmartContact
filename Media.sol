pragma solidity ^0.4.21;

contract Media {

  struct media {
    address creator;
    uint mediaId;
    uint priceIndividual;
    uint priceCompany;
    // TODO: Add stakeholders
    // TODO: Add other things
  }
  
  media[] private mediaList;
  mapping (address => media[]) private owns;
  mapping (address => bool) private isCompany;
  mapping (address => bool) private isCreator;

  function Media() public {
  }

  function isNewUser(address user) view private returns (bool) {
    return (isCreator[user].length ==  0);
  }

  function hasSeenMedia(address user, media testMedia) view private returns (bool) {
    media[] userOwned = owns[user];
    for(uint i = 0; i < userOwned.length; i++) {
      if (userOwned[i] == testMedia) {
        return true;
      }
    }
    return false;
  }

  function availableMedia() view public returns (media[]) {
    address user = msg.sender;
    if (isNewUser(user)) {
      isCreator[user] = false;
      // TODO: generate random no.
      isCompany[user] = false;
    }
    require(isCreator[user]);
    media[] retMedia;
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
    media newEntry = media({
      creator: user,
      mediaId: newMediaId,
      priceIndividual: newPriceIndividual,
      priceCompany; newPriceCompany
    });
    mediaList.push(newEntry);
  }
}
