all: graphs

graphs:
	solgraph contracts/dao-challenge.sol DaoChallenge.dot
	dot -Tpng DaoChallenge.dot > DaoChallenge.png

	solgraph contracts/dao-account.sol > DaoAccount.dot
	dot -Tpng DaoAccount.dot > DaoAccount.png

	solgraph contracts/sell-order.sol > SellOrder.dot
	dot -Tpng SellOrder.dot > SellOrder.png
