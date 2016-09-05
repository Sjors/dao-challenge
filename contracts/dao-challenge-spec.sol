import 'dapple/test.sol';
import '../contracts/dao-challenge.sol';

contract User {

  function buyTokens (DaoChallenge chal, uint256 n) returns (uint256) {
    return chal.buyTokens.value(n * chal.tokenPrice())();
  }

  function placeSellOrder (DaoChallenge chal, uint256 n, uint256 price) returns (SellOrder) {
    return chal.placeSellOrder(n, price);
  }

  function cancelSellOrder (DaoChallenge chal, address addr) {
    chal.cancelSellOrder(addr);
  }

  function getTokenBalance (DaoChallenge chal) returns (uint256) {
    return chal.getTokenBalance();
  }
}

contract DaoChallengeTest is Test {
    DaoChallenge chal;
    Tester proxy_tester;

    User userA;

    function setUp() {
        chal = new DaoChallenge();
        uint256 mockFunds = 50; // 50 wei

        userA = new User();
        if(!userA.send(mockFunds)) throw; // Fund User A

        proxy_tester = new Tester();
        proxy_tester._target(chal);
    }
}

contract DaoChallengeConstructorTest is DaoChallengeTest {

    function testStoresChallengeOwner() {
        assertEq( address(this), chal.challengeOwner() );
    }

    function testInitialEtherBalanceShouldBeZero() {
      assertEq( chal.balance, 0 );
    }

}

contract DaoChallengeIssueTokensTest is DaoChallengeTest {
  function testIssueTokens () {
    // Issue 1000 tokens at 1 szabo each, sale ends in the year 3000.
    chal.issueTokens(1000, 1, 32503680000);
    assertEq(chal.tokenPrice(), 1);
  }
}

contract DaoChallengeBuyTokensTest is DaoChallengeTest {
  function setUp() {
    super.setUp();

    // Issue 1000 tokens at 1 szabo each, sale ends in the year 3000.
    chal.issueTokens(1000, 1, 32503680000);
  }

  function testBuyTenTokens () {
    userA.buyTokens(chal, 10);
    assertEq(userA.getTokenBalance(chal), 10);
  }
}

contract DaoChallengePlaceSellOrderTest is DaoChallengeTest {
  function setUp() {
    super.setUp();

    // Challenge owner issues tokens, user A buys 10:
    chal.issueTokens(1000, 1, 32503680000);
    userA.buyTokens(chal, 10);
  }

  function testSellTwoTokens () {
    // Offer to sell 2 tokens for 1 finney each
    userA.placeSellOrder(chal, 2, 1000);
  }
}

contract DaoChallengeCancelSellOrderTest is DaoChallengeTest {
  SellOrder order;

  function setUp() {
    super.setUp();

    // Challenge owner issues tokens, user A buys 10:
    chal.issueTokens(1000, 1, 32503680000);
    userA.buyTokens(chal, 10);

    // Place a sell order
    order = userA.placeSellOrder(chal, 2, 1000);
  }

  function testCancelSellOrder () {
    userA.cancelSellOrder(chal, address(order));
    assertEq(userA.getTokenBalance(chal), 10);
  }

  function testThrowCancelSellOrderTwice () {
    userA.cancelSellOrder(chal, address(order));
    userA.cancelSellOrder(chal, address(order));
  }
}
