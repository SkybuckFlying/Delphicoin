// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TDiskBlockIndex;

interface

type
	{** Used to marshal pointers into hashes for db storage. *}
	TDiskBlockIndex = class(TBlockIndex)
	public:
		uint256 hashPrev;

		CDiskBlockIndex() {
			hashPrev = uint256();
		}

		explicit CDiskBlockIndex(const CBlockIndex* pindex) : CBlockIndex(*pindex) {
			hashPrev = (pprev ? pprev->GetBlockHash() : uint256());
		}

		SERIALIZE_METHODS(CDiskBlockIndex, obj)
		{
			int _nVersion = s.GetVersion();
			if (!(s.GetType() & SER_GETHASH)) READWRITE(VARINT_MODE(_nVersion, VarIntMode::NONNEGATIVE_SIGNED));

			READWRITE(VARINT_MODE(obj.nHeight, VarIntMode::NONNEGATIVE_SIGNED));
			READWRITE(VARINT(obj.nStatus));
			READWRITE(VARINT(obj.nTx));
			if (obj.nStatus & (BLOCK_HAVE_DATA | BLOCK_HAVE_UNDO)) READWRITE(VARINT_MODE(obj.nFile, VarIntMode::NONNEGATIVE_SIGNED));
			if (obj.nStatus & BLOCK_HAVE_DATA) READWRITE(VARINT(obj.nDataPos));
			if (obj.nStatus & BLOCK_HAVE_UNDO) READWRITE(VARINT(obj.nUndoPos));

			// block header
			READWRITE(obj.nVersion);
			READWRITE(obj.hashPrev);
			READWRITE(obj.hashMerkleRoot);
			READWRITE(obj.nTime);
			READWRITE(obj.nBits);
			READWRITE(obj.nNonce);
		}

		uint256 GetBlockHash() const
		{
			CBlockHeader block;
			block.nVersion        = nVersion;
			block.hashPrevBlock   = hashPrev;
			block.hashMerkleRoot  = hashMerkleRoot;
			block.nTime           = nTime;
			block.nBits           = nBits;
			block.nNonce          = nNonce;
			return block.GetHash();
		}

		std::string ToString() const
		{
			std::string str = "CDiskBlockIndex(";
			str += CBlockIndex::ToString();
			str += strprintf("\n                hashBlock=%s, hashPrev=%s)",
				GetBlockHash().ToString(),
				hashPrev.ToString());
			return str;
		}
	};

implementation

end.
