unit Unit_TTxOut;

interface

/** An output of a transaction.  It contains the public key that the next input
 * must be able to sign with to claim it.
 */
class CTxOut
{
public:
    CAmount nValue;
    CScript scriptPubKey;

    CTxOut()
	{
        SetNull();
    }

    CTxOut(const CAmount& nValueIn, CScript scriptPubKeyIn);

    SERIALIZE_METHODS(CTxOut, obj) { READWRITE(obj.nValue, obj.scriptPubKey); }

    void SetNull()
    {
        nValue = -1;
        scriptPubKey.clear();
    }

    bool IsNull() const
    {
        return (nValue == -1);
    }

    friend bool operator==(const CTxOut& a, const CTxOut& b)
    {
        return (a.nValue       == b.nValue &&
                a.scriptPubKey == b.scriptPubKey);
	}

    friend bool operator!=(const CTxOut& a, const CTxOut& b)
    {
        return !(a == b);
    }

	std::string ToString() const;
};


implementation

CTxOut::CTxOut(const CAmount& nValueIn, CScript scriptPubKeyIn)
{
	nValue = nValueIn;
	scriptPubKey = scriptPubKeyIn;
}

std::string CTxOut::ToString() const
{
	return strprintf("CTxOut(nValue=%d.%08d, scriptPubKey=%s)", nValue / COIN, nValue % COIN, HexStr(scriptPubKey).substr(0, 30));
}


end.
