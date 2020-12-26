// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TSaltedOutputHasher;

interface

class SaltedOutpointHasher
{
private:
	/** Salt */
	const uint64_t k0, k1;

public:
	SaltedOutpointHasher();

	/**
	 * This *must* return size_t. With Boost 1.46 on 32-bit systems the
	 * unordered_map will behave unpredictably if the custom hasher returns a
	 * uint64_t, resulting in failures when syncing the chain (#4634).
	 *
	 * Having the hash noexcept allows libstdc++'s unordered_map to recalculate
	 * the hash during rehash, so it does not have to cache the value. This
	 * reduces node's memory by sizeof(size_t). The required recalculation has
	 * a slight performance penalty (around 1.6%), but this is compensated by
	 * memory savings of about 9% which allow for a larger dbcache setting.
	 *
	 * @see https://gcc.gnu.org/onlinedocs/gcc-9.2.0/libstdc++/manual/manual/unordered_associative.html
	 */
	size_t operator()(const COutPoint& id) const noexcept {
		return SipHashUint256Extra(k0, k1, id.hash, id.n);
	}
};


implementation

SaltedOutpointHasher::SaltedOutpointHasher() : k0(GetRand(std::numeric_limits<uint64_t>::max())), k1(GetRand(std::numeric_limits<uint64_t>::max())) {}


end.
