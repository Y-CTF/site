+++
title = "FROSTies"
date = 2025-03-15
authors = ["cstef"]

categories = ["crypto"]
+++

We are able to eavesdrop on seamingly normal [FROST](#suggested-readings-and-references) rounds

### Round 1

```
Participant 1 sent to participant 2 : VerifiableSecretSharingCommitment([...])
Participant 1 sent to participant 3 : VerifiableSecretSharingCommitment([...])

Participant 2 sent to participant 1 : VerifiableSecretSharingCommitment([...])
Participant 2 sent to participant 3 : VerifiableSecretSharingCommitment([...])

Participant 3 sent to participant 1 : VerifiableSecretSharingCommitment([...])
Participant 3 sent to participant 2 : VerifiableSecretSharingCommitment([...])
```

Which corresponds to the usual commitment sharing phase for the generated $f_i (x) = a_0 + a_1 x + ... + a_(t-1) x^(t-1)$ polynomial, where $t$ is the signing threshold, $2$ in our case, so each user's secret polynomial looks like:

$$
f_i (x) = a_0 + a_1 x | i in cal(P)
$$

With $cal(P)$ the group of signers.

### Round 2

```
Participant 1 sent to participant 2 : 21d572096976faf3962d2af54b2c5a0bafdee5f081e558dfa6e5dec42830cbb5
Participant 1 sent to participant 3 : bcf8cf26d4b4b79db158486c4ee673f3172a878c44582e0b3006f41d77af65fa

Participant 2 sent to participant 1 : e71ea9ddb484788e62b797d559083d759a2eab1112109022132d1319c4bc61bb
Participant 2 sent to participant 3 : 5284cc5c6a2a9f69adc975aba6293b7e4e69e38b740d0db0df3a5417c7a6d524

Participant 3 sent to participant 1 : 48badb74cda77ef986b4b788259c3624dd53da51bf5b5e3a0365a641d1260016
Participant 3 sent to participant 2 : 5ebd8b0b13a9793e70efe19e47cb3d4f98b0287f315c6c75e8cc9a21143de2c9
```

These are seemingly the signing shares being sent to each other. This was confirmed by taking a look at the actual code:

```rs
println!(
    "Participant {} sent to participant {} : {}\n", 
    index1+1, 
    index2+1, 
    hex::encode(
        round2_package
            .signing_share()
            .to_scalar()
            .to_bytes()
    )
);
```

The signing shares are basically just $f_i (ell) | i,ell in cal(P)$ being sent to signer $ell$. These exchanges can be represented with the following exchange matrix:

$$
mat(
    f_1 (1), f_1 (2), f_1 (3);
    f_2 (1), f_2 (2), f_2 (3);
    f_3 (1), f_3 (2) ,f_3 (3),
)
$$

Even though we are only able to intercept two of the three shares, we can still interpolate each $f_i (x)$ because the threshold is $2$. Lagrange may be a bit overkill since we only have two coefficients, but whatever.

$$
f_i (x) = sum_(ell in cal(P)) f_i (ell) dot product_(j in cal(P), j != ell) (x - j)/(ell - j)
$$

Now, since the group's signing key $p$ is just the sum of all $f_i (0)$, we can just remove the $x$ from the equation and get the sum of all shares for each participant.

$$
p &= sum_(i in cal(P)) sum_(ell in cal(P)) f_i (ell) dot product_(j in cal(P), j != ell) j/(ell - j) \
  &= sum_(i in cal(P)) f_i (0) 
$$

### Actually solving the challenge

```rust
use frost_core::compute_lagrange_coefficient;
use frost_secp256k1::{, Ide, Identifier, SigningKey
    self, 
    Identifier, 
    SigningKey, 
    rand_core::OsRng, 
    round2::SignatureShare
};

use std::collections::BTreeSet;

fn str_to_scalar(s: &str) -> k256::Scalar {
    SignatureShare::deserialize(&hex::decode(s).unwrap())
        .unwrap()
        .share()
        .0
}

fn main() {
    let ids: Vec<Identifier> = (1..=3)
        .map(|i| Identifier::new(k256::Scalar::from(i as u64)).unwrap())
        .collect();

    let shares = [
        // (from, to, share)
        (0, 1, "..."),
        (0, 2, "..."),
        (1, 0, "..."),
        (1, 2, "..."),
        (2, 0, "..."),
        (2, 1, "..."),
    ]
    .map(|(from, to, share)| (from, to, str_to_scalar(share)));

    let mut secret = k256::Scalar::ZERO;

    for participant in 0..3 {
        // sent for current participant
        let participant_shares: Vec<_> = shares
            .iter()
            .filter(|(from, _, _)| *from == participant)
            .map(|(_, to, share)| (ids[*to].clone(), *share))
            .collect();

        let points: BTreeSet<_> = participant_shares
            .iter()
            .map(|(id, _)| id.clone())
            .collect();

        // interpolate for f_i(0)
        let mut participant_secret = k256::Scalar::ZERO;
        for (id, share) in participant_shares {
            let lagrange = 
                compute_lagrange_coefficient(&points, None, id).unwrap();
            participant_secret += lagrange * share;
        }

        secret += participant_secret;
    }

    let key = SigningKey::from_scalar(secret).unwrap();
    let signed = key.sign(&mut OsRng, b"Give me the flag");
    println!("{}", hex::encode(signed.serialize().unwrap()));
}
```

## Suggested Readings and References

- **FROST: Flexible Round-Optimized Schnorr Threshold Signatures**  
    Chelsea Komlo  
    [eprint.iacr.org](https://eprint.iacr.org/2020/852.pdf?ref=glossary.blockstream.com) (PDF)

- **Using ECC for (Multi-)Signatures**  
    cstef  
    [blog.cstef.dev](https://blog.cstef.dev/posts/multi-sig)