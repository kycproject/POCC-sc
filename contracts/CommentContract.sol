pragma solidity ^0.4.18;

import "./KycUtils.sol";

contract CommentContract{
    
    struct  CommentStruct{
        address commentator;
        bytes32 question;
        address[] approvers; 
        address[] disapprovers;
        address[] watchings;
    }
    
    mapping(bytes32 => CommentStruct) internal comments;
    
    //Create new Comment
    function createComment(bytes32 questionUid, bytes32 bzId) internal returns(bytes32) {
        // get uid for this comments
        bytes32 commentUid = KycUtils.getUid(bzId);
        comments[commentUid].commentator = msg.sender;
        comments[commentUid].question = questionUid;
        return commentUid;
    }
    
    //Approve of one comment
    function approve(bytes32 commentUid) public {
        CommentStruct storage comment = comments[commentUid];
        comment.approvers.push(msg.sender);
    }
    //Disapprove of one comment
    function disapprove(bytes32 commentUid) public {
        CommentStruct storage comment = comments[commentUid];
        comment.disapprovers.push(msg.sender);
    }

    //Add one user to watchings list
    function addWatchToComment(bytes32 commentUid) internal {
        CommentStruct storage comment = comments[commentUid];
        comment.watchings.push(msg.sender);
    }
    
}
