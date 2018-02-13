pragma solidity ^0.4.18;


import "./UserContract.sol";
import "./QuestionContract.sol";
import "./CommentContract.sol";

contract TemplateContract is UserContract, QuestionContract, CommentContract {
    
    address owner;
    uint minTokenForAddQuestion;
    uint minTokenForWatchComment;
    event AddQuestionEvent(address from, address target, bytes32 questionUid);
    event AddCommentEvent(address from, bytes32 questionUid, bytes32 commentUid);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function TemplateContract() public {
        owner = msg.sender;
        defaultScore = 60;
        minTokenForAddQuestion = 0;
        minTokenForWatchComment = 0;
    }
    
    function setDefaultScore(uint8 score) onlyOwner public {
        defaultScore = score;
    }
    
    function setMinTokenForAddQuestion(uint minToken) onlyOwner public {
        minTokenForAddQuestion = minToken;
    }
    
    function addQuestion(address target, bytes32 bzId) public returns(bytes32) {
        require(target != msg.sender);
        //require(msg.value>=minTokenForAddQuestion);
        // get uid for this question
        bytes32 questionUid = createQuestion(target, bzId);
        // Add questionUid to asker's struct
        addUserAskQuestions(msg.sender, questionUid);
        // Add questionUid to target's struct
        addUserRelateQuestions(target, questionUid);
        AddQuestionEvent(msg.sender, target, questionUid);
        return questionUid;
    }

    function addComment(bytes32 questionUid, bytes32 bzId) public returns(bytes32) {
        // get uid for this comment
        bytes32 commentUid = addComment(questionUid, bzId);
        // add commentUid to question's struct
        addCommentToQuestion(commentUid, questionUid);
        
        QuestionStruct storage question = questions[questionUid];
        UserStruct storage user = users[msg.sender];
        // get Token: BT × 50% x UR x 1%
        uint getToken = question.token*user.score*5/1000;
        question.token = question.token - getToken;
        msg.sender.transfer(getToken);
        
        AddCommentEvent(msg.sender, questionUid, commentUid);
        return commentUid;
    }
    
    function watch(bytes32 commentUid) public {
        //require(msg.value>=minTokenForWatchComment);
        addWatchToComment(commentUid);
        addWatchToUser(commentUid);
    }
    
}
