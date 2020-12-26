// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_TTxIn;

interface

{** An input of a transaction.  It contains the location of the previous
 * transaction's output that it claims and a signature that matches the
 * output's public key.
 *}
class CTxIn
{
public:
    COutPoint prevout;
    CScript scriptSig;
    uint32_t nSequence;
    CScriptWitness scriptWitness; //!< Only serialized through CTransaction

    /* Setting nSequence to this value for every input in a transaction
     * disables nLockTime. */
    static const uint32_t SEQUENCE_FINAL = 0xffffffff;

    /* Below flags apply in the context of BIP 68*/
    /* If this flag set, CTxIn::nSequence is NOT interpreted as a
     * relative lock-time. */
    static const uint32_t SEQUENCE_LOCKTIME_DISABLE_FLAG = (1U << 31);

    /* If CTxIn::nSequence encodes a relative lock-time and this flag
     * is set, the relative lock-time has units of 512 seconds,
     * otherwise it specifies blocks with a granularity of 1. */
    static const uint32_t SEQUENCE_LOCKTIME_TYPE_FLAG = (1 << 22);

    /* If CTxIn::nSequence encodes a relative lock-time, this mask is
     * applied to extract that lock-time from the sequence field. */
    static const uint32_t SEQUENCE_LOCKTIME_MASK = 0x0000ffff;

    /* In order to use the same number of bits to encode roughly the
     * same wall-clock duration, and because blocks are naturally
     * limited to occur every 600s on average, the minimum granularity
	 * for time-based relative lock-time is fixed at 512 seconds.
     * Converting from CTxIn::nSequence to seconds is performed by
     * multiplying by 512 = 2^9, or equivalently shifting up by
	 * 9 bits. */
    static const int SEQUENCE_LOCKTIME_GRANULARITY = 9;

	CTxIn()
	{
		nSequence = SEQUENCE_FINAL;
	}

	explicit CTxIn(COutPoint prevoutIn, CScript scriptSigIn=CScript(), uint32_t nSequenceIn=SEQUENCE_FINAL);
	CTxIn(uint256 hashPrevTx, uint32_t nOut, CScript scriptSigIn=CScript(), uint32_t nSequenceIn=SEQUENCE_FINAL);

	SERIALIZE_METHODS(CTxIn, obj) { READWRITE(obj.prevout, obj.scriptSig, obj.nSequence); }

	friend bool operator==(const CTxIn& a, const CTxIn& b)
	{
		return (a.prevout   == b.prevout &&
				a.scriptSig == b.scriptSig &&
				a.nSequence == b.nSequence);
	}

	friend bool operator!=(const CTxIn& a, const CTxIn& b)
	{
		return !(a == b);
	}

	std::string ToString() const;
};


implementation

CTxIn::CTxIn(COutPoint prevoutIn, CScript scriptSigIn, uint32_t nSequenceIn)
{
	prevout = prevoutIn;
	scriptSig = scriptSigIn;
	nSequence = nSequenceIn;
}

CTxIn::CTxIn(uint256 hashPrevTx, uint32_t nOut, CScript scriptSigIn, uint32_t nSequenceIn)
{
	prevout = COutPoint(hashPrevTx, nOut);
	scriptSig = scriptSigIn;
	nSequence = nSequenceIn;
}

std::string CTxIn::ToString() const
{
	std::string str;
	str += "CTxIn(";
	str += prevout.ToString();
	if (prevout.IsNull())
		str += strprintf(", coinbase %s", HexStr(scriptSig));
	else
		str += strprintf(", scriptSig=%s", HexStr(scriptSig).substr(0, 24));
	if (nSequence != SEQUENCE_FINAL)
		str += strprintf(", nSequence=%u", nSequence);
	str += ")";
	return str;
}


end.
