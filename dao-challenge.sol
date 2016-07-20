import "./dao-account.sol";

contract DaoChallenge
{
	/**************************
					Constants
	***************************/

	// No Constants

	/**************************
					Events
	***************************/

	event notifyTerminate(uint256 finalBalance);

	/**************************
	     Public variables
	***************************/

	/**************************
			 Private variables
	***************************/

	// Owner of the challenge; a real DAO doesn't an owner.
	address owner;

	mapping (address => DaoAccount) private daoAccounts;

	/**************************
					 Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

	function DaoChallenge () {
		owner = msg.sender; // Owner of the challenge. Don't use this in a real DAO.
	}

	function () noEther {
	}

	/**************************
	     Private functions
	***************************/

	// No private functions

	/**************************
	     Public functions
	***************************/

	function createAccount () noEther returns (DaoAccount account) {
		address accountOwner = msg.sender;
		address challengeOwner = owner; // Don't use in a real DAO

		// One account per address:
		if(daoAccounts[accountOwner] != DaoAccount(0x00)) throw;

		daoAccounts[accountOwner] = new DaoAccount(accountOwner, challengeOwner);
		return daoAccounts[accountOwner];
	}

	function myAccount () noEther returns (DaoAccount) {
		address accountOwner = msg.sender;
		return daoAccounts[accountOwner];
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyOwner {
		notifyTerminate(this.balance);
		suicide(owner);
	}
}
