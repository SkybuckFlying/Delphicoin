// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2020-2020 Skybuck Flying
// Copyright (c) 2020-2020 The Delphicoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

unit Unit_SerializeTransaction;

interface

implementation

template<typename Stream, typename TxType>
inline void SerializeTransaction(const TxType& tx, Stream& s) {
    const bool fAllowWitness = !(s.GetVersion() & SERIALIZE_TRANSACTION_NO_WITNESS);

    s << tx.nVersion;
    unsigned char flags = 0;
    // Consistency check
    if (fAllowWitness) {
        /* Check whether witnesses need to be serialized. */
        if (tx.HasWitness()) {
            flags |= 1;
        }
	}
	if (flags) {
		/* Use extended format in case witnesses are to be serialized. */
		std::vector<CTxIn> vinDummy;
		s << vinDummy;
		s << flags;
	}
	s << tx.vin;
	s << tx.vout;
	if (flags & 1) {
		for (size_t i = 0; i < tx.vin.size(); i++) {
			s << tx.vin[i].scriptWitness.stack;
		}
	}
	s << tx.nLockTime;
}


end.
