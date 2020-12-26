// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TCoinsViewErrorCatcher;

interface

/**
 * This is a minimally invasive approach to shutdown on LevelDB read errors from the
 * chainstate, while keeping user interface out of the common library, which is shared
 * between bitcoind, and bitcoin-qt and non-server tools.
 *
 * Writes do not need similar protection, as failure to write is handled by the caller.
*/
class CCoinsViewErrorCatcher final : public CCoinsViewBacked
{
public:
	explicit CCoinsViewErrorCatcher(CCoinsView* view) : CCoinsViewBacked(view) {}

	void AddReadErrCallback(std::function<void()> f) {
		m_err_callbacks.emplace_back(std::move(f));
	}

	bool GetCoin(const COutPoint &outpoint, Coin &coin) const override;

private:
	/** A list of callbacks to execute upon leveldb read error. */
	std::vector<std::function<void()>> m_err_callbacks;

};

implementation

bool CCoinsViewErrorCatcher::GetCoin(const COutPoint &outpoint, Coin &coin) const {
	try {
		return CCoinsViewBacked::GetCoin(outpoint, coin);
	} catch(const std::runtime_error& e) {
		for (auto f : m_err_callbacks) {
			f();
		}
		LogPrintf("Error reading from database: %s\n", e.what());
		// Starting the shutdown sequence and returning false to the caller would be
		// interpreted as 'entry not found' (as opposed to unable to read data), and
		// could lead to invalid interpretation. Just exit immediately, as we can't
		// continue anyway, and all writes should be atomic.
		std::abort();
	}
}


end.
