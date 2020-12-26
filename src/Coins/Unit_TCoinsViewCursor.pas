// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TCoinsViewCursor;

interface

/** Cursor for iterating over CoinsView state */
class CCoinsViewCursor
{
public:
	CCoinsViewCursor(const uint256 &hashBlockIn): hashBlock(hashBlockIn) {}
	virtual ~CCoinsViewCursor() {}

	virtual bool GetKey(COutPoint &key) const = 0;
	virtual bool GetValue(Coin &coin) const = 0;
	virtual unsigned int GetValueSize() const = 0;

	virtual bool Valid() const = 0;
	virtual void Next() = 0;

	//! Get best block at the time this cursor was created
	const uint256 &GetBestBlock() const { return hashBlock; }
private:
	uint256 hashBlock;
};


implementation

CCoinsViewCursor *CCoinsView::Cursor() const { return nullptr; }


end.
