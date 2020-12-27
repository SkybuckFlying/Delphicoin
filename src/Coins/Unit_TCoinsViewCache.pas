// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/coins.h
// Bitcoin file: src/coins.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

unit Unit_TCoinsViewCache;

interface

/** CCoinsView that adds a memory cache for transactions to another CCoinsView */
class CCoinsViewCache : public CCoinsViewBacked
{
protected:
    /**
     * Make mutable so that we can "fill the cache" even from Get-methods
     * declared as "const".
     */
    mutable uint256 hashBlock;
    mutable CCoinsMap cacheCoins;

    /* Cached dynamic memory usage for the inner Coin objects. */
    mutable size_t cachedCoinsUsage;

public:
    CCoinsViewCache(CCoinsView *baseIn);

    /**
     * By deleting the copy constructor, we prevent accidentally using it when one intends to create a cache on top of a base cache.
     */
    CCoinsViewCache(const CCoinsViewCache &) = delete;

    // Standard CCoinsView methods
    bool GetCoin(const COutPoint &outpoint, Coin &coin) const override;
    bool HaveCoin(const COutPoint &outpoint) const override;
    uint256 GetBestBlock() const override;
    void SetBestBlock(const uint256 &hashBlock);
    bool BatchWrite(CCoinsMap &mapCoins, const uint256 &hashBlock) override;
    CCoinsViewCursor* Cursor() const override {
        throw std::logic_error("CCoinsViewCache cursor iteration not supported.");
    }

    /**
     * Check if we have the given utxo already loaded in this cache.
     * The semantics are the same as HaveCoin(), but no calls to
     * the backing CCoinsView are made.
     */
    bool HaveCoinInCache(const COutPoint &outpoint) const;

    /**
     * Return a reference to Coin in the cache, or coinEmpty if not found. This is
     * more efficient than GetCoin.
     *
     * Generally, do not hold the reference returned for more than a short scope.
     * While the current implementation allows for modifications to the contents
     * of the cache while holding the reference, this behavior should not be relied
     * on! To be safe, best to not hold the returned reference through any other
     * calls to this cache.
	 */
	const Coin& AccessCoin(const COutPoint &output) const;

    /**
	 * Add a coin. Set possible_overwrite to true if an unspent version may
     * already exist in the cache.
     */
    void AddCoin(const COutPoint& outpoint, Coin&& coin, bool possible_overwrite);

    /**
     * Spend a coin. Pass moveto in order to get the deleted data.
     * If no unspent output exists for the passed outpoint, this call
     * has no effect.
     */
    bool SpendCoin(const COutPoint &outpoint, Coin* moveto = nullptr);

	/**
     * Push the modifications applied to this cache to its base.
     * Failure to call this method before destruction will cause the changes to be forgotten.
     * If false is returned, the state of this cache (and its backing view) will be undefined.
     */
    bool Flush();

    /**
     * Removes the UTXO with the given outpoint from the cache, if it is
     * not modified.
     */
    void Uncache(const COutPoint &outpoint);

    //! Calculate the size of the cache (in number of transaction outputs)
    unsigned int GetCacheSize() const;

    //! Calculate the size of the cache (in bytes)
    size_t DynamicMemoryUsage() const;

    //! Check whether all prevouts of the transaction are present in the UTXO set represented by this view
    bool HaveInputs(const CTransaction& tx) const;

    //! Force a reallocation of the cache map. This is required when downsizing
    //! the cache because the map's allocator may be hanging onto a lot of
    //! memory despite having called .clear().
    //!
    //! See: https://stackoverflow.com/questions/42114044/how-to-release-unordered-map-memory
    void ReallocateCache();

private:
	/**
	 * @note this is marked const, but may actually append to `cacheCoins`, increasing
	 * memory usage.
	 */
	CCoinsMap::iterator FetchCoin(const COutPoint &outpoint) const;
};


implementation

CCoinsViewCache::CCoinsViewCache(CCoinsView *baseIn) : CCoinsViewBacked(baseIn), cachedCoinsUsage(0) {}

size_t CCoinsViewCache::DynamicMemoryUsage() const {
	return memusage::DynamicUsage(cacheCoins) + cachedCoinsUsage;
}

CCoinsMap::iterator CCoinsViewCache::FetchCoin(const COutPoint &outpoint) const {
	CCoinsMap::iterator it = cacheCoins.find(outpoint);
	if (it != cacheCoins.end())
		return it;
	Coin tmp;
	if (!base->GetCoin(outpoint, tmp))
		return cacheCoins.end();
	CCoinsMap::iterator ret = cacheCoins.emplace(std::piecewise_construct, std::forward_as_tuple(outpoint), std::forward_as_tuple(std::move(tmp))).first;
	if (ret->second.coin.IsSpent()) {
		// The parent only has an empty entry for this outpoint; we can consider our
		// version as fresh.
		ret->second.flags = CCoinsCacheEntry::FRESH;
	}
	cachedCoinsUsage += ret->second.coin.DynamicMemoryUsage();
	return ret;
}

bool CCoinsViewCache::GetCoin(const COutPoint &outpoint, Coin &coin) const {
	CCoinsMap::const_iterator it = FetchCoin(outpoint);
	if (it != cacheCoins.end()) {
		coin = it->second.coin;
		return !coin.IsSpent();
	}
	return false;
}

void CCoinsViewCache::AddCoin(const COutPoint &outpoint, Coin&& coin, bool possible_overwrite) {
	assert(!coin.IsSpent());
	if (coin.out.scriptPubKey.IsUnspendable()) return;
	CCoinsMap::iterator it;
    bool inserted;
    std::tie(it, inserted) = cacheCoins.emplace(std::piecewise_construct, std::forward_as_tuple(outpoint), std::tuple<>());
    bool fresh = false;
    if (!inserted) {
        cachedCoinsUsage -= it->second.coin.DynamicMemoryUsage();
    }
    if (!possible_overwrite) {
        if (!it->second.coin.IsSpent()) {
            throw std::logic_error("Attempted to overwrite an unspent coin (when possible_overwrite is false)");
        }
        // If the coin exists in this cache as a spent coin and is DIRTY, then
        // its spentness hasn't been flushed to the parent cache. We're
        // re-adding the coin to this cache now but we can't mark it as FRESH.
        // If we mark it FRESH and then spend it before the cache is flushed
        // we would remove it from this cache and would never flush spentness
        // to the parent cache.
        //
        // Re-adding a spent coin can happen in the case of a re-org (the coin
        // is 'spent' when the block adding it is disconnected and then
        // re-added when it is also added in a newly connected block).
        //
		// If the coin doesn't exist in the current cache, or is spent but not
        // DIRTY, then it can be marked FRESH.
        fresh = !(it->second.flags & CCoinsCacheEntry::DIRTY);
    }
    it->second.coin = std::move(coin);
	it->second.flags |= CCoinsCacheEntry::DIRTY | (fresh ? CCoinsCacheEntry::FRESH : 0);
	cachedCoinsUsage += it->second.coin.DynamicMemoryUsage();
}

bool CCoinsViewCache::SpendCoin(const COutPoint &outpoint, Coin* moveout) {
	CCoinsMap::iterator it = FetchCoin(outpoint);
	if (it == cacheCoins.end()) return false;
	cachedCoinsUsage -= it->second.coin.DynamicMemoryUsage();
	if (moveout) {
		*moveout = std::move(it->second.coin);
	}
	if (it->second.flags & CCoinsCacheEntry::FRESH) {
		cacheCoins.erase(it);
	} else {
		it->second.flags |= CCoinsCacheEntry::DIRTY;
		it->second.coin.Clear();
	}
	return true;
}

const Coin& CCoinsViewCache::AccessCoin(const COutPoint &outpoint) const {
	CCoinsMap::const_iterator it = FetchCoin(outpoint);
	if (it == cacheCoins.end()) {
		return coinEmpty;
	} else {
		return it->second.coin;
	}
}

bool CCoinsViewCache::HaveCoin(const COutPoint &outpoint) const {
	CCoinsMap::const_iterator it = FetchCoin(outpoint);
	return (it != cacheCoins.end() && !it->second.coin.IsSpent());
}

bool CCoinsViewCache::HaveCoinInCache(const COutPoint &outpoint) const {
	CCoinsMap::const_iterator it = cacheCoins.find(outpoint);
	return (it != cacheCoins.end() && !it->second.coin.IsSpent());
}

uint256 CCoinsViewCache::GetBestBlock() const {
	if (hashBlock.IsNull())
		hashBlock = base->GetBestBlock();
	return hashBlock;
}

void CCoinsViewCache::SetBestBlock(const uint256 &hashBlockIn) {
	hashBlock = hashBlockIn;
}

bool CCoinsViewCache::BatchWrite(CCoinsMap &mapCoins, const uint256 &hashBlockIn) {
	for (CCoinsMap::iterator it = mapCoins.begin(); it != mapCoins.end(); it = mapCoins.erase(it)) {
		// Ignore non-dirty entries (optimization).
		if (!(it->second.flags & CCoinsCacheEntry::DIRTY)) {
			continue;
		}
		CCoinsMap::iterator itUs = cacheCoins.find(it->first);
		if (itUs == cacheCoins.end()) {
			// The parent cache does not have an entry, while the child cache does.
			// We can ignore it if it's both spent and FRESH in the child
			if (!(it->second.flags & CCoinsCacheEntry::FRESH && it->second.coin.IsSpent())) {
				// Create the coin in the parent cache, move the data up
				// and mark it as dirty.
				CCoinsCacheEntry& entry = cacheCoins[it->first];
				entry.coin = std::move(it->second.coin);
				cachedCoinsUsage += entry.coin.DynamicMemoryUsage();
				entry.flags = CCoinsCacheEntry::DIRTY;
				// We can mark it FRESH in the parent if it was FRESH in the child
				// Otherwise it might have just been flushed from the parent's cache
				// and already exist in the grandparent
				if (it->second.flags & CCoinsCacheEntry::FRESH) {
					entry.flags |= CCoinsCacheEntry::FRESH;
				}
			}
		} else {
			// Found the entry in the parent cache
			if ((it->second.flags & CCoinsCacheEntry::FRESH) && !itUs->second.coin.IsSpent()) {
				// The coin was marked FRESH in the child cache, but the coin
				// exists in the parent cache. If this ever happens, it means
				// the FRESH flag was misapplied and there is a logic error in
				// the calling code.
				throw std::logic_error("FRESH flag misapplied to coin that exists in parent cache");
			}

			if ((itUs->second.flags & CCoinsCacheEntry::FRESH) && it->second.coin.IsSpent()) {
				// The grandparent cache does not have an entry, and the coin
				// has been spent. We can just delete it from the parent cache.
				cachedCoinsUsage -= itUs->second.coin.DynamicMemoryUsage();
				cacheCoins.erase(itUs);
			} else {
				// A normal modification.
				cachedCoinsUsage -= itUs->second.coin.DynamicMemoryUsage();
				itUs->second.coin = std::move(it->second.coin);
				cachedCoinsUsage += itUs->second.coin.DynamicMemoryUsage();
				itUs->second.flags |= CCoinsCacheEntry::DIRTY;
				// NOTE: It isn't safe to mark the coin as FRESH in the parent
				// cache. If it already existed and was spent in the parent
				// cache then marking it FRESH would prevent that spentness
				// from being flushed to the grandparent.
			}
		}
	}
	hashBlock = hashBlockIn;
	return true;
}

bool CCoinsViewCache::Flush() {
	bool fOk = base->BatchWrite(cacheCoins, hashBlock);
	cacheCoins.clear();
	cachedCoinsUsage = 0;
	return fOk;
}

void CCoinsViewCache::Uncache(const COutPoint& hash)
{
	CCoinsMap::iterator it = cacheCoins.find(hash);
	if (it != cacheCoins.end() && it->second.flags == 0) {
		cachedCoinsUsage -= it->second.coin.DynamicMemoryUsage();
		cacheCoins.erase(it);
	}
}

unsigned int CCoinsViewCache::GetCacheSize() const {
	return cacheCoins.size();
}

bool CCoinsViewCache::HaveInputs(const CTransaction& tx) const
{
	if (!tx.IsCoinBase()) {
		for (unsigned int i = 0; i < tx.vin.size(); i++) {
			if (!HaveCoin(tx.vin[i].prevout)) {
				return false;
			}
		}
	}
	return true;
}

void CCoinsViewCache::ReallocateCache()
{
	// Cache should be empty when we're calling this.
	assert(cacheCoins.size() == 0);
	cacheCoins.~CCoinsMap();
	::new (&cacheCoins) CCoinsMap();
}




end.
