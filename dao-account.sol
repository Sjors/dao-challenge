contract DaoAccount
{
	/**************************
			    Constants
	***************************/

	/**************************
					Events
	***************************/

	// No events

	/**************************
	     Public variables
	***************************/


	/**************************
	     Private variables
	***************************/

	uint256 tokenBalance; // number of tokens in this account
  address owner;        // owner of the otkens
	address daoChallenge; // the DaoChallenge this account belongs to
	uint256 tokenPrice;

  // Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address challengeOwner;

	/**************************
			     Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	modifier onlyDaoChallenge() {if (daoChallenge != msg.sender) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

  function DaoAccount (address _owner, uint256 _tokenPrice, address _challengeOwner) noEther {
    owner = _owner;
		tokenPrice = _tokenPrice;
    daoChallenge = msg.sender;
		tokenBalance = 0;

    // Remove for a real DAO contract:
    challengeOwner = _challengeOwner;
	}

	function () {
		throw;
	}

	/**************************
	     Private functions
	***************************/

	/**************************
			 Public functions
	***************************/

	function getTokenBalance() constant returns (uint256 tokens) {
		return tokenBalance;
	}

	function buyTokens() onlyDaoChallenge returns (uint256 tokens) {
		uint256 amount = msg.value;

		// No free tokens:
		if (amount == 0) throw;

		// No fractional tokens:
		if (amount % tokenPrice != 0) throw;

		tokens = amount / tokenPrice;

		tokenBalance += tokens;

		return tokens;
	}

	function withdraw(uint256 tokens) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		tokenBalance -= tokens;
		if(!owner.call.value(tokens * tokenPrice)()) throw;
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		suicide(challengeOwner);
	}
}
