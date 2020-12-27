// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/primitives/transaction.h
// Bitcoin file: src/primitives/transaction.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

unit Unit_TGenTxid;

interface

/** A generic txid reference (txid or wtxid). */
class GenTxid
{
	bool m_is_wtxid;
	uint256 m_hash;
public:
	GenTxid(bool is_wtxid, const uint256& hash) : m_is_wtxid(is_wtxid), m_hash(hash) {}
	bool IsWtxid() const { return m_is_wtxid; }
	const uint256& GetHash() const { return m_hash; }
	friend bool operator==(const GenTxid& a, const GenTxid& b) { return a.m_is_wtxid == b.m_is_wtxid && a.m_hash == b.m_hash; }
	friend bool operator<(const GenTxid& a, const GenTxid& b) { return std::tie(a.m_is_wtxid, a.m_hash) < std::tie(b.m_is_wtxid, b.m_hash); }
};


implementation

end.
