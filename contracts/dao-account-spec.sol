import 'dapple/test.sol';
import '../contracts/dao-account.sol';

// Mock DaoChallenge with several test helper methods
contract DaoChallenge {
  uint256 public token_price = 1; // 1000000000000000; // 1 finney

  function createAccount (address challengeOwner) returns (DaoAccount) {
     DaoAccount account = new DaoAccount(this, token_price, challengeOwner);
     return account;
  }

  function buyTokens (DaoAccount account, uint256 amount) returns (uint256) {
    return account.buyTokens.value(amount)();
  }
}

contract DaoAccountTest is Test {
    DaoChallenge chal;
    DaoAccount acc;
    Tester proxy_tester;
    address challenge_owner = address(this);

    function setUp() {
        chal = new DaoChallenge();
        uint256 mockFunds = 1000;
        if(!chal.send(mockFunds)) throw; // Fund the mock DaoChallenge
        acc = chal.createAccount(address(this));
        proxy_tester = new Tester();
        proxy_tester._target(acc);
    }

    // Constructor

    function testConstructorStoresChallengeOwner() {
        assertEq( address(this), acc.challengeOwner() );
    }

    function testConstructorStoresParentChallenge() {
        assertEq( address(chal), acc.daoChallenge() );
    }

    function testConstructorInitialTokenBalanceShouldBeZero() {
      assertEq( acc.getTokenBalance(), 0 );
    }

    function testConstructorInitialEtherBalanceShouldBeZero() {
      assertEq( acc.balance, 0 );
    }

    // buyTokens()

    function testBuyTokensTwoTokens() {
      uint256 tokens = chal.buyTokens(acc, chal.token_price() * 2);
      assertEq( tokens, 2 );
      assertEq( acc.getTokenBalance(), 2 );
      assertEq( acc.balance, chal.token_price() * 2 );
    }

    function testThrowBuyTokensNoFreeTokens() {
      chal.buyTokens(acc, 0);
    }

    function testThrowBuyTokensNoPartialTokens() {
      chal.buyTokens(acc, chal.token_price() / 2);
    }
}
