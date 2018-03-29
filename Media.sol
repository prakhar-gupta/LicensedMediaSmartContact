pragma solidity ^0.4.21;

contract Media {

  struct media {
    bytes32 creator;
    bytes32 mediaId;
    uint priceIndividual;
    uint priceCompany;
    // TODO
  }
  
  media[] private mediaList;
  mapping (bytes32 => media[]) private owns;
  mapping (bytes32 => bool) private isCompany;
  mapping (bytes32 => bool) private isCreator;
  bytes32[] public userList;

  function Media(bytes32[] users) public {
    userList = users;
  }

  function hasSeenMedia(bytes32 user, media testMedia) view private returns (bool) {
    media[] userOwned = owns[user];
    for(uint i = 0; i < userOwned.length; i++) {
      if (userOwned[i] == testMedia) {
        return true;
      }
    }
    return false;
  }

  function availableMedia(bytes32 user) view public returns (media[]) {
    require(validCandidate(user));
    media[] retMedia;
    for(uint i = 0; i < mediaList.length; i++) {
      if (!hasSeenMedia(user, mediaList[i])) {
        retMedia.push(mediaList[i]);
      }
    }
    return retMedia;
  }

  function validUser(bytes32 user) view private returns (bool) {
    for(uint i = 0; i < userList.length; i++) {
      if (userList[i] == user) {
        return true;
      }
    }
    return false;
   }
}
