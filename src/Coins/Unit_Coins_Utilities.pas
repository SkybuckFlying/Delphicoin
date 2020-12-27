// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/coins.h
// Bitcoin file: src/coins.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

unit Unit_Coins_Utilities;

interface

{
#include <compressor.h>
#include <core_memusage.h>
#include <crypto/siphash.h>
#include <memusage.h>
#include <primitives/transaction.h>
#include <serialize.h>
#include <uint256.h>

#include <assert.h>
#include <stdint.h>

#include <functional>
#include <unordered_map>
}




//! Utility function to add all of a transaction's outputs to a cache.
//! When check is false, this assumes that overwrites are only possible for coinbase transactions.
//! When check is true, the underlying view may be queried to determine whether an addition is
//! an overwrite.
// TODO: pass in a boolean to limit these possible overwrites to known
// (pre-BIP34) cases.
void AddCoins(CCoinsViewCache& cache, const CTransaction& tx, int nHeight, bool check = false);

//! Utility function to find any unspent output with a given txid.
//! This function can be quite expensive because in the event of a transaction
//! which is not found in the cache, it can cause up to MAX_OUTPUTS_PER_BLOCK
//! lookups to database, so it should be used with care.
const Coin& AccessByTxid(const CCoinsViewCache& cache, const uint256& txid);


implementation

#include <coins.h>

#include <consensus/consensus.h>
#include <logging.h>
#include <random.h>
#include <version.h>





void AddCoins(CCoinsViewCache& cache, const CTransaction &tx, int nHeight, bool check_for_overwrite) {
	bool fCoinbase = tx.IsCoinBase();
	const uint256& txid = tx.GetHash();
	for (size_t i = 0; i < tx.vout.size(); ++i) {
		bool overwrite = check_for_overwrite ? cache.HaveCoin(COutPoint(txid, i)) : fCoinbase;
		// Coinbase transactions can always be overwritten, in order to correctly
		// deal with the pre-BIP30 occurrences of duplicate coinbase transactions.
		cache.AddCoin(COutPoint(txid, i), Coin(tx.vout[i], nHeight, fCoinbase), overwrite);
	}
}


static const Coin coinEmpty;


static const size_t MIN_TRANSACTION_OUTPUT_WEIGHT = WITNESS_SCALE_FACTOR * ::GetSerializeSize(CTxOut(), PROTOCOL_VERSION);
static const size_t MAX_OUTPUTS_PER_BLOCK = MAX_BLOCK_WEIGHT / MIN_TRANSACTION_OUTPUT_WEIGHT;

const Coin& AccessByTxid(const CCoinsViewCache& view, const uint256& txid)
{
	COutPoint iter(txid, 0);
	while (iter.n < MAX_OUTPUTS_PER_BLOCK) {
		const Coin& alternate = view.AccessCoin(iter);
		if (!alternate.IsSpent()) return alternate;
		++iter.n;
	}
	return coinEmpty;
}



end.
