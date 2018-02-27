pragma solidity ^0.4.18;

contract UserContract {

    struct UserStruct {
        uint score;
        address[] friends;
        bytes32[] askQuestions;
        bytes32[] relateQuestions;
        bytes32[] comments;
        bytes32[] commentWatchings;
        address introducer;
    }
    
    uint8 defaultScore;
    uint8 tokenDay = 1;
    
    mapping(address => UserStruct) internal users;
    event GetFriendRelateQuestions(address userAddress, bytes32[] questions);
    
    function addUserAskQuestions(address userAddress, bytes32 questionUid) internal {
        UserStruct storage user = users[userAddress];
        user.askQuestions.push(questionUid);
    }
    
    function addUserRelateQuestions(address userAddress, bytes32 questionUid) internal {
        UserStruct storage user = users[userAddress];
        user.relateQuestions.push(questionUid);
    }
    
    function addUserComments(address userAddress, bytes32 commentUid) internal {
        UserStruct storage user = users[userAddress];
        user.comments.push(commentUid);
    }
    
    function getScore() public constant returns(uint score) {
        UserStruct storage user = users[msg.sender];
        uint userScore = user.score;
        if (userScore <= 0) {
            userScore = defaultScore;
        }
        //count friends with score
        uint friendScore = 0;
        uint friendCount = 0;
        for (uint i=0;i<user.friends.length;i++) {
            if (users[user.friends[i]].score>0) {
                friendScore += users[user.friends[i]].score;
                friendCount ++;
            }
        }
        if (friendCount > 0) {
            score = (userScore*7+(friendScore/friendCount)*3)/10;
        } else {
            score = userScore;
        }
        //The highest score can't exceed 99 points
        if (score > 99) {
            score = 99;
        }
    }
    
    function getFriends() internal constant returns(address[]) {
        UserStruct storage user = users[msg.sender];
        return user.friends;
    }
    
    function getAskQuestions() internal constant returns(bytes32[]) {
        UserStruct storage user = users[msg.sender];
        return user.askQuestions;
    }
    
    function relateFriend(address friendAddress) public {
        require(msg.sender != friendAddress);
        UserStruct storage user = users[msg.sender];
        bool existFlag = false; 
        for (uint i=0;i<user.friends.length;i++) {
            if (user.friends[i]==friendAddress) {
                existFlag = true;
            }
        }
        if (!existFlag) {
            user.friends.push(friendAddress);
            UserStruct storage friend = users[friendAddress];
            friend.friends.push(msg.sender);
        } else {
            //An existing relationship of friends
        }
    }
    
    function getFriendRelateQuestions() public returns(bytes32[]) {
        bytes32[] storage questions;
        UserStruct storage user = users[msg.sender];
        for (uint i=0;i<user.friends.length;i++) {
            address friendAddr = user.friends[i];
            UserStruct storage friend = users[friendAddr];
            bytes32[] memory friendQues = friend.askQuestions;
            for (uint j=0;j<friendQues.length;j++) {
                questions.push(friendQues[j]);
            }
        }
        GetFriendRelateQuestions(msg.sender, questions);
        return questions;
    }
    
    function addWatchToUser(bytes32 commentUid) internal {
        UserStruct storage user = users[msg.sender];
        user.commentWatchings.push(commentUid);
    }
    
}
