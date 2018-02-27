pragma solidity ^0.4.18;

import "./KycUtils.sol";

contract CommentContract{
    
    struct WatchingStruct {
        address watching;
        uint token;
        uint8 currentStatus; // The status of watching; 1 init ; 2 approve; 3 disapprove
    }
    
    struct CommentStruct {
        address commentator;
        bytes32 questionUid;
        uint score;
        mapping(address => WatchingStruct) watchings;
    }
    
    mapping(bytes32 => CommentStruct) internal comments;
    
    //Create new Comment
    function createComment(bytes32 questionUid, bytes32 bzId) internal returns(bytes32) {
        // get uid for this comments
        bytes32 commentUid = KycUtils.getUid(bzId);
        comments[commentUid].commentator = msg.sender;
        comments[commentUid].questionUid = questionUid;
        return commentUid;
    }
    
    
    //Add one user to watchings list
    function addWatchToComment(bytes32 commentUid) internal {
        CommentStruct storage comment = comments[commentUid];
        comment.watchings[msg.sender].watching = msg.sender;
        comment.watchings[msg.sender].token = msg.value;
        comment.watchings[msg.sender].currentStatus = 1;
    }
    
}
