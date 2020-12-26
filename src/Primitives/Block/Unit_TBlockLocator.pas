unit Unit_TBlockLocator;

interface

type
	{** Describes a place in the block chain to another node such that if the
	 * other node doesn't have the same branch, it can find a recent common trunk.
	 * The further back it is, the further before the fork it may be.
	 *}
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
