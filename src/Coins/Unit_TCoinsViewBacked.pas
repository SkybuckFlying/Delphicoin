// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/coins.h
// Bitcoin file: src/coins.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

unit Unit_TCoinsViewBacked;

interface

/** CCoinsView backed by another CCoinsView */
class CCoinsViewBacked : public CCoinsView
{
protected:
	CCoinsView *base;

public:
	CCoinsViewBacked(CCoinsView *viewIn);
	bool GetCoin(const COutPoint &outpoint, Coin &coin) const override;
	bool HaveCoin(const COutPoint &outpoint) const override;
	uint256 GetBestBlock() const override;
	std::vector<uint256> GetHeadBlocks() const override;
	void SetBackend(CCoinsView &viewIn);
	bool BatchWrite(CCoinsMap &mapCoins, const uint256 &hashBlock) override;
	CCoinsViewCursor *Cursor() const override;
	size_t EstimateSize() const override;
};


implementation

CCoinsViewBacked::CCoinsViewBacked(CCoinsView *viewIn) : base(viewIn) { }
bool CCoinsViewBacked::GetCoin(const COutPoint &outpoint, Coin &coin) const { return base->GetCoin(outpoint, coin); }
bool CCoinsViewBacked::HaveCoin(const COutPoint &outpoint) const { return base->HaveCoin(outpoint); }
uint256 CCoinsViewBacked::GetBestBlock() const { return base->GetBestBlock(); }
std::vector<uint256> CCoinsViewBacked::GetHeadBlocks() const { return base->GetHeadBlocks(); }
void CCoinsViewBacked::SetBackend(CCoinsView &viewIn) { base = &viewIn; }
bool CCoinsViewBacked::BatchWrite(CCoinsMap &mapCoins, const uint256 &hashBlock) { return base->BatchWrite(mapCoins, hashBlock); }
CCoinsViewCursor *CCoinsViewBacked::Cursor() const { return base->Cursor(); }
size_t CCoinsViewBacked::EstimateSize() const { return base->EstimateSize(); }


end.
