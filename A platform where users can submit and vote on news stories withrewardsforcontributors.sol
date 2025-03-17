// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DecentralizedNewsPlatform {
    struct NewsStory {
        string title;
        string content;
        address author;
        uint256 votes;
        uint256 timestamp;
    }

    struct Comment {
        address commenter;
        string text;
        uint256 timestamp;
    }

    mapping(uint256 => Comment[]) public comments;
    mapping(address => uint256) public reputation;
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    NewsStory[] public newsStories;
    uint256 public constant REWARD_AMOUNT = 10;
    uint256 public constant REPUTATION_INCREMENT = 5;

    event NewsSubmitted(uint256 indexed newsId, address indexed author, string title);
    event Voted(uint256 indexed newsId, address indexed voter);
    event CommentAdded(uint256 indexed newsId, address indexed commenter, string text);
    event ContentFlagged(uint256 indexed newsId, address indexed reporter);
    event RewardIssued(address indexed recipient, uint256 amount);

    function submitNews(string memory _title, string memory _content) public {
        newsStories.push(NewsStory({
            title: _title,
            content: _content,
            author: msg.sender,
            votes: 0,
            timestamp: block.timestamp
        }));
        emit NewsSubmitted(newsStories.length - 1, msg.sender, _title);
    }

    function voteNews(uint256 _newsId) public {
        require(_newsId < newsStories.length, "Invalid news ID");
        require(!hasVoted[_newsId][msg.sender], "You have already voted");
        
        newsStories[_newsId].votes++;
        hasVoted[_newsId][msg.sender] = true;
        reputation[newsStories[_newsId].author] += REPUTATION_INCREMENT;
        balances[newsStories[_newsId].author] += REWARD_AMOUNT;

        emit Voted(_newsId, msg.sender);
        emit RewardIssued(newsStories[_newsId].author, REWARD_AMOUNT);
    }

    function addComment(uint256 _newsId, string memory _text) public {
        require(_newsId < newsStories.length, "Invalid news ID");
        comments[_newsId].push(Comment({
            commenter: msg.sender,
            text: _text,
            timestamp: block.timestamp
        }));
        emit CommentAdded(_newsId, msg.sender, _text);
    }

    function flagContent(uint256 _newsId) public {
        require(_newsId < newsStories.length, "Invalid news ID");
        require(reputation[msg.sender] > 50, "Insufficient reputation to flag content");
        emit ContentFlagged(_newsId, msg.sender);
    }

    function getNews(uint256 _newsId) public view returns (string memory, string memory, address, uint256, uint256) {
        require(_newsId < newsStories.length, "Invalid news ID");
        NewsStory memory story = newsStories[_newsId];
        return (story.title, story.content, story.author, story.votes, story.timestamp);
    }
}



