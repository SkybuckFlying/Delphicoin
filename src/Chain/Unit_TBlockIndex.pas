// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.


unit Unit_TBlockIndex;

interface

// Skybuck: example usage
{

uses
	arith_uint256,
	consensus.params,
	flatfile,
	primitives.block,
	tinyformat,
	uint256,
	vector;

}

// Skybuck: don't know for sure yet how to convert this probably just some constants.
// perhaps these constats must be moved elsewhere or seperated into a unit if it's shared.

{**
 * Maximum amount of time that a block timestamp is allowed to exceed the
 * current network-adjusted time before the block will be accepted.
 *}
static constexpr int64_t MAX_FUTURE_BLOCK_TIME = 2 * 60 * 60;

{**
 * Timestamp window used as a grace period by code that compares external
 * timestamps (such as timestamps passed to RPCs, or wallet key creation times)
 * to block timestamps. This should be set at least as high as
 * MAX_FUTURE_BLOCK_TIME.
 *}
static constexpr int64_t TIMESTAMP_WINDOW = MAX_FUTURE_BLOCK_TIME;

{**
 * Maximum gap between node time and block time used
 * for the "Catching up..." mode in GUI.
 *
 * Ref: https://github.com/bitcoin/bitcoin/pull/1026
 *}
static constexpr int64_t MAX_BLOCK_TIME_GAP = 90 * 60;

*)




type
	{** The block chain is a tree shaped structure starting with the
	 * genesis block at the root, with each block potentially having multiple
	 * candidates to be the next block. A blockindex may have multiple pprev pointing
	 * to it, but at most one of them can be part of the currently active branch.
	 *}
	TBlockIndex = class
	public
		//! pointer to the hash of the block, if any. Memory is owned by this CBlockIndex
		const uint256* phashBlock{nullptr};

		//! pointer to the index of the predecessor of this block
		CBlockIndex* pprev{nullptr};

		//! pointer to the index of some further predecessor of this block
		CBlockIndex* pskip{nullptr};

		//! height of the entry in the chain. The genesis block has height 0
		int nHeight{0};

		//! Which # file this block is stored in (blk?????.dat)
		int nFile{0};

		//! Byte offset within blk?????.dat where this block's data is stored
		unsigned int nDataPos{0};

		//! Byte offset within rev?????.dat where this block's undo data is stored
		unsigned int nUndoPos{0};

		//! (memory only) Total amount of work (expected number of hashes) in the chain up to and including this block
		arith_uint256 nChainWork{};

		//! Number of transactions in this block.
		//! Note: in a potential headers-first mode, this number cannot be relied upon
		unsigned int nTx{0};

		//! (memory only) Number of transactions in the chain up to and including this block.
		//! This value will be non-zero only if and only if transactions for this block and all its parents are available.
		//! Change to 64-bit type when necessary; won't happen before 2030
		unsigned int nChainTx{0};

		//! Verification status of this block. See enum BlockStatus
		uint32_t nStatus{0};

		//! block header
		int32_t nVersion{0};
		uint256 hashMerkleRoot{};
		uint32_t nTime{0};
		uint32_t nBits{0};
		uint32_t nNonce{0};

		//! (memory only) Sequential id assigned to distinguish order in which blocks are received.
		int32_t nSequenceId{0};

		//! (memory only) Maximum nTime in the chain up to and including this block.
		unsigned int nTimeMax{0};

		CBlockIndex()
		{
		}

		explicit CBlockIndex(const CBlockHeader& block)
			: nVersion{block.nVersion},
			  hashMerkleRoot{block.hashMerkleRoot},
			  nTime{block.nTime},
			  nBits{block.nBits},
			  nNonce{block.nNonce}
		{
		}

		FlatFilePos GetBlockPos() const {
			FlatFilePos ret;
				if (nStatus & BLOCK_HAVE_DATA) {
				ret.nFile = nFile;
				ret.nPos  = nDataPos;
			}
			return ret;
		}

		FlatFilePos GetUndoPos() const {
			FlatFilePos ret;
			if (nStatus & BLOCK_HAVE_UNDO) {
				ret.nFile = nFile;
				ret.nPos  = nUndoPos;
			}
			return ret;
		}

		CBlockHeader GetBlockHeader() const
		{
			CBlockHeader block;
			block.nVersion       = nVersion;
			if (pprev)
				block.hashPrevBlock = pprev->GetBlockHash();
			block.hashMerkleRoot = hashMerkleRoot;
			block.nTime          = nTime;
			block.nBits          = nBits;
			block.nNonce         = nNonce;
			return block;
		}

		uint256 GetBlockHash() const
		{
			return *phashBlock;
		}

		{**
		 * Check whether this block's and all previous blocks' transactions have been
		 * downloaded (and stored to disk) at some point.
		 *
		 * Does not imply the transactions are consensus-valid (ConnectTip might fail)
		 * Does not imply the transactions are still stored on disk. (IsBlockPruned might return true)
		 *}
		bool HaveTxsDownloaded() const { return nChainTx != 0; }

		int64_t GetBlockTime() const
		{
			return (int64_t)nTime;
		}

		int64_t GetBlockTimeMax() const
		{
			return (int64_t)nTimeMax;
		}

		static constexpr int nMedianTimeSpan = 11;

		int64_t GetMedianTimePast() const
		{
			int64_t pmedian[nMedianTimeSpan];
			int64_t* pbegin = &pmedian[nMedianTimeSpan];
			int64_t* pend = &pmedian[nMedianTimeSpan];

			const CBlockIndex* pindex = this;
			for (int i = 0; i < nMedianTimeSpan && pindex; i++, pindex = pindex->pprev)
				*(--pbegin) = pindex->GetBlockTime();

			std::sort(pbegin, pend);
			return pbegin[(pend - pbegin)/2];
		}

		std::string ToString() const
		{
			return strprintf("CBlockIndex(pprev=%p, nHeight=%d, merkle=%s, hashBlock=%s)",
				pprev, nHeight,
				hashMerkleRoot.ToString(),
				GetBlockHash().ToString());
		}

		//! Check whether this block index entry is valid up to the passed validity level.
		bool IsValid(enum BlockStatus nUpTo = BLOCK_VALID_TRANSACTIONS) const
		{
			assert(!(nUpTo & ~BLOCK_VALID_MASK)); // Only validity flags allowed.
			if (nStatus & BLOCK_FAILED_MASK)
				return false;
			return ((nStatus & BLOCK_VALID_MASK) >= nUpTo);
		}

		//! Raise the validity level of this block index entry.
		//! Returns true if the validity was changed.
		bool RaiseValidity(enum BlockStatus nUpTo)
		{
			assert(!(nUpTo & ~BLOCK_VALID_MASK)); // Only validity flags allowed.
			if (nStatus & BLOCK_FAILED_MASK)
				return false;
			if ((nStatus & BLOCK_VALID_MASK) < nUpTo) {
				nStatus = (nStatus & ~BLOCK_VALID_MASK) | nUpTo;
				return true;
			}
			return false;
		}

		//! Build the skiplist pointer for this entry.
		void BuildSkip();

		//! Efficiently find an ancestor of this block.
		CBlockIndex* GetAncestor(int height);
		const CBlockIndex* GetAncestor(int height) const;
	};


// Skybuck: might also have to be moved to a shared unit very maybe/perhaps.
arith_uint256 GetBlockProof(const CBlockIndex& block);

/** Return the time it would take to redo the work difference between from and to, assuming the current hashrate corresponds to the difficulty at tip, in seconds. */
int64_t GetBlockProofEquivalentTime(const CBlockIndex& to, const CBlockIndex& from, const CBlockIndex& tip, const Consensus::Params&);

/** Find the forking point between two chain tips. */
const CBlockIndex* LastCommonAncestor(const CBlockIndex* pa, const CBlockIndex* pb);

implementation

const CBlockIndex* CBlockIndex::GetAncestor(int height) const
{
    if (height > nHeight || height < 0) {
        return nullptr;
    }

	const CBlockIndex* pindexWalk = this;
    int heightWalk = nHeight;
    while (heightWalk > height) {
        int heightSkip = GetSkipHeight(heightWalk);
        int heightSkipPrev = GetSkipHeight(heightWalk - 1);
        if (pindexWalk->pskip != nullptr &&
            (heightSkip == height ||
             (heightSkip > height && !(heightSkipPrev < heightSkip - 2 &&
                                       heightSkipPrev >= height)))) {
            // Only follow pskip if pprev->pskip isn't better than pskip->pprev.
            pindexWalk = pindexWalk->pskip;
            heightWalk = heightSkip;
        } else {
            assert(pindexWalk->pprev);
            pindexWalk = pindexWalk->pprev;
            heightWalk--;
        }
    }
    return pindexWalk;
}

CBlockIndex* CBlockIndex::GetAncestor(int height)
{
    return const_cast<CBlockIndex*>(static_cast<const CBlockIndex*>(this)->GetAncestor(height));
}

void CBlockIndex::BuildSkip()
{
    if (pprev)
        pskip = pprev->GetAncestor(GetSkipHeight(nHeight));
}

arith_uint256 GetBlockProof(const CBlockIndex& block)
{
    arith_uint256 bnTarget;
    bool fNegative;
	bool fOverflow;
	bnTarget.SetCompact(block.nBits, &fNegative, &fOverflow);
    if (fNegative || fOverflow || bnTarget == 0)
        return 0;
    // We need to compute 2**256 / (bnTarget+1), but we can't represent 2**256
	// as it's too large for an arith_uint256. However, as 2**256 is at least as large
    // as bnTarget+1, it is equal to ((2**256 - bnTarget - 1) / (bnTarget+1)) + 1,
    // or ~bnTarget / (bnTarget+1) + 1.
    return (~bnTarget / (bnTarget + 1)) + 1;
}

int64_t GetBlockProofEquivalentTime(const CBlockIndex& to, const CBlockIndex& from, const CBlockIndex& tip, const Consensus::Params& params)
{
    arith_uint256 r;
    int sign = 1;
    if (to.nChainWork > from.nChainWork) {
        r = to.nChainWork - from.nChainWork;
    } else {
        r = from.nChainWork - to.nChainWork;
        sign = -1;
    }
    r = r * arith_uint256(params.nPowTargetSpacing) / GetBlockProof(tip);
    if (r.bits() > 63) {
        return sign * std::numeric_limits<int64_t>::max();
    }
    return sign * r.GetLow64();
}

/** Find the last common ancestor two blocks have.
 *  Both pa and pb must be non-nullptr. */
const CBlockIndex* LastCommonAncestor(const CBlockIndex* pa, const CBlockIndex* pb) {
    if (pa->nHeight > pb->nHeight) {
        pa = pa->GetAncestor(pb->nHeight);
    } else if (pb->nHeight > pa->nHeight) {
        pb = pb->GetAncestor(pa->nHeight);
    }

    while (pa != pb && pa && pb) {
        pa = pa->pprev;
        pb = pb->pprev;
    }

	// Eventually all chain branches meet at the genesis block.
	assert(pa == pb);
	return pa;
}

end.
