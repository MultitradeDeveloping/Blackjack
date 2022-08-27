// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Blackjack {
    uint public player1 = 0;
    uint public player2 = 0;
    uint public bank = 0;    
    bool nowplaying1 = true;
    bool firstround = true;
    bool consensus = true;
    bool Imt21 = false;
    string aax = "";
    uint t;

    bool endgame1 = false;
    bool endgame2 = false;

    uint constant fee = 4;

    address p1;
    address p2;

    uint public bet1 = 0;
    uint public bet2 = 0;
    uint public debt1 = 0;

    uint public maxbet = 1000000000000000000;

function random() internal view returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
    randomnumber = randomnumber + 1;
    return randomnumber;
}

function endgame() public{
require(consensus == true, "set the same bet. Use 'equalize'");
if(msg.sender == p1){
        if(endgame1 == false)
            {endgame1 = true;}
        else{
            require(endgame2 == true, "you've already agreed to end game. Another player must agree it too");
            setwinner();
        }
    }
else{
require(msg.sender == p2, "play from 1 account");
     if(endgame2 == false)
            {endgame2 = true;}
        else{
            require(endgame1 == true, "you've already agreed to end game. Another player must agree it too");
            setwinner() ;
        }
    }
}


function setwinner() private{
if(player1 > player2){
    if(player1 <= 21){
        address payable p1x = payable(p1);
        withdraw(p1x);
    }
    else{
        address payable p2x = payable(p2);
        withdraw(p2x);
    }
}
else{
    if(player1 < player2){
    if(player2 <= 21){
        address payable p2x = payable(p2);
        withdraw(p2x);
    } 
    else{
        address payable p1x = payable(p1);
        withdraw(p1x);
    }
}
    else{
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
        randomnumber = randomnumber + 1;
        player1 + randomnumber;
        player2 + randomnumber;
        setwinner;
        aax = "The same number of points were scored. The winner was determined by redrawing the card";
    }
    clean();
}
}
modifier accrq(){
    if(firstround == true){
        if(nowplaying1 == false){
        require(msg.sender != p1, "different users must play from different wallets");
        _;
        }
        else{_;}
    }
    else{
        if(nowplaying1 == true){
            require(msg.sender == p1, "play from 1 account");
            _;}
        else{
            require(msg.sender == p2, "play from 1 account");
        _;
    }
}
}

function pass() public payable{
    if(msg.sender == p1){
        address payable p2x = payable(p2);
        withdraw(p2x);
       clean();
    } 
    else{
        require(msg.sender == p2);
        address payable p1x = payable(p1);
        withdraw(p1x);
        clean();

    }
}

function withdraw(address payable _to) private{
_to.transfer(address(this).balance);
}

function equalize() public payable{    
    if (consensus == false){
        require(msg.value == debt1, "please indicate the amount of payment equal to the debt");
        bet1 = bet1 + msg.value;
        consensus = true;
        debt1 = 0;}
    }

event Paid(address indexed _from, uint _amount, uint _timestamp);

function takecard() public payable accrq {
      require(consensus == true, "please, use function 'equalize' to return debt");
      endgame1 = false;
      endgame2 = false;
      uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
        randomnumber = randomnumber + 1;
        bet1 = bet1++;
     if(firstround == true){
       if(nowplaying1 == true){
           require(msg.sender.balance >= maxbet, "your balance is lower than max bet");
           require(bet1 + msg.value <= maxbet, "your bet is higher then max bet ");
           player1 = player1 + randomnumber;
           bet1 = bet1 + msg.value;
           p1 = msg.sender;
         emit Paid(msg.sender, msg.value, block.timestamp);
         nowplaying1 = false;
         bet1 = bet1 --;
        
       }
       else{
        require(bet2 + msg.value >= bet1);
        require(msg.sender.balance >= maxbet, "your balance is lower than max bet");
        require(bet2 + msg.value <= maxbet, "your bet is higher then max bet ");
        player2 = player2 + randomnumber; 
        bet2 = bet2 + msg.value;
        firstround = false;
        p2 = msg.sender;
        nowplaying1 = true;
        if(bet2 == bet1){
        consensus = true;
        }
        else{consensus = false;
        debt1 = bet2 - bet1;
        
        }
        }
       
}
    else{
        if(nowplaying1 == true){
        require(msg.sender.balance >= maxbet, "your balance is lower than max bet");
        require(bet1 + msg.value <= maxbet, "your bet is higher then max bet ");
           player1 = player1 + randomnumber;
           nowplaying1 = false;
           bet1 = bet1 + msg.value;
       }
        else{
        require(msg.sender.balance >= maxbet, "your balance is lower than max bet");
        require(bet2 + msg.value <= maxbet, "your bet is higher then max bet ");
        require(bet2 + msg.value >= bet1);
        player2 = player2 + randomnumber;  
        nowplaying1 = true;
        bet2 = bet2 + msg.value;
            if(bet2 == bet1){consensus = true;}
            else{consensus = false;}
        }
    }
}

function stand() public payable accrq {
    if(firstround == true){
       if(nowplaying1 == true){
           bet1 = bet1 + msg.value;
           p1 = msg.sender;
         emit Paid(msg.sender, msg.value, block.timestamp);
         nowplaying1 = false;
         bet1 = bet1 --;
       }
       else{
        bet2 = bet2 + msg.value;
        firstround = false;
        p2 = msg.sender;
        nowplaying1 = true;
        }
}

    else{
        if(nowplaying1 == true){
           nowplaying1 = false;
           bet1 = bet1 + msg.value;
           bet1 = bet1 --;
       }
        else{ 
        nowplaying1 = true;
        bet2 = bet2 + msg.value;
        }
        }
    }

    //Изменить максимальную ставку
    function changeMaxBet(uint maxbetEth) public{
        require(firstround = true, "you can't change max bet during game");
        maxbet = maxbetEth * 1000000000000000000;   
    }

function td() public view returns(uint){return(t);}

function clean() private{
    player1 = 0;
     player2 = 0;
     bank = 0;    
     nowplaying1 = true;
     firstround = true;
     consensus = true;
     Imt21 = false;
     aax = "";

     endgame1 = false;
     endgame2 = false;
     p1;
     p2;

     bet1 = 0;
     bet2 = 0;
     debt1 = 0;

     maxbet = 1000000000000000000;

   
}
}  
