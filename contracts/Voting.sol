//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Voting {
  address owner;
  constructor() {
    owner = msg.sender;
  }

  struct Candidate {
    string name;
    uint totalVotes;
    address wallet;
  }

  struct Voter {
    bool voted;
  }

  struct Ballot {
    bool isOpen;

    uint startTime;
    uint deposit;

    // Список проголосовавших.
    mapping (address => Voter) voters;

    // Список кадидатов
    uint candidatesCount;
    mapping (uint => Candidate) candidates;
  }

  uint count;
  mapping(uint => Ballot) ballots;

  function addVoting() public {
    require(msg.sender == owner, "You are not owner!");
    count++;

    Ballot storage b = ballots[count];
    b.isOpen = true;
    b.startTime = block.timestamp;

    // В ТЗ не указано как добавлять кандидатов, поэтому сделал так.
    b.candidatesCount++;
    b.candidates[b.candidatesCount-1] = Candidate("candidate 1", 0, owner);

    b.candidatesCount++;
    b.candidates[b.candidatesCount-1] = Candidate("candidate 2", 0, owner);

    b.candidatesCount++;
    b.candidates[b.candidatesCount-1] = Candidate("candidate 3", 0, owner);
  }

  function vote(uint ballotID, uint candidateID) public payable {
    // Для участия необходимо внести .001 ETH
    require(msg.value >= .001 ether, "To participate, you need to deposit .001 ETH");
    // Можно участвовать только один раз
    require(!ballots[ballotID].voters[msg.sender].voted, "You can only participate once");
    // Голосование существует
    require(ballots[ballotID].isOpen, "Ballot does not exist");
    // Кандидат существует
    require(ballots[ballotID].candidatesCount >= candidateID, "Candidate does not exist");

    Ballot storage b = ballots[ballotID];
    
    b.deposit += msg.value;
    b.voters[msg.sender].voted = true;
    b.candidates[candidateID].totalVotes++;
  }

  function finish(uint ballotID) public {
    // Голосование существует
    require(ballots[ballotID].isOpen, "Ballot does not exist");

    if (block.timestamp >= ballots[ballotID].startTime + 3 days) {
      Ballot storage b = ballots[ballotID];

      uint winnerID;
      uint max;
      for (uint i = 1; i < b.candidatesCount; i++) {
        if (b.candidates[i].totalVotes > max) {
          max = b.candidates[i].totalVotes;
          winnerID = i;
        }
      }

      uint commission = b.deposit / 100 * 10;
      uint toWinner = b.deposit - commission;

      payable(b.candidates[winnerID].wallet).transfer(toWinner);
      
      b.isOpen = false;
    }
  }

  function withdraw() public {
    require(msg.sender == owner, "You are not owner");
    payable(owner).transfer(address(this).balance);
  }

  function ballotInfoIsOpen(uint ballotID) public view returns(bool) {
    require(ballots[ballotID].startTime > 0, "Ballot does not exist");
    return ballots[ballotID].isOpen;
  }

  function ballotInfoStartTime(uint ballotID) public view returns(uint) {
    require(ballots[ballotID].startTime > 0, "Ballot does not exist");
    return ballots[ballotID].startTime;
  }

  function ballotInfoDeposit(uint ballotID) public view returns(uint) {
    require(ballots[ballotID].startTime > 0, "Ballot does not exist");
    return ballots[ballotID].deposit;
  }

  function ballotInfoGetCandidates(uint ballotID) public view returns(address[] memory) {
    require(ballots[ballotID].startTime > 0, "Ballot does not exist");
    address[] memory answer = new address[](ballots[ballotID].candidatesCount);
    for (uint i = 0; i < ballots[ballotID].candidatesCount; i++) {
      answer[i] = ballots[ballotID].candidates[i].wallet;
    }
    return answer;
  }
}
