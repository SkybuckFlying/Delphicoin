// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

// Bitcoin file: src/primitives/block.h
// Bitcoin file: src/primitives/block.cpp
// Bitcoin commit hash: f656165e9c0d09e654efabd56e6581638e35c26c

unit Unit_TBlockLocator;

interface

type
	// /** Describes a place in the block chain to another node such that if the
	// * other node doesn't have the same branch, it can find a recent common trunk.
	// * The further back it is, the further before the fork it may be.
	// */
	TBlockLocator = record
		std::vector<uint256> vHave;

		constructor Create;

		constructor Create(const std::vector<uint256>& vHaveIn) : vHave(vHaveIn) {}

		SERIALIZE_METHODS(CBlockLocator, obj)
		{
			int nVersion = s.GetVersion();
			if (!(s.GetType() & SER_GETHASH))
				READWRITE(nVersion);
			READWRITE(obj.vHave);
		}

		procedure SetNull();

		function IsNull() : boolean;
	end;


implementation

constructor TBlockLocator.Create;
begin

end;

constructor TBlockLocator(const std::vector<uint256>& vHaveIn) : vHave(vHaveIn)
begin

end;

SERIALIZE_METHODS(CBlockLocator, obj)
{
	int nVersion = s.GetVersion();
	if (!(s.GetType() & SER_GETHASH))
		READWRITE(nVersion);
	READWRITE(obj.vHave);
}

procedure TBlockLocator.SetNull();
begin
	vHave.clear();
end;

function TBlockLocator.IsNull() : boolean;
begin
	result := vHave.empty();
end;


end.
