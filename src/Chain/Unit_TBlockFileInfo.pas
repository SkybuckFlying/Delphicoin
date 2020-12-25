// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TBlockFileInfo;

interface

type
	TBlockFileInfo = class
	public
		nBlocks: Cardinal;       //!< number of blocks stored in file
		nSize: Cardinal;         //!< number of used bytes of block file
		nUndoSize: Cardinal;     //!< number of used bytes in the undo file
		nHeightFirst: Cardinal;  //!< lowest height of block in file
		nHeightLast: Cardinal;   //!< highest height of block in file
		nTimeFirst: uint64;        //!< earliest time of block in file
		nTimeLast: uint64;         //!< latest time of block in file

		constructor Create;

		procedure SetNull;

		// Skybuck not sure what this is:
//		procedure SERIALIZE_METHODS(CBlockFileInfo, obj);

		procedure AddBlock( nHeightIn : cardinal; nTimeIn : uint64);

//		function ToString() : string; override; // Skybuck: since implementation is missing keeping Tobject.ToString by disabling this.
	end;


implementation

constructor TBlockFileInfo.Create;
begin
	SetNull();
end;

procedure TBlockFileInfo.SetNull;
begin
	 nBlocks := 0;
	 nSize := 0;
	 nUndoSize := 0;
	 nHeightFirst := 0;
	 nHeightLast := 0;
	 nTimeFirst := 0;
	 nTimeLast := 0;
end;


// Skybuck not sure what this is leaving it untouched for now :)
(*

	SERIALIZE_METHODS(CBlockFileInfo, obj)
	{
		READWRITE(VARINT(obj.nBlocks));
		READWRITE(VARINT(obj.nSize));
		READWRITE(VARINT(obj.nUndoSize));
		READWRITE(VARINT(obj.nHeightFirst));
		READWRITE(VARINT(obj.nHeightLast));
		READWRITE(VARINT(obj.nTimeFirst));
		READWRITE(VARINT(obj.nTimeLast));
	}

*)

{** update statistics (does not update nSize) *}
procedure TBlockFileInfo.AddBlock( nHeightIn : cardinal; nTimeIn : uint64);
begin
	 if (nBlocks=0) or (nHeightFirst > nHeightIn) then
		nHeightFirst := nHeightIn;
	 if (nBlocks=0) or (nTimeFirst > nTimeIn) then
		nTimeFirst := nTimeIn;
	 Inc(nBlocks);
	 if (nHeightIn > nHeightLast) then
		nHeightLast := nHeightIn;
	 if (nTimeIn > nTimeLast) then
		nTimeLast := nTimeIn;
end;

{
function TBlockFileInfo.ToString() : string;
begin
	// Skybuck: implementation missing ? or automated ?
end;
}


end.
