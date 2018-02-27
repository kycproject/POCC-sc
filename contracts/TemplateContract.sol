pragma solidity ^0.4.18;


import "./UserContract.sol";
import "./QuestionContract.sol";
import "./CommentContract.sol";

contract TemplateContract is UserContract, QuestionContract, CommentContract {
    
    address owner;
    uint minTokenForAddQuestion;
    uint minTokenForWatchComment;
    event AddQuestion(address from, address target, bytes32 questionUid);
    event AddComment(address from, bytes32 questionUid, bytes32 commentUid);
    
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
    
    function addQuestion(address target, bytes32 bzId) public payable returns(bytes32) {
        require(target != msg.sender);
        require(msg.value>=minTokenForAddQuestion);
        // get uid for this question
        bytes32 questionUid = createQuestion(target, bzId);
        // Add questionUid to asker's struct
        addUserAskQuestions(msg.sender, questionUid);
        // Add questionUid to target's struct
        addUserRelateQuestions(target, questionUid);
        AddQuestion(msg.sender, target, questionUid);
        return questionUid;
    }

    function addComment(bytes32 questionUid, bytes32 bzId) public returns(bytes32) {
        // get uid for this comment
        bytes32 commentUid = createComment(questionUid, bzId);
        CommentStruct storage comment = comments[commentUid];
        
        // add commentUid to question's struct
        addCommentToQuestion(commentUid, questionUid);
        
        QuestionStruct storage question = questions[questionUid];
        UserStruct storage user = users[msg.sender];
        comment.score = user.score;
        // get Token: BT × 50% x UR x 1%
        uint getToken = question.token*user.score*5/1000;
        question.token = question.token - getToken;
        msg.sender.transfer(getToken);
        
        AddComment(msg.sender, questionUid, commentUid);
        return commentUid;
    }
    
    function watch(bytes32 commentUid) payable public {
        require(msg.value>=minTokenForWatchComment);
        addWatchToComment(commentUid);
        addWatchToUser(commentUid);
    }
    
    //Approve of one comment
    function approve(bytes32 commentUid) public {
        CommentStruct storage comment = comments[commentUid];
        WatchingStruct storage watching = comment.watchings[msg.sender];
        require(watching.currentStatus == 1);
        watching.currentStatus = 2;
        QuestionStruct storage question = questions[comment.questionUid];
        //affect the score of comment
        UserStruct storage approveUser = users[msg.sender];
        uint commentScore = comment.score + (100-comment.score)*approveUser.score/200;
        if (commentScore>99) {
            commentScore = 99;
        }
        comment.score = commentScore;
        //affect the score of comment user
        UserStruct storage commentUser = users[comment.commentator];
        uint commentCount = commentUser.comments.length;
        uint commentUserScore = (commentUser.score*commentCount + commentScore)/(commentCount+1);
        if (commentUserScore > 99) {
            commentUserScore = 99;
        } else if (commentUserScore < 1) {
            commentUserScore = 1;
        }
        commentUser.score = commentUserScore;
        
        //45% to asker
        uint askerToken = watching.token*45/100;
        question.asker.transfer(askerToken);
        //45% to commentator
        uint commentatorToken = watching.token*45/100;
        comment.commentator.transfer(commentatorToken);
        //10% to target
        uint targetToken = watching.token - askerToken - commentatorToken;
        question.target.transfer(targetToken);
    }
    
    //Disapprove of one comment
    function disapprove(bytes32 commentUid) public {
        CommentStruct storage comment = comments[commentUid];
        WatchingStruct storage watching = comment.watchings[msg.sender];
        require(watching.currentStatus == 1);
        watching.currentStatus = 3;
        QuestionStruct storage question = questions[comment.questionUid];
        //affect the score of comment
        UserStruct storage approveUser = users[msg.sender];
        uint commentScore = comment.score - approveUser.score/2;
        if (commentScore<1) {
            commentScore = 1;
        }
        comment.score = commentScore;
        //affect the score of comment user
        UserStruct storage commentUser = users[comment.commentator];
        uint commentCount = commentUser.comments.length;
        uint commentUserScore = (commentUser.score*commentCount + commentScore)/(commentCount+1);
        if (commentUserScore > 99) {
            commentUserScore = 99;
        } else if (commentUserScore < 1) {
            commentUserScore = 1;
        }
        commentUser.score = commentUserScore;
        
        //10% to asker
        uint askerToken = watching.token*10/100;
        question.asker.transfer(askerToken);
        //10% to commentator
        uint commentatorToken = watching.token*10/100;
        comment.commentator.transfer(commentatorToken);
        //80% to system
    }
}
