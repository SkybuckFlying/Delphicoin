// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/chain.h
// Bitcoin file: src/chain.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c


unit Unit_TBlockStatus;

interface

type
	TBlockStatus : longword =
	(
		//! Unused.
		BLOCK_VALID_UNKNOWN      =    0,

		//! Reserved (was BLOCK_VALID_HEADER).
		BLOCK_VALID_RESERVED     =    1,

		//! All parent headers found, difficulty matches, timestamp >= median previous, checkpoint. Implies all parents
		//! are also at least TREE.
		BLOCK_VALID_TREE         =    2,

		// /**
		// * Only first tx is coinbase, 2 <= coinbase input script length <= 100, transactions valid, no duplicate txids,
		// * sigops, size, merkle root. Implies all parents are at least TREE but not necessarily TRANSACTIONS. When all
		// * parent blocks also have TRANSACTIONS, CBlockIndex::nChainTx will be set.
		// */
		BLOCK_VALID_TRANSACTIONS =    3,

		//! Outputs do not overspend inputs, no double spends, coinbase output ok, no immature coinbase spends, BIP30.
		//! Implies all parents are also at least CHAIN.
		BLOCK_VALID_CHAIN        =    4,

		//! Scripts & signatures ok. Implies all parents are also at least SCRIPTS.
		BLOCK_VALID_SCRIPTS      =    5,

		//! All validity bits.
		BLOCK_VALID_MASK         =   BLOCK_VALID_RESERVED | BLOCK_VALID_TREE | BLOCK_VALID_TRANSACTIONS |
								 BLOCK_VALID_CHAIN | BLOCK_VALID_SCRIPTS,

		BLOCK_HAVE_DATA          =    8, //!< full block available in blk*.dat
		BLOCK_HAVE_UNDO          =   16, //!< undo data available in rev*.dat
		BLOCK_HAVE_MASK          =   BLOCK_HAVE_DATA | BLOCK_HAVE_UNDO,

		BLOCK_FAILED_VALID       =   32, //!< stage after last reached validness failed
		BLOCK_FAILED_CHILD       =   64, //!< descends from failed block
		BLOCK_FAILED_MASK        =   BLOCK_FAILED_VALID | BLOCK_FAILED_CHILD,

		BLOCK_OPT_WITNESS       =   128, //!< block data in blk*.data was received with a witness-enforcing client
	};

implementation

end.
