pragma solidity ^0.4.18;

import "./KycUtils.sol";

contract QuestionContract {

    struct QuestionStruct {
        address asker;
        address target;
        bytes32[] comments;
        uint token;
    }
    
    mapping(bytes32 => QuestionStruct) internal questions;
    
    function createQuestion(address target, bytes32 bzId) internal returns(bytes32) {
        require(target != msg.sender);
        // get uid for this question
        bytes32 questionUid = KycUtils.getUid(bzId);
        questions[questionUid].asker = msg.sender;
        questions[questionUid].target = target;
        questions[questionUid].token=msg.value;
        return questionUid;
    }
    
    //Add new comment to this question
    function addCommentToQuestion(bytes32 commentUid, bytes32 questionUid) internal {
        QuestionStruct storage question = questions[questionUid];
        question.comments.push(commentUid);
    }

    //Get information of this question
    function getQuestionInfo(bytes32 qusetionUid) public constant 
    returns (address asker, address target, bytes32[] comments){
        QuestionStruct storage question = questions[qusetionUid];
        asker = question.asker;
        target = question.target;
        comments = question.comments;
    }
}
