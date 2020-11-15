%%%
title = "Assurance Levels"
abbrev = "assurance-levels"
ipr = "none"
area = "Identity"
workgroup = "connect"
keyword = ["security", "openid", "authorization", "trust"]

date = 2020-04-03T11:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "assurance-levels-00"
status = "standard"

[[author]]
initials="A."
surname="Pulido"
fullname="Alberto Pulido Moyano, Ed."
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

This specification defines a new member attribute that allows the process of requesting a minimum assurance level in relation to an existing claim. In the response to this request, the OP SHOULD provide extended information about the assurer and the resolved level.

{mainmatter}

# Introduction {#Introduction}

Within the current OpenID Connect specification [@!OIDC], when returning claims to the RP - with the exception of email and telephone - there is no a way to declare and differentiate the claims that have been validated by the OP as part of their current customer due diligence or onboarding processes.

The concept around level of assurance, which has an associated degree of liability based on contractual conditions of the service and the relevant legislation for the OP, is attached too. For instance, banks currently perform KYC and AML checks as part of the onboarding process. In this case, some of the claims provided by the bank could be tied to a particular level of assurance or trust framework.

With this extension proposal, requested claims by the RP can refer to a desired level of assurance. If the OP can meet that level for the claim, and the user consents to share the relevant information, the data will be included in the response. If this level of assurance cannot be met, the claim will not be returned.

## Notational conventions

The key words "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "MAY", and "CAN" in this document are to be interpreted as described in "Key words for use in RFCs to Indicate Requirement Levels" [@!RFC2119]. These key words are not used as dictionary terms such that any occurrence of them shall be interpreted as key words and are not to be interpreted with their natural language meanings.

## Terminology

This specification uses the terms "Claim", "Claim Type", "Claims Provider","ID Token", "OpenID Provider (OP)", "Relying Party (RP)", and "UserInfo Endpoint" defined by OpenID Connect [@!OIDC]

Other terms:

* IAL: Identity Assurance Level
* Assurer: Entity responsible for the verification of the level of assurance for a specific claim.

# Request

This specification defines a generic mechanism to request an assurance level over claims using the new OPTIONAL member `ial`. This new member will be used as part of the claims elements within `id_token` or `userinfo`, as specified in section 5.5 of [@!OIDC]. It will contain one of the values of the level of assurance as defined by the OP.

Any other member already supported by OpenID specifications remains valid, including members that are defined for every claim.

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

IAL values are specified by the OP as an ordered enumeration and represented as `string` values. Therefore, the comparator operations are defined and every verification level contains the previous one excluding the first level.

Claim requests with an invalid `ial` member SHOULD not be included in the response. Returning the claim in this case could be misleading.

Every claim MAY have a identity assurance level based on the level of OP verification of the actual data provided in the given claim. The IAL of the actual data at the OP MUST be equal to or greater than the IAL in the request. If the OP cannot provide the level of assurance that has been requested, the claim will not be returned.

The values and meaning for the IALs supported by the OP MAY represent the legal framework the OP operates in, or at least the adherence to standard ways to attest the validity of the data being returned. Here is an example for the IAL values with similarity to some standards such as NIST or eIDAS:

* "1": There is no requirement to link the applicant to a specific real-life identity. Any attributes provided in conjunction with the subject’s activities are self-asserted or should be treated as self-asserted. Self-asserted attributes are neither validated nor verified.
* "2": Evidence supports the real-world existence of the claimed identity and verifies that the applicant is appropriately associated with this real-world identity. IAL2 introduces the need for either remote or physically-present identity proofing.
* "3": Physical presence is required for identity proofing. Identifying attributes must be verified by authorized and trained representatives.

# Response

The request will return the resulting claims that match the assurance levels (IALs) requested by the RP.

Implementers SHOULD return an object for each claim inside the `ial_claims` element with the following fields:

* `level` REQUIRED. This is the level of assurance provided by the OP - it MUST be equal to the level requested.
* `assurer` OPTIONAL. The `id` and `name` of the assurer (the entity assuring the data level). This id MUST be unique.

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
    "ial_claims": {
        "given_name": {
            "level": "2",
            "assurer": {
              "id": "SANUK",
              "name": "Santander UK PLC"
            }
        },
        "address": {
            "level": "2",
            "assurer": {
              "id": "SANUK",
              "name": "Santander UK PLC"
            }
        }
    }
}
```

# OP Metadata {#op-metadata}

The OP SHOULD advertise their capabilities with respect to the assertion claims in their `openid-configuration` (see [@!OIDC.Discovery]) using the following new elements:

* `ial_claims_supported`: Boolean value indicating the support of any level of assurance claims.
* `ials_definition_supported`: List of supported IALs by the OP

Non normative example:

```json
{
  "ial_claims_supported": true,
  "ials_definition_supported": {
    "1": {
      "description" : "There is no requirement to link the applicant to a specific real-life identity. Any attributes provided in conjunction with the subject’s activities are self-asserted or should be treated as self-asserted. Self-asserted attributes are neither validated nor verified.",
      "reference_trust_framework" : "NIST.800-63A"
    },
    "2": {
      "description" : "Evidence supports the real-world existence of the claimed identity and verifies that the applicant is appropriately associated with this real-world identity. IAL2 introduces the need for either remote or physically-present identity proofing.",
      "reference_trust_framework" : "NIST.800-63A"
    },
    "3": {
      "description" : "Physical presence is required for identity proofing. Identifying attributes must be verified by an authorized and trained representatives.",
      "reference_trust_framework" : "NIST.800-63A"
    }
  }
}

```

# IANA Considerations

To be done.


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

# Notices

MIT License

Copyright (c) 2020 Grupo Santander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
