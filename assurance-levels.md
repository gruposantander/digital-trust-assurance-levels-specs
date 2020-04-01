%%%
title = "Assurance Levels"
abbrev = "assurance-levels"
ipr = "none"
area = "Identity"
workgroup = "connect"
keyword = ["security", "openid", "authorization", "trust"]

date = 2020-03-30T10:40:28Z

[seriesInfo]
name = "Internet-Draft"
value = "assurance-levels-00"
status = "standard"

[[author]]
initials="A."
surname="Pulido"
fullname="Alberto Pulido Moyano"
organization="Santander"
 [author.address]
 email = "alberto.pulido@santander.co.uk"

[[author]]
initials="V."
surname="Herraiz, Ed."
fullname="Victor Herraiz Posada"
organization="Santander"
 [author.address]
 email = "victor.herraiz@santander.co.uk"

[[author]]
initials="J."
surname="Oliva"
fullname="Jorge Oliva Fernandez"
organization="Santander"
 [author.address]
 email = "Jorge.OlivaFernandez@santander.co.uk"

%%%

.# Abstract

This specification defines a new member attribute that allows requesting assurance levels over existing claims, and another claim that allows sending the verification details for each of the claims verified and matching the requested level of assurance.

{mainmatter}

# Introduction {#Introduction}

Within current OpenID Connect specification [@!OIDC], when returning claims to the RP, with the exception of email and telephone, there is no a way to declare and differentiate those claims that have been validated by the OP following their current customer due diligence or onboarding processes.

That is the concept around level of assurance, which has associated some degree of liability based on contractual conditions of the service and the relevant legislation the OP is attached too. For instance, banks currently perform KYC and AML checks as part of onboarding process. In that case, some of the claims provided by the bank, could be tight to a particular level of assurance and trust framework.

We believe that in the majority of situations, the level of assurance will be enough, and it will not be even necessary to disclose any other attribute or evidence document back to the RP.

With this extension proposal, requested claims by the RP can refer to a desired level of assurance. If the OP can meet that level for the claim, and the user consents to share, the data will be included in the response, otherwise the claim will not be returned.

## Notational conventions

The key words "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "MAY", and "CAN" in this document are to be interpreted as described in "Key words for use in RFCs to Indicate Requirement Levels" [@!RFC2119]. These key words are not used as dictionary terms such that any occurrence of them shall be interpreted as key words and are not to be interpreted with their natural language meanings.

## Terminology

This specification uses the terms "Claim", "Claim Type", "Claims Provider","ID Token", "OpenID Provider (OP)", "Relying Party (RP)", and "UserInfo Endpoint" defined by OpenID Connect [@!OIDC]

# Request

This specification defines a generic mechanism to request assurance level over claims using the new OPTIONAL element `ial`. This new element will be used inside any of the claims elements within `id_token` or `userinfo`, as specified in section 5.5 of [@!OIDC]. It will contain one of the values of level of assurances defined by the OP.

Any other member already supported by OpenID specifications remains valid, including members are defined for every claim:

Here is a non normative example:

```json
{
"id_token": {
    "given_name": {
      "purpose": "This is why the RP requires your name",
      "essential": true,
      "ial": "2"
    }
}
```

Values for the `ial` member not supported by the OP SHOULD be ignored.

Every claim MAY have a identity assurance level based on the level of OP verification of the actual data provided in the given claim. The IAL of the actual data at the OP MUST be equal or greater that the IAL in the request if the OP cannot provide the level of assurance the claim will not be returned.

The values and meaning for the IALs supported by the OP MAY represent the legal framework the OP operates in, or at least the adherance to standard ways to attest the validity of the data eing returned. Here is an example for IAL values with similiraty to some standards such as NIST or eIDAS:

- "1": There is no requirement to link the applicant to a specific real-life identity. Any attributes provided in conjunction with the subject’s activities are self-asserted or should be treated as self-asserted. Self-asserted attributes are neither validated nor verified.
- "2": Evidence supports the real-world existence of the claimed identity and verifies that the applicant is appropriately associated with this real-world identity. IAL2 introduces the need for either remote or physically-present identity proofing.
- "3": Physical presence is required for identity proofing. Identifying attributes must be verified by an authorized and trained representatives.

# Response

The request will return as a result the claims that matches the assurance levels (IALs) requested by the RP.

Implementers MUST return an object for each claim inside `ials_claims` element with the following fields:

* `level` REQUIRED. This is the level of assurance provided by the OP, it MUST be equal than the level requested.
* `assurer` OPTIONAL. The id and name of the assurer (the entity assuring the data level). This id must be unique.
* `issuer` OPTIONAL. The id and name of the issuer (the trusted entity source of the data, in a format of a document or any other valid digital representation). This id must be unique.

  
The following is a non normative example of the response:

```json
{
    "given_name": "Joe",
    "address": {
        "street_address": "1234 Hollywood Blvd.",
        "locality": "Los Angeles",
        "region": "CA",
        "postal_code": "90210",
        "country": "US"
    },
    "claim_ials": {
        "given_name": {
            "level": "2",
            "assurer": {
              "id": "SANUK",
              "name": "Santander UK PLC"
            },
            "issuer": {
              "id": "UKGOV",
              "name": "UK Government"
            }
        },
        "address": {
            "level": "2",
            "assurer": {
              "id": "SANUK",
              "name": "Santander UK PLC"
            },
            "issuer": {
              "id": "UKDVLA",
              "name": "UK DVLA"
            }
        }
    }
}
```

{backmatter}


<reference anchor="RFC2119" target="https://tools.ietf.org/html/rfc2119">
  <front>
    <title>Key words for use in RFCs to Indicate Requirement Levels</title>
    <author initials="S." surname="Bradner" fullname="Scott Bradner">
      <organization>Harvard University</organization>
    </author>
   <date month="March" year="1997"/>
  </front>
</reference>

<reference anchor="OIDC" target="http://openid.net/specs/openid-connect-core-1_0.html">
  <front>
    <title>OpenID Connect Core 1.0 incorporating errata set 1</title>
    <author initials="N." surname="Sakimura" fullname="Nat Sakimura">
      <organization>NRI</organization>
    </author>
    <author initials="J." surname="Bradley" fullname="John Bradley">
      <organization>Ping Identity</organization>
    </author>
    <author initials="M." surname="Jones" fullname="Mike Jones">
      <organization>Microsoft</organization>
    </author>
    <author initials="B." surname="de Medeiros" fullname="Breno de Medeiros">
      <organization>Google</organization>
    </author>
    <author initials="C." surname="Mortimore" fullname="Chuck Mortimore">
      <organization>Salesforce</organization>
    </author>
   <date day="8" month="Nov" year="2014"/>
  </front>
</reference>

<reference anchor="OIDC.Discovery" target="https://openid.net/specs/openid-connect-discovery-1_0.html">
  <front>
    <title>OpenID Connect Discovery 1.0 incorporating errata set 1</title>
    <author initials="N." surname="Sakimura" fullname="Nat Sakimura">
      <organization>NRI</organization>
    </author>
    <author initials="J." surname="Bradley" fullname="John Bradley">
      <organization>Ping Identity</organization>
    </author>
    <author initials="M." surname="Jones" fullname="Mike Jones">
      <organization>Microsoft</organization>
    </author>
    <author initials="E." surname="Jay" fullname="Edmund Jay">
      <organization>Illumila</organization>
    </author>
   <date day="8" month="Nov" year="2014"/>
  </front>
</reference>

# OP Metadata {#op-metadata}

The OP SHOULD advertise their capabilities with respect to assertion claims in their `openid-configuration` (see [@!OIDC.Discovery]) using the following new elements:

* `ials_claims_supported`: Boolean value indicating support of level of assurance claims.
* `ials_definition_supported`: List of supported IALs by the OP
* `claims_in_ials_supported`: List of claims supported by any of the available IALs.

Non normative example:

```json
{
  "ials_claims_supported": true,
  "ials_definition_supported": {
    "1": {
      "description" : "There is no requirement to link the applicant to a specific real-life identity. Any attributes provided in conjunction with the subject’s activities are self-asserted or should be treated as self-asserted. Self-asserted attributes are neither validated nor verified.",
      "reference_trust_framework" : "NIST.800-63A",
      "assurer-id" : "SANUK",
      "assurer-name" : "Santander UK PLC"
    },
    "2": {
      "description" : "Evidence supports the real-world existence of the claimed identity and verifies that the applicant is appropriately associated with this real-world identity. IAL2 introduces the need for either remote or physically-present identity proofing.",
      "reference_trust_framework" : "NIST.800-63A",
      "assurer-id" : "SANUK",
      "assurer-name" : "Santander UK PLC"
    },
    "3": {
      "description" : "Physical presence is required for identity proofing. Identifying attributes must be verified by an authorized and trained representatives.",
      "reference_trust_framework" : "NIST.800-63A",
      "assurer-id" : "UKGOV",
      "assurer-name" : "UK Government"
    }
  },
  "claims_in_ials_supported": {
    "2": [
      "address", "phone_number", "email"
    ],
    "3": [
      "birthdate", "gender", "nationality"
    ]
}

```

# IANA Considerations

To be done.

# Notices

Copyright (c) 2020 Grupo Santander

We intent to release this specification under MIT license, pending internal process.
