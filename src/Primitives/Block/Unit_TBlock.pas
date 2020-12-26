unit Unit_TBlock;

interface

type
	TBlock = class(TBlockHeader)
	public:
		// network and disk
		std::vector<CTransactionRef> vtx;

		// memory only
		mutable bool fChecked;

//				std::string ToString() const;

		constructor TBlock.Create;

		constructor TBlock(const header: PBlockHeader);

		SERIALIZE_METHODS(CBlock, obj)

		procedure SetNull()
		function GetBlockHeader() : TBlockHeader;

	end;

implementation

constructor TBlock.Create;
begin
	SetNull();
end;

constructor TBlock(const header: PBlockHeader)
begin
	SetNull();

	TBlockHeader(inherited Self) := header;
end;

SERIALIZE_METHODS(CBlock, obj)
{
	READWRITEAS(CBlockHeader, obj);
	READWRITE(obj.vtx);
}

procedure TBlock.SetNull()
begin
	inherited Self.SetNull();

//	CBlockHeader::SetNull();
	vtx.clear();
	fChecked = false;
end;

function TBlock.GetBlockHeader() : TBlockHeader;
begin
	result.nVersion       := nVersion;
	result.hashPrevBlock  := hashPrevBlock;
	result.hashMerkleRoot := hashMerkleRoot;
	result.nTime          := nTime;
	result.nBits          := nBits;
	result.nNonce         := nNonce;
end;

std::string CBlock::ToString() const
{
	std::stringstream s;
	s << strprintf("CBlock(hash=%s, ver=0x%08x, hashPrevBlock=%s, hashMerkleRoot=%s, nTime=%u, nBits=%08x, nNonce=%u, vtx=%u)\n",
		GetHash().ToString(),
		nVersion,
		hashPrevBlock.ToString(),
		hashMerkleRoot.ToString(),
		nTime, nBits, nNonce,
		vtx.size());
	for (const auto& tx : vtx) {
		s << "  " << tx->ToString() << "\n";
	}
	return s.str();
}

end.