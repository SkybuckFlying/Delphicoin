// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TChain;

interface

type
	{** An in-memory indexed chain of blocks. *}
	TChain = class
	private:
		std::vector<CBlockIndex*> vChain;

	public:
		{** Returns the index entry for the genesis block of this chain, or nullptr if none. *}
		CBlockIndex *Genesis() const {
			return vChain.size() > 0 ? vChain[0] : nullptr;
		}

		{** Returns the index entry for the tip of this chain, or nullptr if none. *}
		CBlockIndex *Tip() const {
			return vChain.size() > 0 ? vChain[vChain.size() - 1] : nullptr;
		}

		{** Returns the index entry at a particular height in this chain, or nullptr if no such height exists. *}
		CBlockIndex *operator[](int nHeight) const {
			if (nHeight < 0 || nHeight >= (int)vChain.size())
				return nullptr;
			return vChain[nHeight];
		}

		{** Efficiently check whether a block is present in this chain. *}
		bool Contains(const CBlockIndex *pindex) const {
			return (*this)[pindex->nHeight] == pindex;
		}

		{** Find the successor of a block in this chain, or nullptr if the given index is not found or is the tip. *}
		CBlockIndex *Next(const CBlockIndex *pindex) const {
			if (Contains(pindex))
				return (*this)[pindex->nHeight + 1];
			else
				return nullptr;
		}

		{** Return the maximal height in the chain. Is equal to chain.Tip() ? chain.Tip()->nHeight : -1. *}
		int Height() const {
			return vChain.size() - 1;
		}

		{** Set/initialize a chain with a given tip. *}
		void SetTip(CBlockIndex *pindex);

		{** Return a CBlockLocator that refers to a block in this chain (by default the tip). *}
		CBlockLocator GetLocator(const CBlockIndex *pindex = nullptr) const;

		{** Find the last common block between this chain and a block index entry. *}
		const CBlockIndex *FindFork(const CBlockIndex *pindex) const;

		{** Find the earliest block with timestamp equal or greater than the given time and height equal or greater than the given height. *}
		CBlockIndex* FindEarliestAtLeast(int64_t nTime, int height) const;
	end;


implementation

/**
 * CChain implementation
 */
void CChain::SetTip(CBlockIndex *pindex) {
    if (pindex == nullptr) {
        vChain.clear();
        return;
    }
    vChain.resize(pindex->nHeight + 1);
    while (pindex && vChain[pindex->nHeight] != pindex) {
        vChain[pindex->nHeight] = pindex;
        pindex = pindex->pprev;
    }
}

CBlockLocator CChain::GetLocator(const CBlockIndex *pindex) const {
    int nStep = 1;
    std::vector<uint256> vHave;
    vHave.reserve(32);

    if (!pindex)
        pindex = Tip();
    while (pindex) {
        vHave.push_back(pindex->GetBlockHash());
        // Stop when we have added the genesis block.
        if (pindex->nHeight == 0)
            break;
        // Exponentially larger steps back, plus the genesis block.
        int nHeight = std::max(pindex->nHeight - nStep, 0);
        if (Contains(pindex)) {
            // Use O(1) CChain index if possible.
            pindex = (*this)[nHeight];
        } else {
            // Otherwise, use O(log n) skiplist.
            pindex = pindex->GetAncestor(nHeight);
        }
		if (vHave.size() > 10)
            nStep *= 2;
    }

    return CBlockLocator(vHave);
}

const CBlockIndex *CChain::FindFork(const CBlockIndex *pindex) const {
    if (pindex == nullptr) {
        return nullptr;
    }
    if (pindex->nHeight > Height())
        pindex = pindex->GetAncestor(Height());
    while (pindex && !Contains(pindex))
        pindex = pindex->pprev;
    return pindex;
}

CBlockIndex* CChain::FindEarliestAtLeast(int64_t nTime, int height) const
{
    std::pair<int64_t, int> blockparams = std::make_pair(nTime, height);
    std::vector<CBlockIndex*>::const_iterator lower = std::lower_bound(vChain.begin(), vChain.end(), blockparams,
        [](CBlockIndex* pBlock, const std::pair<int64_t, int>& blockparams) -> bool { return pBlock->GetBlockTimeMax() < blockparams.first || pBlock->nHeight < blockparams.second; });
    return (lower == vChain.end() ? nullptr : *lower);
}

/** Turn the lowest '1' bit in the binary representation of a number into a '0'. */
int static inline InvertLowestOne(int n) { return n & (n - 1); }

/** Compute what height to jump back to with the CBlockIndex::pskip pointer. */
int static inline GetSkipHeight(int height) {
    if (height < 2)
        return 0;

    // Determine which height to jump back to. Any number strictly lower than height is acceptable,
    // but the following expression seems to perform well in simulations (max 110 steps to go back
    // up to 2**18 blocks).
    return (height & 1) ? InvertLowestOne(InvertLowestOne(height - 1)) + 1 : InvertLowestOne(height);
}


end.
