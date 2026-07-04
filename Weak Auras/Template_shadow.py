"""
Template_shadow.py - static, versioned captures of the "Template_shadow"
in-game WeakAuras scaffold.

WHAT THIS IS
------------
`Template_shadow` is Battlewrath's own in-game positional mask for the
HUD_DESIGN.md five-tier model - a real WeakAuras group (character
Weakauratest / Area 52 - Free-Pick) used to work out scale and position
together by testing live, rather than guessing from docs alone.

Each captured version is a real WeakAuras import string, decodable with
`weakaura_codec.py`'s `decode_group_import_string()` - that's the source
of truth. Positions from v0.4 onward are computed with `geometry.py`
rather than hand-derived per revision - see AURA_BLUEPRINT.md's
"Positional geometry model" section for the method.

USAGE
-----
    import weakaura_codec as wa
    import Template_shadow as ts

    group, children = wa.decode_group_import_string(
        ts.TEMPLATE_SHADOW_V0_IMPORT_STRING
    )
"""

# ============================================================================
# v0 - baseline capture (2026-07-02, Area 52 - Free-Pick, character
# Weakauratest). Exactly as exported from the live client, before any
# agent edits. Group id: "Template_shadow", 24 children, all icons
# uniform 25x25, Health+Mana as two separate bars, Tier 3/4 only 2 slots
# each, zero gap between all icons.
# ============================================================================

TEMPLATE_SHADOW_V0_IMPORT_STRING = (
    "!WA:2!TR1wWTr1zyROYLQotghhCGK6cMabCsHqSKVLqdyT2Yw2rwYSs(ssdiTs7rA3ePDxV7kllxkx"
    "CBdHYTG5szygOPUxG2MaubpK2PLjJlthEHz(XdtBFOqBnuOLx600zA7mTu6)5SRKSDSJtSJPtirpiV"
    "7z3ZUNZ57Y)Nojo6VkJcnUv31Vv31YrmfQktvIvjEWRAQ4cj2VOUQwBQPv172PtN96CBBTXPJRQls0"
    "5SVOwLCPLhDubDXAJOQM2uwBct1edt0nKvvU0H37ucznLu1dPzINB4AsREhkzsdI5NnU1zsty9xFIP"
    "iARj8qzf0j12r20PRDajztYe6KuyNJKxJWNsxnRM9ThwEuYfPvPHeE7IDOlKHeGmmjDScwx2Ay7WHd"
    "N8gjestCQN3616)4()xdTLv)RpUUqc2OQjEdtbDtxCYkYMUINe)JHKRXm1LtLcNiB460Tp8atisINn"
    "zs6qr3VVa92rFb4mPJlHS6cUhZqJKoDxIgUM2iBCCSOyggVB5rkeTnVHJenCeV8r4YIVK4APfYt05v"
    "WbTHlE2Tg3priTPuPU2Rob7kF4E9fiW4zvShcUkiOKaxq7vvg7sB(cgXh)jWdj6kcP73Az)O6JyptB"
    "D7RFTvmO(VFCbf5mc0jBtWA7a2aNIQczsIGbjSPorjLP0LmLiofO3ru6es3GKqvr0ym69qNUWnWLrq"
    "wb7lCdWnEjWwHBc2gEy1ZTLnklEIiKm4e0KefXgr1CJBqsNKnGH6kKKcu4BvWuW5jSMlmSJ(sIhUnE"
    "F(c6oRSyHE6Qoj5(hiB)jgjoouskNYfVqAnjbNtGRq8mkHHRcYkjv1TMAUMGoKLTiACPvfeBIdrKeR"
    "JptwKy6IprAbdJ1bT6IZaPo0dSPkDPGlwoRkXHVId2YegAc67FazrtPQNKDS1A5GoGlgx8f3xwdtIy"
    "pcJSQYNiRSkyn(po5yV2tS7h)bHRhQBkwp5vnzJmhARzwN3JQiHZBFrcbBX)Xh83923)QoWGCY4Oxc"
    "w3QVo4Y)vtN1GU4PMZBCdv94XW14Rc(cWvYAxG1g9zed2iCn4vQv7Yk2HUusOMrwjfLmfdQXfCTWMg"
    "JErkTlgC1UGRawpCDU0wdL8pmjIfTI(0osftqhdrtuuV7e28rNwtxnLoXWiSAw9eKTutfRc8a1Xzsg"
    "XuAS4cfLzoD4efhgcMuwerAMRC72bCZDVoydtH4g1tHQHveTBarpIvdh8Y1UA6tnk7llunQwut5mKO"
    "A6KeYuQTZXlDlBCtO5d7mlwwz9(0wTwI01T2AzTGwrQuQscg6Y5fp9ewVm5riISgV3PSOK72AO7ys2"
    "1PWSCY8qDWg0XXmTnTRDHgRPjPesKpAY0QQOZg7gkVIoUDhum1QSdD5rR92Ykis1c1gjI2MxOhPyE0"
    "OqorutjejKutlMxRQzmZThS1uH1ODyCLkEAsSPyNLdz4dOlOn2a2hmvPHavYXfeDc0UYf6nBDMdT1p"
    "p3G1b807tCsRLTOA0f8j6kyqF8rd4RJiLFzu361BV6oO9Q7SMf2n68GRfY6e2Zg3Kc8LzWjSxOB42H"
    "7aIEVqmhGafgG4GOffLajbPAQa2hSFqo28mqvSpaDPgQG1iJVRo9hbmwpy6asdz0wBkDbrz0ZnKo9B"
    "MgDc)H47ApHcgXBa2KiRoXsc4oq4EGBPdWl1abUv63JtfykORTEmGJ2W0m6pxAIIivz52B7TRvjEtE"
    "TDmygism5M1dTMkgVOwYnoVqomrrabXoThysNOSYPerNvpg(Iww6Z2wU(f3OEAJmQQMs9ARVJn3bOm"
    "6g950Pf2WrMLRyBLDgAUqhHeuJ0xCs4CcJZ8nmKfj8SL24se5us0YpUQ8F64bVyOrOPcSNGF2f2PU9"
    "k6yfdpan4KBuv1mo4z3MeCry2bSucCn29twuKOWh0x)(4HD4KphvS6V14VXBCGDE03XYTjI1ZuRUUO"
    "LdtkKGS32eqHRskob992xx3y5ZUXW0oaB3LUScnRcrQGAzOhYd70f8LCbvHlTUGlZfuTRd2c0E1Gph"
    "OJDRD9czs8VV7dbDSkOtBJ)rEY76DFaQXp43b0fYxFC4jGVwzqIzR)(qGso5qpO5nFVQ5i6ulAiySX"
    "1ONql(6G6BhIzwJE7trjxLUwmB)BO3JubCBfDPb(IgZqyjis3o8FRV(vq)Sb)36h8BOF(ToH(KG(TT"
    "IHbOFn4bVCy3mPM2PwQLqAMQTu5zco5ymnhQFafhGkObdb62IQSlpvmmmvSc5klrHrqqzu4RmhHhCN"
    "2co4Rc3fC3sW9GpJ7Lo9FB2N3bF0Jjb7sAjRsGVEm4BGcb4aiBbz9zhP5eT0KIV2AmoC)W3eEaKK)X"
    ")3N6poWnrj5WdUt4HGhgzZWJ4aoujAmxpckcWJcJJCx4XqE7FOIN5z(WNftua3N1cWtkbFR5L3Tj2C"
    "cZj03lU68NyJxAzw3D8wh75EQGYuw3KjWS3OhQcncnoFJzr4oaJSSb4ZtjuushsNOSkAQbkPZMgnl("
    "dYsU5DWOiuiC(C(nkBOI4RXPp(6Oi8oK2ASmI5cfjsOEMLDSEO(IeORG(E)PsLwnxh6KHYsusKV3pZ"
    "22Q7gTQ)sVWKOQOZ02v9LgJ2eTC2uXZAAQQecf1yc7jOnhGLVT6c0JlwwF8uf7kB4nj902TZ)6KDNf"
    "lrXgfrKKtSFf0K0jRJHz)Cco6HsSgciJxCnS3gN1VObEaplivfPPmg1USjLizJY5MbPCoTu9j1sjos"
    "1mAYJ4GFgH2S5CAvgrMOxBJ1AKw1Sw0MpbsF57RDJKQEg2BQiuskLYICqKzJ8VhZdLDUtxJvKmf7e7"
    "Nq08sZqBYtxBKSzJVK1lA(yIWZSi0pkVJY)qAyz63RinFCp4zxgum4BxY94WVp8DkYFGjGFOt47bFF"
    "4hun8CoGN3QZFxj4h5aoQeCeNWp2j8cRbEXttmKUeIQZGVtn)93RDhWlhZwlH6FBGyQzIdUPl24kpU"
    "yFXu)Kr57CBBRN8bs2DDumabGzi(TTdwQEx2O1CGjTtlyAEDjEfPLoL9tgSfXXtcBr8gXwevrSfr4Z"
    "aSfXvU7GIRvYONiuucBFPzP1Mfe7bHvH917U2vG64I4MJz57PSmJsyAGQZOCLzOIxb1wl5IFNlkiX1"
    "6slSwQOhHMA74x)izE1v)UCZlK1afB2rj)WMlemCZ(QV(gY3KN0umdXllK3sqIKHs1LBDl334E)B18"
    "QlneBHKzFY5gE6Ry83AlF8h9Z2v(h6t0kBNkLwJ0kACd3IQFtX8TRCYv0WWzvuXf9ZF63YQYwj35ZZ"
    "QJDMGCw1ZATTR(9o0D25nTO1ZAQy9SYl1mbKwlg5AIB0T3U(aRu11OzIF(x)XVgZxQmcg)GJ8YI)No"
    "x6ApRj75vgM2QGt20ChLZsEzmmVElmV42yAd9LmnZLtB4bhCZ7z7TOzNNe1dNSJ5Xd(MpMXXCD4zHA"
    "p8r)qplDD3c(ZxoNiMXkSzz9ftE2CHuJQiB4pql5919cg)NseELfkP)zcs9))ABRij95Unl27c6mwF"
    "XyGZoPVhZicBUn9bYKQ3v8K(lBb15Hj9V(o68xC7F0DDAL0V(IXgBUqDJKYJ(U3wsU47EzM0Fzx76t"
    "tj9ptISmJShZxY)w3Yp9yCtSQBzEHWgNBY)SDosB7tRpV7xX7IL8VTTQu5ZFph(SlcEHK)NofZAcrQ"
    "ws0ZU73xEPbvpZt(pFzhL(ZJS3)YR9tUqkKZYaN26ziNB7nIK(VKrTwBtRbDNs6YtBD6P7U3MI8sls"
    "YzcS9P0ijbFZh9VoWDhBHJK4E(38r1g33qPY0ICdCnTIhj5SbmDE3MpAh180jsI7YB(iF(r3V2Mf2x"
    ")d7BzgjzzBjEHnF0EZhTdxoFq2jV5JsnS589pAd8PIVOB(ilAZyNR6gEo1VJ2D5nDCpnU9DzMi8Gjj"
    "N6IwNQnB8SH26C76w2bOp0Iw3QP5u3QL9exuwIF0EfuxPQBDsO1F6F0GOBVxWjC56ek45x(6jpWhue"
    "NNMHZEQLlBYKgwbuMPvyOmDTVwYLjuMgnoLwHljC6cXmSIzig2cso1XmMCMifcnE7EGo8eC0qH41wU"
    "PmUG26SI2Q19(u5o6QoYtx6hETbgK1qTHnfueP)x0pRPCAzZ812w7ZvOX3C8CbtNV3uKowSmh9pi9T"
    "COZUAUlK5yU)Q5AwyWJTx(gd7R5H49Mm3OBFXZGu1WV1G)V)"
)

# ============================================================================
# v0.1 - first agent edit (2026-07-02): merge Health+Mana into one
# resource bar spanning their combined old footprint +20px each side,
# half height; 6px gap added between all icons (25% of the 25px icon
# width) so cooldown/stack numeric overlays don't clip into neighbors.
# ============================================================================

TEMPLATE_SHADOW_V0_1_IMPORT_STRING = (
    "!WA:2!TRvFSTr5z84AQyZ)bQj9lsxg42rPjWkKANKMWGr8L4eNuN40ZoFvvi(SVx77AoF317oh)X2q"
    "q0Olti2GiXOIHeL8hJjeLTLUXym2wxagvAsJh8q7dPnMuqdy7)w)J9H02ypV3D2joFqAsAyQ0K)W5E"
    "EV3xFVVp)(45jNIJbQkvv8vXpH7cX4IpkVMIABkskAD70PZ(Cw)T14SXu04jAm23uDBmsI5ZZPX7oI"
    "IIKHO6ugkXhJOPlQi)jg74f4sBiOOfs1aJ1DnJ1QdLiHoX4tgZksykRF7NpjrTYWNmnNgXDhPLKCpO"
    "GObzknssCXrYPsytQPKw1E6HfZt2Q620fWPZ3HgxksqYyePOtBDBRTTdhoCYQhNtI4ulN1JnW5d8pp"
    "5TCD)MZRXf3Cx1eRUbNMHlgrzrdxXsG)sxW14gAIjtIhK9CZA2xEQP4jXsNibDROfWFW(6O)Gmg09f"
    "xAnopJRRsKK6Ix31S6PJH7fzJW4SfZo9iT5lCKrchXhBeM04djMQexoIgRmUP1DXAo1ybiCsgcLwAF"
    "AeCPSH7ZFWGtMw2El4AAo54ycTpfrCjT5V3i(zViEjrtMtAaR0(z1YAFsBTLQ3EfdP9NMKtwmfh9W2"
    "euvhq1mYkYKziC6KWgAe5KgcxBbE8iqNXi0dKMojUImV(405qpUWTYKItugxlCRWN9AHdc3gC74L7y"
    "HJSpr(lgHKcpGgKrqSHxjZK6ePeMBy4atNGcu4tLZGZ5fTolMyh9HelCBS(93RN0I8t3tx1kioWGPh"
    "iE2y4wjHysxSCsQcCoNcZqSMucDxtlkNqrZ6O5Ak6ww0IOXiPWX3edIiX3fBQ0iX0fBCjoD9Db3Tlg"
    "DK6qVWMQ0LmMSCQwfUEdnfjjcFBcIs8yM5m7MPhozo1TfrKO5Ur36skgU7ttjEH5pGNYI8wwudLf1y"
    "zrnPUdZWdzfYQyyEqkm)b9uwK3YIAOSOgllQj1Qnd9yVNvYGbXsByGzNcZ)oEklYBzrnuwuJLf10mM"
    "rEDZGCC9zNFGBpQ1yg3G7WgCY8u3H0gIsIg5C3w74D3ZYF3QIFMDprZtPRYPn6GI8gc7CgZRTy0d5a"
    "QZX0C8NiTUbHVhUSBzUar5TaBlW5jVy2VX99opeCZWbkyUYIPvhQvwwCpk8egF9hjK1dicjRrAnIAT"
    "Drvtj4ItoEBC6gIYjz40oE)DDW5Ioyy6cUi1GKAijZxYRX0Ie251DZWUE3ztRtvakz8ftxrlwuuOCd"
    "qnWN2CCoZXOBHOWEznrh4Za3K6okUOUKJRKcFCuxHOtQsNavy6a(uUgNohQnsuWTl878glqhO0uIc7"
    "gUEy)UuRK6VngjILZb9z9CvmLisYhjErlDNqTNDwvnLKAeD9WkP1ItULAQylGh4amgycry8yCfDsdC"
    "3x46P)SNa3979BP)87CI(H6CguJdIW8HPHDa3r37cQUakvNllzpakyjwdmXUv3l9PmI5hwc5ruhXqm"
    "fEC0iXfPUzoNS0u23(X6nMrwglZzXpR1OL8z4u3U5iy1hfQ7qCtQeJpm8IwpmXSeEZbFGcwUqdBT1D"
    "mJ59PCkXe5GdavRH7z6yQ30YTxLij5INBKeskkyXmZjmxgEs7fiBOUTo0eZ7(OP54P2FUJerTUL7RK"
    "phwBqm(igciYiOiXNtTQ5DYT3S1uH1UDmmtftIeTGzug0uBqno1Xh0(IcL2cuxwMErZF1By5EYwrou"
    "REjMG1fS05XpJvAd5DycFQU6Tx)SJe0FhrM7HrlqxTD2Di7SBzNc7bDoX2Hh1jm2(2VmKXeoHSahKd"
    "YdFHha(IoGVefgG7dUFlk7daJdF5AQaof8vGhm6sSrLTValm9WtBTZy7QZarGVE1WJ4aMa(QQBpPgh"
    "ViwMnKg9ttdHPceITRJfQ3i(cAEiq3aljHNGH7bURoGwP1mGpp9ZjPsozSqTwuWhDGznP)msezEQsZ"
    "JV2BxDB4K8zBpz6wjyk)S(sRPIjlQT8qfx)rZFEBNoNLiZHGzN2Bqbg6AeGBXQ0D5LFRFLlipREkff"
    "dH(Sf5rx4Use)UDPrBGb3oqZUGMMoD2dhV5MK93wJXM00VqxKNWAMcJjqetkGDwu3dETV(F7Kpb0a0"
    "40Mh9aM34U0SZCJxSVqWRtM8kkPCWAonb4AW2cXUeG2TxNipprMTx)d4NfAXjBgQOmqRPhk7J)c)JN"
    "b2QlRAbL6c1PMOmT)sIW0kZHDWJb3Pl4Z5cQettUGT7c2HRj2p8KinPUaNFyLR76)9FqZW9Sf4Enls"
    "CVV1l(mNUxrArIzIJ9TIKrzA7NcWtf1Y((uMUOvd7bnCPU2uFwQD7EH9rnQr)vq65QaTpb5IoMWjfG"
    "74oqxoqNYOxkjK(CmtKURFPt3DyZ2HhwTslgntOirc1tz8ATq9hjyx96)DlKusjthAKtMMihpxFxt9"
    "3MNgTmYO3ygKa0PKT9PW40HO(cfS6oieMCXUtNIoCqZEd3500Rl6pozYIl1C7ndnSD7EhDAoZIADZD"
    "rebX4JkJepNMlmSzR4m0lfmhiOiEZknFAmw)1aW3Y7ceBWPTfzW3uaEAKUcpLTCaP5u2(8KdlyKDSO"
    "rkXr2Hjn5zDWoVQHf5M(rvaB)TRNqX7y(sgb5WuIosgPcKVRa88ErQkY4gVi5j6fhLqu9r730GLMle"
    "SzFVM1x8sX8GPxb6gLNr5BiTBo62fewkUgCU1bLc((LCg)bVl8cf5lWpe(PoHFe8sWpENWl7a(jwl("
    "ffGFMdygb4N7eoVt4vQeE1lrmJMcr14r)owQXxpQT25zDukX3bnbJzBmbVvQvuE2oRV(EYfmr31sZ7"
    "ysFEcCBj)A1z0gHwa0OEjbnlPtWfew70YpAWte7weEIymINisI4jIQRc8eXY2E7Ao05(VQMusekkHN"
    "Vw56PorOK7e9DKJeSwMiEyO4OfcBjNOedVu9eLtmp15gOgATsAUIu4H56sjwlLdcri6T3SQ)I34Fnt"
    "jykafpAPKxxtt3B4d7)qhQHCn5vIItigzHWwcpe0lvJT1MA71FYt78gxBO0YjN(OZP7sxzeO1M)G)Z"
    "lDKCp8hPvPwOIQlAfkMXAwjGbFU2LxCfQaT2sfvS1x(jElRkvLCBVkRU0QbTSQp1A3p978Rc64rwY6"
    "tDxS(0CPxtHIAZ6zAIjFlTRn4gvDkAFScx41EVNO(5qTytK9C8)7ox7AmRd4vvMH2m)fBi2YCQRJyd"
    "ZLmcZKrDSHgQUJ1sZQ29)H89f7cE(J(Txmc91o7F17AxxTS)5fxr0IWgNbyqevsMxwupqWMZ5V7LTf"
    "DkqFHLRB8vd68))AuBiDJ32B(Op0B0q0L0TRNf0nUxJiC11M2GPs23gE34RBHZvHDJV3o642VZ38(x"
    "PUX7fHYAZM0R2W1NGj2WRZUXx31G(4u34RM2nMxpelv35T20X)dVp3J3Ajyl0c7opDNzB7eQ97BuzF"
    "Ru35D)8Yg1)lpZLxuBZUZxUIt9HOtZX7z4b8NtyiLvF35L61RH5qmH3p7X)lV63BZojUCdwhL(Yj6Y"
    "BBD6T7URxwCT1jXQbD(yANew9(2Ws2jb7c6KqPXtCYKPAwSbMM2W7K4Yb0Cv371ZSRqHvQtIW03crU"
    "8JQwh3jgym)RZojw3oCB(E9SFVEM9bEMsWuKf9E9eAOUCdKVb2KXwX3RNzxi1FLQt3vkfH6hrLJ1yl"
    "hXiE4Hsq(Wlc9H9E8UCOHUYUoKDVUNEjRdnWcQd18XIXlkWMVpoLn(6q)5)Ed8E8TzDOvrDi(Z9kxi"
    "XPEVvQo0Giu6R7b7WBV5dfIvD9whAvauBwh6dPou0FTf6veMgAH1HcLQRt0CMuHs1O(kvhQ)tN5SB5"
    "5ESlVYPnRdTqL0WiQOpM)dFswFjYKVL1EDOn1qxw0qTEpdzX7lcqhBHAi2dhltVs56ljPJLwdv1yV1"
    "qvPR6odHBu6)NxJexHNe3DTCjjYghe)Gq)h4KVU)h"
)

# ============================================================================
# v0.2 - second agent edit (2026-07-02): Mana moved up to touch Tier 1's
# row exactly, and a same-sized placeholder bar ("Resource 2
# (placeholder)") added directly beneath it for the second class
# resource/counter slot HUD_DESIGN.md's Resources tier calls for.
# ============================================================================

TEMPLATE_SHADOW_V0_2_IMPORT_STRING = (
    "!WA:2!TRvFWXrzz8C9Od69hmTPFMAfUwO0eWcP5sstqqYDjxYL0lF09U8rRfYT3TV3TBZE7UD39YLl"
    "IkeHsuSiefPwrOKbbeBbjOiIOwdFueNrEi2XpMrXzIkG(hod9p8JzuXN33DV7YLM00K0ItPn)X195D"
    "FFV99953hpp7n1rxfNSyHIfg29er5J1NGUQw9QYQ6T40PZoCw(1u1Krv1fi6(SVP2Y8jln4G86cUdR"
    "QkBkPnQPAS(j6gsQkFO(39e8Pmfv1BxZeJnCnU1QBpECdI5hoQvK4Ow)RFHeeTLhAVP41jUBmLSS7U"
    "fLmjJQtsGloCgncxcD1uA2tpK0GKLQTmdrC6cnQZNKeK0proYyw32AB7WHdNCgX4Ljo1Zy9ydC0a)Z"
    "9EvxYV6O68Xy7QQ5mm51nD5tsrY0v044)yi6AitDPejWdY6UsD7l33OcKOPIhNUv0d4pyhn2zqFM09"
    "fFkD(kgYqJil3SGHRjnsff3lkMHWzlnWy9wV3qH7nuyVCH9LcFir1K5Zq05uWnTHlo2uJgGWlBkMBP"
    "DOtWLYfQd)bdoskf7TGRX4vIHj0ouLWLuV)2c7N7e4LeDfE5USs7hrFa7tAD1wYkkQh9)Wi8ksj5Ph"
    "2QHIBekXNIQczCcVbjKPorjHP4fpHaEeOZOx6bs3GetvrWyi6COhx4Q9LKxsbxlC1Wh7IHTaxdCT4L"
    "RC6JSrjHteMKepGMKErSrqn9ige54SnmS5XItbk8PYBY78ewNfg2rFirdvpNF)TvrkjHXAT5sfL6Q7"
    "uDfBGO4wjUucxC8YAI8ohfZqCmkHHRXKuIRQBD0CnkDllzr08jRYluTperITAUKPqIPlUyY8ggRgUr"
    "x(mqQd9cBQsZkyYYPwX46n1vLLjc1lkjlGzMdTgFTYRWRTSWseD3v52qw10Dh6QXMyQdurbrEkiQYc"
    "IQQGOQ1wjlCRwHCQMSdYetDWkkiYtbrvwquvfevTwjSWkS3ZQPXGOPmnXSZet9ovuqKNcIQSGOQkiQ"
    "6XzrEC7d54gto1a3vOTEwCLUdzYRiqDhszkjlzMXD9nG3DDZ(Dlo2Hw7W1mQHgVEFDljykUQXzxBXO"
    "7XbuMJX4f2tkdtIqR8dSK8bsklbwwGJk8No07(i35XHRe28eSvMnT6qB5fe3QQaXN3od3U1dimzaZu"
    "6eTsBMQMIZhJS765nmLus4JxF3D28wYhTLq0fCcQbj1qsriNxdZIew1LCLWQFRjtzqvaQP9g1qvpAe"
    "uOCPW6HpkBCE2y0TqeydCm0bUC4k0wz2f1Ssm1K4JJ6kezen6eOcthWhX1q05qTrIaUDHFNx2e0bYn"
    "LiWAG1cBYL2YP(B9tcB5CqFwhUOrLqsEVXYAP7ek9itQPRMqNyyesnLEmYvT(IwcubSzFMycrCOO8z"
    "DsdCJV6AP)TUa34B)RP)9BCI(Hg8MuJdI4uHPD6aUUwwnuYeOunFwYEauWsSgy41OTb6tPx2hwc5E1"
    "61ukjEC0jXKOUzohj3u24MW6nSilJL8w8tAnAoFgETvWgbR(OsDhIXOs(8IHNW6HjnarGn4TnHLl0o"
    "T26ogNDFkNskEgyZqj64EMoM2vmB7vzsc(yz6nUSQkwmJnH8z4rSxGIP2YAuxAq37ifVa1(ZD4WALn"
    "BFLczWAdsX61uergrvzHmAfpLtU9MD9fzTB7hZurLjrMGfLgn16wNxBOUTVyICBbQlRV2qZFTlD2EY"
    "wro0kzgMG1fC05jmUvAd5DycF0MBRn)C9g0FJHZ)WOfOlXo72JD2TGtH9GohEfW96e6FJBsbsZGtya"
    "GhYadcFQBdUfhWNMcdWNbUvlk7Tbdb3(6lc2hCNWDezg2Ok2xGfM2)yw7mUMBkqy4lvcCpoGHHpV2k"
    "sOZliHLzBxN(jZqy0aTZ18UAVTWEdYoeOBGLKOIGHAfUHgH6O1mGpb9ZrOsofSqTEeWlDGjz0FFYef"
    "bQsRcVn0G2YWj512EI5wjYKFwFPRVOrYQTQGkU(9S)EtNoNKOWJGzt2BqrF01icxLvP7cl)w(CxqEs"
    "JKQQMIDylYJm9DLe(D7sN2adUDGACbvpwQb2wSAQwXF9vfDeMFHHKaHJLcJksKsiIDwu2DCXh7D37b"
    "HkHQgJD0dWUXnOBN5gkBFHGhN(guvnPdo20eHlcBle7saAWEDsccefU283LFoOwNCPPIYa1LQNbU)N"
    "9F8yWsDzvlixxOo1LuO9xsehtnp2b3hC9UGpUly5yAYfScxWkDnCnWNCvWUPLmGBAjWnZkpe)wExLl"
    ")b)B0YdqVoGiirlkedeMU7nqYzydXrpAib1FgeJasupyypznFH(YA4cYhUiizwBvqjRtkOkcAZO)jS"
    "xrq32RemOFyo8AGumTG2Pwl8zfNQC4ZLHPiUJimrbsWHVGd4UGViSF4UTz937ItMbJqvtWxoVgc(ky"
    "s)Rc3)0ugWbSveWxdoi81fHha)o(gfWWHhueEOfoJgoue4HrslmkJUoPMihXWsO2F5vapc8nHhTack"
    "8y3a84W3czIWt4a(25OGARn7cXMAkfBzngHA1s0ldomCeKmcp5ujIWtzLy(oIWtpJ8TnXoRLf4O7u9"
    "sw7V99QjpR7Mp(Z9yhOnjkRB8y47jHMFk0x3bZdrSiC7JrIkbwhLCrjDuQfYW2aSrgXZMEvaVczpx3"
    "1XOouODMSSnY7eI4UXPpU7ilSVFTLB5G6R9WHBV1c8r1BVZWbBUn)V1ejKvt3OozVPikXY0Xfv(1ur"
    "vwfoP3yC0WPjz7Y1IdrhIwhAcRUrBhfZ4BdnkD4GS3fzvJrVoB94rsKDPST340WgSFxfNSzMT2cBxe"
    "wukwFkOrNt2cdXE1pF0lfzdeucV5YzpnFwV9j8OEMvkmsFzmThYMSIKqkxCkK1PnYkpPrYXrwjJM8e"
    "o4Ms3xz9c9JUUCD2GrCvp97nryktLYBrohYWr(2t6HYgVExdLL8e5e9riAEPVFJjhnxiAZ(oM1x8mX"
    "8GV7Cq3O8mkFdPD5PBVM4mX1GV3IGsbpBoxKV)Bbpxw(c8dGJ6e(HWla)Ovb)yhWpXAXpVi8tDaVKi"
    "8IoHXDcV8YHx50eZOPqunUJNYsn(ZIyRDqtGSj(gPjymBJj4Lsl9nixtLxERzcgVLsP5DmPpfbUTKF"
    "H6BzJqtdA0oTGMz0j41ex40Y3FWte7oj8eXyeprKeXtevNh4jIL1)MRFRpZ)vJrjrOihEESc1tnHqj"
    ")E6y7BpyP(cxHpMvUN8YjkXWdvpr5etrDEwudTGl2DUOWdZ15sSwkheIq0BddO9kV()A8CWuakEuBo"
    "VUQhRTqBZ)w3ALzQ2JmfNqmYcHTeEiONRgBDvx)XEGd48YwyO0SjNE)ZP70xzeOUAEV)ZZV9m7)91Q"
    "utxr1mTcLV(RrnGPqMguo5kubQR2IkAPVWbpUvLQCUTNNvxA(Gww1NQRLh(p(lc64EMX6tTKT(u(0l"
    "tOOvJr6Q9nyTnO39zR6u0(yfF1x(Tpy55rTOdpWZi8VBAHRXSoGNxzgAZ8pzdXAZRU2UnmNZimDAT("
    "7PNY2vT1Oz3)hY3pzxWJUJh)KrO7(i)vplCD1S(6fNt0IWzpdWGiQKyqfjJabRjJ)wM1w0Pa9RnBDJ"
    "pFqN))xJ6Ss341)g37D96vgzgD7ADADJ7XmmFz1R3DYeDCwVB8fTW58WUX3qJnETx)BCRZv34THqzP"
    "dKWJ(olpUVO7Cr2n(IUg0hK6gF(0UXu6HyM6oVUQ39V7D4V)6YbBTp9UZt10a1VhTo92NI35Q78wEs"
    "fZY)5h6mlQDHUZNTItDGOtnXADND5pJypQZ)UZZ1RxL5rmX3zGD)xEPN(cDsCMgS2b9hNOzp13KNwA"
    "PCfPfwNeZh05dODsy17BLZyNeCtRtc1Q2ZEtKSgPk9v9z9ojotanN3976X6kuCU6Kie9xHiZG9Pvg)"
    "E6QF)lYojw0oCx431Z(31J1h4HYbtHpPFxpXklltxdwjxIOZ5VRhRlKYpx1P7CLIqDIOYUQQ2TBglu"
    "pXjN6IqNQFhVZeAOZTRdz3R7bMX6qDnT6q1SROcsICd2bV6z)6q)5)ELcv49c1HMh1HeEMx8vJVV3E"
    "UQd1ncLEBP7g902GT3oN2ITo08aOUqDOtrDOi)sl0llm1Z0Rd1EYM3tnPt2EYQmMR6qDEG0hzjh((o"
    "ZkNUqDOPRK2jIkg97FB7LZB80dw7cVo0f0qNr0q1Dt9yX7Zcq7A6AiUTfnDBYz6ibPXzwdvC)hVNIn"
    "0CNMW3h9)xH9gtvGeZDP8jikMBb)Gq)pmSqz)p"
)

# Battlewrath then hand-tweaked this live in-game (screenshot + string
# shared 2026-07-02, character Gravekeeper): resized Power buttons to
# 40x30, Buffs/Utility down to 30x20, rounded resource bars to 350x15.
# Flagged for the agent to fix with a formula rather than more hand-
# tweaking: (1) spacing/sizing should be computed, not dragged, (2)
# Tier 3/Tier 4 had drifted to different distances from center.

# ============================================================================
# v0.3 - third agent edit (2026-07-02), built from Battlewrath's hand-
# tweaked live version, fixing both flagged issues with an explicit
# formula: gap = round(icon_width * 0.25) (10px/8px), Proc/Rotation/
# Power centered at x=0, Tier 3/Tier 4 rebuilt as an exact mirror, full
# vertical stack recomputed with a consistent 10px gap between every
# row (needed because growing icon height without doing this made two
# rows overlap by ~5 units).
# ============================================================================

TEMPLATE_SHADOW_V0_3_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4OSPjurAi2UjnjeAvdnH4Y0o2YxtN6P1YwosU2sYRKDSdHATA3J0U2R2DZURSSm"
    "xRbcMRbmqlxAHIPCpPdOHY1cum36Wt)JggGhkWmEykVWt5jMPVW)5SRKTuStICmDM2A9G8(F05SNZ5"
    ")77)77S7ypJ1y2gLAuAbFRKs3uIygqqCAjtDdJ9hqvzU5emL8Lqxx1wXWC2OPtBrSd9WN6WnTJXn)N"
    "MfCB4fc9Fp)9UV)Yluuqtuw3mMUIMDQ(cgjrqEJ9BjlysKgWuilziYme1KfDMO(0v1nh0JhpCMcI2k"
    "6AwDYBzlyA7nGIMIT3uPX)yj7DEBtLmziMwh5eMUxEHLKiPYLoDIcgeZqbhk2aJouaBmGxiNPG)5Tm"
    "iQQHLS8UIvUu4CQzhh7TYSfNSVEJNyY4j6LprGC4KKYqvOaXSs3IzsWUXhpwWHgIN1sQqebvBzEnC5"
    "B5DXCAUlbVxb3Jetnb1XWLgU6V8IcAkzfOBKobVdaneqtxJSmrWIe32KOLXwEpLKWLhThtsxSMwerD"
    "njR5P9HUvaFbYkOOHJf8b39EGJbVD4EWl3BTTSeUE5jzO5mVbu1fK6maULfpiF2Ciq5LxuvWY6GqZE"
    "dyPmhHErPuUWQtwNJJlgxl3Fh8wIcQeUuoiI8so)nOugIrdXpFoe48nqovvFNrwXMSKjBkPRu(mM65"
    "mC7ECCoULLDU2HqCRlzRloJtE5nnZ5oMI0vsqYI5ABYKiDqspFX0u(aMyeSf4UIdTHrrO39uX7JpyW"
    "iLeYzJnh1Gro86sBcRHtaxkmZLwjJx)5uKk6V3mnpSwxQHo9ulArutZ4FWUxIMDvChSIwADth4XlVG"
    "QHSaNrJyhSn1vvjs9jROkHO0tFOadlOjy0umvbrISUkoJ(mjw65ejg7pHcg1HplvDBFXm1flT2g8xv"
    "uBvf1EvrDuvuNg3olSvNqEDB2QS0AB0FvrTvvu7vf1rvrDACywOF31SEEmivoBBmNuAT)I)QIARQO2"
    "RkQJQI6CfwuB(cGfyw(AR6q)ghLf3UV42cAsuTKC2kQk2f81x)xNFTTgfF6dTq3lzziyo9zuKSLpWs"
    "kiGfxpNPi5O7aEaVffKMkNLnrAyHz35QbkA7e2143sRD7)(7aUfy3lMsWrSX)GEc9q)D2N)bhxj2DU"
    "C62JrdvfpSUejqVJMi6vOvou6UMufflwTdCB77eW(E5vYzrj1657nLLUzQKyP6bHBhoaRDbwB07vs4"
    "i8S0pCuVg3E5XewtupRIwgQitYfnO)ovzWd0Kx4qWHX70DmpTVuTQKLOxvPpjH3cSF4T51ObQ65mKe"
    "o6s056s7GLPMuSCTo3kenHuQKtBkiPGIAYRyyQNbP1wozZ79O7yNWD5iBvT0ZXV(IrbSjZAlpF5Kmn"
    "h)IhI(5iHEO)9FL(5VXH61wc2uXpISdIwrhIBzwSJWXeEGtm4bHgkHcCRM3DBalGjonSWDyC30zDs2"
    "xof2tAmPTswmbzsevOcpClwPlh74ODglYr9zvRNvCATIOHOrtSwqPhDQAHiJ5fOxm8kotMYSejwJpM"
    "X9SrRbvsgbXctMwvx3uEzwhOCtL0fGDdnyI7fABLCK9MWzR7zjw)wfZw09gRzBS)bmvMZ3i5eKO6L("
    "sKWO5nAQLkGovkItAlJWlv)QGrJRzN7ozhDhoRQzWmfYlswIfLhfypJPGX8NX9Isvwcuz5arqdnJ7C"
    "JMzNipghED6GZf80(jTSZ2gzYycFPWrIeKFYHcoqIvNmQHYHDZoJ7MDQAx42i3cnToZMM7fijD2JDC"
    "nOadOH5ar49aVx499yWJ5b(auGa(GW8Sun8HGpmCbutzb4JbF0KWNJdUyrNvgF4thkb8zpmSOh4JdF"
    "IuYeLmY23fBXMZK4u)4FO4ddVJbG7LA1cNK(9I0Ivn8ieMYW7K2WkmAEavIMeTg1FV93VX(Xo1RRSf"
    "tftg48eGw7kdDdNcUZldpioWS662YXCRytw7OuWo3Qj9Gpyji0fNrtzClZJAs)MjNTuOO8HpB0ij6D"
    "OfzAdwkseENn3TIf(EH3SxyVEDQft4S3mozy6rCsJgHNRpbK(QLjGG55gn89TA09fNoGISHfILA6X0"
    "n1mF5ZpI2)q)bMtxpRhEwhLHoWtf4oifjjIgFKGJfKhEievcWXNNwE9Voa0trRXs12OIrdZpDRMkA0"
    "tuqKxREX4EkQV6MewcEyVqVExOB4ChaE3iEY5bE0Dct64hCQUC8dWEacEGuiHWzRVx2U3rohivuWH0"
    "OOnKbfSb5KGYAfLHPsctxwbguV0oGSoejeX0zQP0TIHmC(1voeqsHLZaSDv8GC0VMzH7aYZr5TgxBE"
    "lYqxd1f5Mu2lYplZG)KEGpf8PHlcFgk39JuaE)Yl0eDuB2sc69(IWxWTs4ZJfxFDmD)eWxKY7zmEx2"
    ")xYLVdFz4RapPmiTQHjLsJK1Ek28id0PqlsJLOLHHVAs4RHey4PrKhE87c(gWZapLmCj4YW3Uh47aF"
    "x4BcFl475b((o0gkBkisZHNfzioEwOxe1sAnEw10YEVQwEqVWpqg(HEGIoKMKvD0a8SflCCgb6b8Yy"
    "p)NDtjollIpiek)OrpGS8vtEUaJq0a0iLPqjquMcLXCe4TszrUuL78YxzAcXOx6r2T5PmxzgDbjfN4"
    "byubkuTEcPwvjTzDJJJEkdJx0ObhDTartKi6WvPUzgD0edfosWxUugv98dysoFoIMyHy7QL73Fho2w"
    "0Fyz6x97(GmCZtJOUdLCowzuSifFMQLOnpe7PEoqr61LD5wKgSgZFul70LBrM1ZYk(SvrczfXP1qzp"
    "o2aJZECLa0lLznmKc(JnWMTaopdd849uJu8QusKoY4Apf8ujrva(vnBDRArAgYmktZgaE2rOmnkVfj"
    "N9umC00D3DNd6xDotk95r35MNa(WENVmBkjW9s7z94BWpsMUq3yUfYPOulkfRc3cEo5n9r5QLcc)4B"
    "cMg8tQyB(tFz4NvMgb)C43idpp8lHF1bGFTh4fCg8VGdw2d87LHFhh8B5G)qdWF8gekDqU)eMfF(DX"
    "QJErN7iIL9uCQtkuWC8(SsmCZvG1ttbtxyfbyhPaelzEhR1n0ft4Esp1dOSEf8UlYnnB5vhCbXGRcx"
    "qScXferqCbrN6axqEiMoDbdKxxDTvOYvvoLy9umYOrgyMyXThV3Z6IhuSeXeezxJs7gvNSgyRElyw1"
    "W(1I0FKls5(TT5l6xB9Ye8Pgl(P6KCQZ3zfOkmfGCqkkMvt9YZjFTHKnJ)4R6qYwlZNzUuoTILbvZ8"
    "hSwxLO(LoDuR(mEKyk38UkmYWtSTBYnVBYRCvMjQYT1C3zo1e2Jnvf08rQxZKxApmmr9wRpLR1Tm55"
    "KFnUSfsq30SlgKiiMF6wBDW84rgRajdrbIaoqcImvGexO0bzy4C1Lj1cjxpLRnQE51fYwR35HhUwLR"
    "P7wFuRibNYiuhBrkxp)U2imP(pZ1BCLUWdSwR2Ls7zvB2msVT1hPcEgPE1UAREWKRXzT2(CWvWGO1E"
    "o4SfMGKnJDRJOg6g)CWBjUjVU4CWpXwZ5GJ0vR51c2p)mH6QcufRUohC96M8gUZbpsTUjNSJ4rgn1z"
    "1BzKcBrUjVsnqY(22G)AAWZxlK0xxTo6eDxWk8SDTfbj1(MUwft22G)M6nDDEd)Z1vSXNTD7twbpJV"
    "jFtx3mGY2o81uuLOwh(273ySMhnFRZQOxho87B7301w6B6Q1HMzQZM3oEAjXkq1O1Nd)(22H)A6Wpw"
    "T2jt8ikzBZirxrug5)pVPRBqHRTFtxxN3010QXAjC((dfzU4vqZZuVMj79222mP6sQMVPntgVIzspo"
    "MjePCTMnE3D1RERBBMuhPzxZKl5DRXnjww78jotlJkn4QVELjk7M0Z2Uj3OyY1Wn5SUC(kUjJpc5S("
    "jwX5h2AlYn5z2UozdQt21TT1uNi3XSzKgjD8UmhPcW(UUo1jnoZFE8gTm8LNimn9FZTjf1LiI(oPqg"
    "IM99HFrO)FLk18)d"
)

# Tested live: felt too loose ("I think gap of 10 will be too great" -
# Battlewrath, correctly, before even seeing it). Investigated why
# rather than just picking a smaller number by feel: pulled Luxthos
# Mage's actual live `Core` DynamicGroup definition via wago.io's Editor
# - it uses `space=2, columnSpace=1, rowSpace=1` on 48px icons (about
# 4% of width), corroborating the ToxiUI guide's separately-documented
# ~2px convention. Two independent real packs, same small near-fixed
# range - the "gap = 25% of width" formula was the mistake, not the
# specific number. Promoted to a standing cross-cutting rule in
# HUD_DESIGN.md ("Compactness and cohesive spacing reinforce each
# other"), and to a reusable tool (`geometry.py`) so this math doesn't
# get hand-rederived (and potentially mis-derived) again next time.

# ============================================================================
# v0.4 - fourth agent edit (2026-07-02): replaced the percentage-based
# gap formula with a small FIXED icon-to-icon gap (3px - within the
# 2-4px range HUD_DESIGN.md's spacing rule now specifies), applied to
# every icon row (Proc/Rotation/Power at 40x30, Buffs/Utility at
# 30x20). Built using `geometry.py`'s `row_x_offsets`/`mirror_flanks`
# directly (the first real use of that tool, not ad hoc script math) -
# self-tests still pass and reproduce v0.3's numbers, confirming the
# tool itself is correct before trusting its output for something new.
#
# Deliberately UNCHANGED from v0.3: vertical row-to-row spacing (10px)
# and the group gap separating Power's row from the flanking Buffs/
# Utility (10px) - both represent inter-TIER separation, a different
# concern from same-row icon cohesion, and weren't part of the Luxthos/
# ToxiUI evidence the new fixed-gap rule is based on. Resource bars
# (Mana/Placeholder) also unchanged - 350x15, stacked touching.
# ============================================================================

TEMPLATE_SHADOW_V0_4_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4OSTPurieB3KMecTQHMqCzAhl5RPt90AzlhjxBj5vYo2HqTwT7rAx7v7Uz3vwwM"
    "R1fkMRbmq5AHI5o00b0q5(LI5whE6F0Wa8cWmEykVWt5jEK)ZzxjzPy7y7y6mT1(b59)OZUNZ()99)"
    "99V7ipJ3CUMLAwArFRMw3uIyguqCgjtDdJdhuvz(5fmL8Luxx1wXWCUyzYyrSd)iN74TSVjm)NMfDh"
    "4fc)FV89DO)Ylusqtuw3mUUIMD6(dfnziEJdBjlysKg0uihzyYSe1uLCwO(1v1nhYJhpCMcI2k6AwD"
    "XBzlyA7nOIMIT30zW)zj7DbBtLSzjMwN4mMUh(KllrsNptMKfniMHdnC8bhB4G2yaVqEtHalyzquvJ"
    "iz5DvR8PX1uZoboBL5knv)9Li5ujs2hFYG5XfjTHQqrIz1Pf3KGtJpr8qdpmpBK0HjcQ2Y8A423Y7s"
    "51C3cEVgEpsm1euhh3A4U)QljOPKtGEJ0f4DqOPGA6AKvicwKe2MeTS2Y3wzjC7rNXu0nRPfruxtYA"
    "b6CO3kGVG5eu0WZf8b3ZTbNcElW9IhEWghzzC)YtYsZzEdQQli1vq8ww8O85YJaLxErvblRJcT6nOL"
    "Y8e6bLt7cRozDooU4CT9aDYBjkOs4s7GiYl78)qszjgnL4Y5rGZ3G5vv9DbzfBYYMSLKUt5ZAQN3WD"
    "6jW14wxX5yhcXTVSTU4So5Lx3Sx6uksxljjhMRTjtH0bj9cLYq5dyIrWwG7Ao0ggfHE1tNOF(qHIww"
    "iVnoCmdg5WRlTjIgUaCPXmxgLSEdKxrQuG(Y26iADRg(8tVKfrndJ)bhyzA2vX9Kv0YOB6apE5funK"
    "f4mAgNGTPUQkrQFzfvjeLEMJfCebnbJwIRkisK1vXv0NjXspViX4WjvWOo9zPQB7lUPUy51oqG6IAV"
    "UOoQlQZ6I6Y4oyH(Dc51Tz7YYRDWa1f1EDrDuxuN1f1LXXzHbC3Z6fWG05TTXCs51(nbQlQ96I6OUO"
    "oRlQRvzrT7liwGz5R96ddyCswCh(sylOjr1sYBROQyx0x)dCd(22Bw8zo2I9SSLHG5mxqrYw(ilRGa"
    "wc98MIKtUp4b9wsqA68w2ePreMB)1cu02pCltCR(7jWd0jCRWbwkTGJytGH8e(H)7S)(hCCLzx5kPB"
    "pgnvx8i6sKG9nwYyxJw5qP7AsvvSy1oWB4qNbo0lTAElkPwVqFPT0ntNclvpkChWryJlWgJETsbNGN"
    "L(Ht614oQCor0e1ZPOLLkYKAjd63tvg8aT4fogCC8kDNlqNlvRkvz6rvNtk4nchgEZEnAIQEoljPJU"
    "eDTE29XYutjwPwNBvIMqAvY5nfKuqrn5vnm1ZI0AlNS59DY9TF4UDKTQx6503yXOG2K5SLxOssMMJF"
    "XJr)7eHF4)9FL(3FJd1RTeSPIFezheTQoe3kSyhHJj9aNzOJcnvgf4QL3DhalGjodS4DACp0vDk2ho"
    "f2tzmLTsombzsevOcpClvDkN60ODglYr9PM1ZQoJwv0q0Of2iO0JovTqKX8c2hgEnNftzoIeBWh34E"
    "3O9GkjRGyXPYOQRBkVcBcuUPsMIWbGMmX7f6yLDK9M05w3ZYS5vdZwY9cRzBC4bnvM33O5fKO6L(sM"
    "0O1nAPLkIovkItzlJWlv)QOrZR5o3DXo5(C2vZIzkKxKQmlQakWEbtbJfUG7bLRUfOYYbJIgAg31gT"
    "YorEmo(6mbNd4PZtAfNBBKjJj8LJenAi(Pgo0GjRTyudLJ7MDMWn7u3DH7GCl2Y6SAAUhGK05o1P1G"
    "ImGgMheH3j8UG39JdpUh49sbc49blWs1WtaVF4jrnLfHpe8btbFko4kLC2z8roF4KWN84WsEGpm8rs"
    "ltuYkBF3SnBEtIt9tGHtmc8wheUpQvlCw6Nlrlw1WwimLH3gDGvz08GQenjAnAG(gyaJdJtQpxzlMk"
    "MmW5jiT2vg6bohCxxfEi8eZPRBlh3TInvJNLcoz)M0gFWsqOBoJwY6wMhZK(jtoB5WX4JCXyrt23Wl"
    "X0gSuKi8o3C3ow47fE9EHd61PwmPZ9MXzJqBXjdAeEP(fq6Rw2GcMxASi3FTO7pb9ekXoTWSutVMUP"
    "MfQ0)iA)ddeCED9CE4ztug6e7kW9KuKKiA8rdnEiE4HrujihFbA51)6iqVLSgpD7Jjglc)m(nv0ODu"
    "qKxREXeEkPx7MewgEeVqFExSh4shbEhiEY5bES9dt54hCUUD8dWzacEG0iHW5w)GS7Eh5CGuvbhYGI"
    "2qwuWgKtbkRvugMofmtffyq9z3hKZHiHiMotnLERyidxEDLdbKuy5Cc2UkEqE6hZU4Dcf4O8wJnN3I"
    "m01qDrUjL9I8Zkm4pQh4JbFC4kWNGYD)afH3J8ITqpRDAjb9AFf4Z4wj8PXIRVkMU)SWNJY7zmEx2)"
    "N3LVdFb4lcFjzqQMHjLsJK1El16Od2LqBsJNSTrGVCk4RGey4zqKhEQ7g(AWxhEAz4zHRcFREHVn8D"
    "GVb8nHVRh475qBOSPqinhEoKH44zHErulP14z1Wih86g5H8cFFz4h4bk5qAsvxRbyVflEAgb6b9Yyp"
    ")NdqjoRiIpiek)OrBqw(6jppjJq0e0mLPqjquMcLXCc4nrzrUuL76QxBgcXOpAl728uMRmJUGKIZ8G"
    "mQafQwpHuR6K2S264ONkW4vmAYrxlySKjJnsDQBMXgl5WrIg6LkNvvVWGMKlNNOjwm(T02deOthBl6"
    "xSc9JbCFqgUfOru3HYoTvgdlsXNPAz6WdZEQNJuIECfxULObRX8h1YoFLrKzZSIIpBxKuwrCgnu2JJ"
    "DIjypUsq6HYSbgwb)YMyRwqNNHbEQEBqkUgLePJmU2tdpDkufGVMzRBvlsZqMrfA2GWZnkLPr5Ti5S"
    "3srILPNE6AOaQZBsPpp2(35eWhX7cvytPaouDQnuDA9iDWpuMUB3ycgsSO8lkpRkbdEE5DC)CnYdHF"
    "0nbDd(Xv9o)jVe8tRWLGFg8BKHFb8lHF1rGFTh4fCo5FohSIh43ld)oo43Yb)HMG)4wepDGV)envEl"
    "D1bQ1qlOErNRkcQ9wA6Zku0CI(TsosRvX3Ztrvx8frAhnbeuzMiR1w0fxWRDa)41EBaoRx1V7MDhtD"
    "E5bFqS46WheZq8brgeFquABGpiFetPUacYVRVqlCLsmN6TElfDSOdoB8e2t03fDXekEI4cIWRr2DJQ"
    "xwd0TDlCQ5E)kXYaKlsRbI7Wt3XkaRTWzs(0JN4CDro3L7QkEfHIsoWff4AOW55L3CCzN4y(YoUS7s"
    ")z2nvsRyTq90)HA0NjwaPZhZQFJhnUYnVpJlJGQkUN)YnV)sChR6RZGrvU9w7j75M0E8PRcSp622GX"
    "9ItHh1BF7jNTULnpV8RW1YqU6oMOXWfbXcZ43)qfWMkRIldtrJGo4ccpvXfx80bEyqE9vmncj3iLSn"
    "Q05vfYyRxhZJ0Os2m9OpMv0qtBeUZDjLSjwhLSA4Y2VzSxl3PmRlHgfYu6iNARMr7R9(jvX1OBxHS4"
    "16uElcoBs3y71PCvGiwJDkNR4KKCzT9pQA4TENY7kwlVkPtz2tlUR0PC0U9xql0a8ZgU7Q4v8TvNYB"
    "x)LxZ1P8On6VC2oteDS0xuVTrlUB1P869Qyup0Eg)BQXpFJat)D7FSj7POvK56E3Y4FZbM9C(VPFhz"
    "x2iW8DhFI56W(Svb2e3eVJSBgWzpN)gQWs2OZFhdymERJvW)Ck6BdN)dT37iB3)DK5F4zN(IfStKrs"
    "SkEn22Z5)q758VPo)J3ObZKpQsU2ns2DuLr))47iBlkHT37iBl9oYMrnEBrkmq4OZNOkWEHDW7iRZa"
    "75W0yjwR30omtu1HPxhhgIuE)5s0t39P7FphMTrA21HH(tqSZDllM45SlK8cTnM0q1ERmtwXIP39Sy"
    "2QaZMyXCrxIFvlMjgLCXaeRe8JyT79WLuTR9Qy2GEY2nRyK7CUSsJMjr3MJwfIF73GkMMN9pprZwg("
    "kqeMH(lQBkrDjIOVZkKLOzF)4he6pHvPw)Fa"
)

# ============================================================================
# v0.5 - fifth agent edit (2026-07-02), live feel-test feedback on v0.4:
# v0.4's flat 3px icon-to-icon gap read as too tight for the 40-wide
# combat icons (Proc/Rotation/Power); even v0.3's older 8px flank gap
# still read as "quite large". Landed on two fixed values instead of one:
#   - COMBAT_GAP = 6px for the 40-wide rows (Proc/Rotation/Power)
#   - FLANK_GAP  = 4px for the 30-wide rows (Buffs/Utility)
# Both still fall inside HUD_DESIGN.md's small-fixed-gap rule (a 40px
# icon's own footprint is 6-15% larger, comfortably under the >10%-of-
# element-size red flag once you also count that these are two-tier
# scaled values, not a single "one size fits all" gap).
#
# Also tightened the two "structural" gaps that were left alone in v0.4,
# in direct response to "the horizontal gaps still read as quite large,
# instead of being compact around the mana/resource bars":
#   - vertical row-to-row gap: 10px -> 6px
#   - group gap (Power row's outer edge to the flanking Buffs/Utility
#     footer): 10px -> 6px
#
# OPEN STRUCTURAL TENSION (not resolved by this version - flagging
# rather than silently forcing a number): even with FLANK_GAP shrunk to
# 4 and GROUP_GAP to 6, the footer (Buffs/Utility) still reaches out to
# +-205 from center, wider than the 350-wide resource bar's own +-175
# half-width. Six 40-wide combat icons plus any reasonable flank group
# will always be wider than a single 350-wide bar - gap-shrinking alone
# can't make the footer sit "inside" the resource bar's footprint. True
# compactness-around-the-resource-bar likely means widening the resource
# bar to match the icon rows' real width, not just shrinking gaps
# further. Left as an open question for next discussion, not guessed at
# here.
#
# Deliberately UNCHANGED / explicitly deferred by Battlewrath ("that will
# be 2 steps away"): Proc tier resized to 40x20 (distinct from Rotation/
# Power's 40x30). Not applied in this version.
# ============================================================================

TEMPLATE_SHADOW_V0_5_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4OSPje10sSDtAsi0QgAcXfART810jEATSLJKRTK8kzh7qOwR29iTR9QD3S7kllt"
    "5sDHIHceWaLRfkM7qshqdL7xkMc0HHh(hnmaVamJNoTV0NYt8i)NZUs2sXoj(cDM2A9G8(F05SNZ5)"
    "77)77S7ypJuF26LQxAoFlLs3uIygqqCsjtDdJ9hqvzMzemL8Lqxx1wXWC6OPtBrSd9qN6WnSJrn)pM"
    "fCB45d9FVW9CR)9NVOGMOSUzmDfn7u9emsIG8g73swWKi1NPqwYaKPiQjl6mr9ORQB2VhpE4mfeTv0"
    "1SAN3YwW02BafnfBVPsJ)Xs27S2MkzYqmToYjmDV8jwqIKkx60jkyqmdfCGy9n8abSXaEHCMc(N1YG"
    "OQgwYY7sw5sHZPMDCS3ktxC8E6oEIXJNOB(ebYHtskdvHceZkDlMjb7gF8ybhyaEwlPcreuTL51WLV"
    "L35ZP5Ue8EfCpsm1euhbxA4Q)YZlOPKvGUrAh82huxanDnYIeblsCBtIwgB59uscxE0EmoDXAAre11"
    "KSML2h6wb8fiRGIgowWhCx7bog8oG7gVCF12Yc46LNKHMZ8gqvxqQ9a4ww8G8zZHaLxErvblRdcn6n"
    "GLYme6fLs5cRozDooUyCnDFTXBjkOs4s5GiYl483Gszig1f)c5qGZxF5uv9DwzfBYcMSPKUs5ZyQNZ"
    "WT7XX54Mw05AhcXExWwxCkN8YBzQZFmfPRKGKfZ12KXr6GKE(IPP8bmXiylWDfhAdJIqV7PI3dFWGr"
    "kjKZgBoQbJC41L2ewdNaUuyMlTsgV(ZPiv0F3zACqToudDMjM3IOMMX)GDVan7Q4oyfT06MoWJxEbv"
    "dzboJ6XoyBQRQsK6rwrvcrPN5qbguqtWOHyQcIezDvCg9zsS0Zjsm2FcfmQnFwQ62(IzQlwALn4VQO"
    "wQkQ1QIARQO2nUnwyZoH862SvzPv2O)QIAPQOwRkQTQIA34WSq)URz98yqQC22yoP0k)f)vf1svrTw"
    "vuBvf1(sSOw8falWS81s1H(noklUvFXTf0KOAj5SvuvSl4RNEVo)Al1l(mhAUoxWYqWCYZQizlFGfu"
    "qalUEotrYr3b8aElkinrolBI0GctVZLdu02jSRrVPM7O17Rn4MGDpFkbhXg)97j0d(VyF(3CCLy35Y"
    "PBpg1vv8G6sKaDpCIOxHw5qP7AsvuSy1oWTCRNaU1xEPCwusTE(UtzPBMkjwQEq42GdWAxG1g9ELeo"
    "cpl9dh1RXTvEmH1e1ZQOLHkYKCEd6Vtvg8an4foeCy8oD7Zs7lvRkzj6vv6ts4Tc7hE7EnQJQEofjH"
    "JUeDUU0oyzQXflxRZTertiLk5mMcskOOM8sgM6zqATLt28Eo6o2jCNoYwvl9C8RVyuaBY02YZwojtZ"
    "XV4HOFosOh8v(h0p)touV2sWMk(rKDq0k6qClYIDeogZdCI(piuxjuGB58UBdybmXPH5UDJ7IoRJZ("
    "YPWECJXTvYIjitIOcv4HB(kD5yhhTZyroQplB9SKtRvenenAG1ck9OtvlezmVaDJHxXzYuMMiXA8Xm"
    "U71AnOsYiiwy80Q66MYlY6aLBQKUaSBOotCVqBRKJS3yoBDplW63Yy28U3ynBJ93NPYm(gkNGevV0x"
    "IegnUwtTub0PsrCCBzeEP6xfmQFf7C3j7O7WzvnfMPqErYsSO8Oa7znfmM9SUxuQYsGklhicAOzChR"
    "1m7e5X4WRshCUGN2pPfD22itgt4leosKG8JpqW(sS8KrnuoSB2zu3Stv7c3g5MRHvz20CVajPtFSJR"
    "bfyanmdicVp4rH3)JbpMh4dsbc4dbZYs1WJdFy4jqnL5Gpg8rtcFwo4IfDwz8HptOeWN5WW8EGpo8K"
    "PKjkzKTVt2InNjXP(X)aXheEN9b3d1Qfoj975PfRA4rimLH3fTHLy08aQenjAnQ)U7TxJ9JDQBxzlM"
    "kMmW5jaT2vg6eofChxgonoWS662YXCRytw7OuWo3Sj9Gpyji0bNrdzClZJAs)MjNTqOO8Hpx0ij6EG"
    "5zAdwkseENn3EXcFVWn7f2NxNAXeo7nJtgMEeN0Or457raPVAzciyE(HdFVlhDVXPdOiByHyPMUmDt"
    "nZw(8JO9p0BGz01Z6HN1rzOn8ubUdsrsIOXhj4ib5HherLaC85PLxV0bGUkAnsQwgwmAy(jB2urJEI"
    "cI8k1lg1tr9L3KWcWd5f627CDcN)aW7fXtopWJStyCh)GopLJFa2dqWdKcjeoB99X29oY5aPIcoKgf"
    "THmOGniNeuwPOmmrsyYYkWG6L2bK1HiHiMotnLUvmKHlSQYHaskSCgGTRIhKJ(1uZD7qEokV14AZBr"
    "g6kOUi3KYEr(zzg8NWd8jHpfCr4tt5UFKcWhqEUgOJAJwsqV3xe(8UvcFoS46BGP7Va8fP8EgJ3L9)"
    "LC57Wxg(kWxvgKw2WKsPrYAxfBCO(AxOjPrs00GWxlj81rcm8miYdp1DcFt4BbpTmCj4YW3Tl47bFF"
    "4BdFh4h4b(Ho0gkBkisZHNfzioEwOxe1sAfEw10Y(UQwoTx4hjd)ypqrhstYQoAaE2I5ooJa9aEzSN"
    "xD3uIZII4dcHYpA0dilF1KNNGriQdQNYuOeiktHYyoc82OSixQYDC5RmjHy0n9i728uMRmJUGKIt8a"
    "mQafQwnHuRQK2SUXXrpLHXlAuNJUwGOjseDWQu3mJoCIbchj4lxkJQE((mjxihrtSqSD1095VnhBl6"
    "pSi9REDFqgUzPru3HsohRmkwKIpt1c0MhG9uphOi96YUCZtdwH5pQLDMYTiZ6zzfF2QiHSI4KAOShh"
    "BGXzpUsa6LYSggqb)X6yZwaNNHbEQUQrkEzkjshzCTNgE6KOka)YMTUvTindzgLPz9bp7quMgL3IKZ"
    "UkgoA6o7S9(9RoJjL(8i7CJtaFiVZwMnLe4o9Ewn(g8tKPl01MBHCkk1IsXQWTGNtEdFuUAPGWpDtW"
    "0GFwfBZF(ld)IY0i4xc)Ez4xd)g43Ea435bEENb)R4Gf9a)rz4f4G)ah8NQd(Z3GqPdY9xWS453fRo"
    "6fDUJiw2vXjoPqbZr7XkXGnwbwpdfmDHveGDKcqSK5DSs3qxmH7r9SEaLvRG3DrUHzlV2GligCv4cI"
    "viUGicIli6SoWfKhIPtxWa51vxBfQCvLtjwxfJmCK(MkwC7r7(CU4bflrmbr2vO0Uw1jRa2wVfmlBy"
    ")6r6pYfPC)7FJx0VY6LX4tns8t1o5uxO9kqvyka5GuumRM6LNt(AdjBe)XxZHKTwMpZCPCAfldQM53"
    "FTUkr9lDMOw9y8WXu28UkmYWtUTBYM3n5vUkZev5wASZmNAm7rMOcA(WRxZKtVhgM8U376t5AvltEo"
    "5xNlBHe0nm7IbjcI5NS5M7ppEKXkqYauGiGdKGitfiXfkDqggoxDzsTqY1t5ATQxEdHS1QDE4bRv5A"
    "Yo1h2ksWjmc12wKY1531AHjR)ZC9MxPl8aR1QDP0Aw1gnJ0Dl9qQGNrwVAx3)6btUgN1A7ZbxbdIw7"
    "5GZwyms2m2npKAOB8ZbVL4M8gIZb)KBnNdoshnNxlyV8tfQJkqvS115GxVUjVP7CWdvRBYjBlEKHtD"
    "o9MgQWwKBYRunKCPBzBd(RPbpFTqspD08WJ1zbRWt3XweKu7B6AzmzBd(n1B66cg(NPJyJoDR2NScE"
    "gFd(MU2mGY2o81uuLOwh(w71yKghoFZtROFJ7WxR212VPRnPdFZdm1eNlVD80sIvGQHxxo8Rx7K305"
    "WpsT2jJ9WkzBXirhrug6)pVPRBqHRTFtxxN301KQXAkC(EdfzM4vqZZUEntE1BEBZKQlPACtBMmAfZ"
    "KUCmtis5AoB8o7OB9M32mzDKMDnt(R7DRXnjww78joBtdl1)YVELXk7M012Uj3OyY1Wn5CUC(kUjJo"
    "e5C(jwX5h0AlYn5f2721jREDYlDZBn1jYTnDgPHshVdZHQaSVNRtDs9t93gTEldF5jcts)3CBCrDjI"
    "OVtkKHOzFV4xe6)xPsn()a"
)

# ============================================================================
# v0.6 - sixth agent edit (2026-07-02), live feel-test feedback on v0.5:
# both v0.4 and v0.5 left a visible "dead-air" band where the 350-wide
# Mana/Placeholder bars sat narrower than the footer row (Power +
# flanking Buffs/Utility, which reaches out to +-205) - the bars looked
# like they were being undercut rather than anchoring the stack.
#
# Widened Mana/Placeholder from 350 to 410, matching the footer row's
# own outer edge (+-205) exactly, so the bars now read as the visual
# base plate for the whole HUD rather than a narrower strip floating
# under the widest row. Proc/Rotation (the narrower top rows, span
# +-135) still sit inset from the bar's edge - left as-is for now.
#
# Battlewrath's choice, from three options (shrink bars to match
# Proc/Rotation and free the reclaimed width for a later element;
# extend bars to match the footer; or leave bars and widen Proc/
# Rotation instead): extend to match the footer, deferring what (if
# anything) goes in the remaining gap above Proc/Rotation until there's
# a concrete thing to track there.
# ============================================================================

TEMPLATE_SHADOW_V0_6_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4OSPje10sSttACi0QgAcXfART810jEATSLJKRTK8kzh7qOwR29iTR9QD3S7kllt"
    "5sDHIHceWaLRfkMY9KoGgk3VumfOddp8pAyaEbygpmTV0NYt8i)NZUs2sXoj(cDM2A9G8(F05SNZ5)"
    "77)77S7ypJuF26LQxAoFlLs3uIygqqCsjtDdJ9hqvzMzemL8Lqxx1wXWC6OPtBrSd9qNQHdSJrn)3M"
    "fCB4fc9FVW9CR)TxOOGMOSUzmDfn7u9emsIG8g73swWKi1NPqwYaKPiQjl6mr9ORQB2VhpE4mfeTv0"
    "1SAN3YwW02BafnfBVPsJ)Xs27S2MkzYqmToYjmDV8jwqIKkx60jkyqmdfCGy9n8abSXaEHCMc(N1YG"
    "OQgwYY7sw5sHZPMDCS3ktxC8E6oEIXJNOB(ebYHtskdvHceZkDlMjb7gF8ybhyaEwlPcreuTL51WLV"
    "L35ZP5Ue8EfCpsm1euhbxA4Q)YZlOPKvGUrAh82huxanDnYIeblsCBtIwgB59uscxE0EmoDXAAre11"
    "KSML2h6wb8fiRGIgowWhCx7bog8oG7gVCF12Yc46LNKHMZ8gqvxqQ9a4ww8q8zZHaLxErvblRdbn6n"
    "GLYme6fLs5cRozDooUyCnDFTXBjkOs4s5GiYl483Gszig1f)c5qGZxF5uv9DwzfBYcMSPKUs5ZyQNZ"
    "WT7XX54Mw05AhcXExWwxCkN8YBzQZFmfPRKGKfZ12KXr6GKE(IPP8bmXiylWDfhAdJIqV7PI3dFWGr"
    "kjKZgBoQbJC41L2ewdNaUuyMlTsgV(ZPiv0F3zACqToudDMjM3IOMMX)GDVan7Q4oyfT06MoWJxEbv"
    "dzboJ6XoyBQRQsK6rwrvcrPN5WbguqtW4aXufejY6Q4m6ZKyPNtKyS)ekyuB(Su1T9fZuxS0kBWFvr"
    "TuvuRvf1wvrTBCBSWMDc51TzRYsRSr)vf1svrTwvuBvf1UrdSq)URz98yqQC22yoP0k)f)vf1svrTw"
    "vuBvf1(sSOw8falWS81s1H(noklUvFXTf0KOAj5SvuvSl4RNEVo)Al1l(mhEUoxWYqWCYZQizlFWfu"
    "qalUEotrYr3b8aElkinrolBI0GctVZLdu02jSRrVPM7O17Rn4MGDpFkbhXg)97j0d(pzF(xCCLy35Y"
    "PBpg1vv8G6sKaDpCIOxHw5qP7AsvuSy1oWTCRNaU1xEPCwusTE(UtzPBMkjwQEi42GdYAxG1g9ELeo"
    "cpl9dh1RXTvEmH1e1ZQOLHkYKCEd6Vtvg8ahWlCyOb8oD7Zs7lvRkzj6vv6ts4Tc7hE7EnQJQEofjH"
    "JUeDUU0oyzQXflxRZTertiLk5mMcskOOM8sgM6zqATLt28Eo6o2jCNoYwvl9C8RVyuaBY02YZwojtZ"
    "XV0HPFosOh8v(70p)douV2sWMk(rKDq0k6qClYIDeogZdCI(peuxjuGB58UBdybmXPH5UDJ7IoRJZ("
    "YPWECJXTvYIjitIOcv4HB(kD5yhhTZyroQplB9SKtRvenenoaRfu6rNQwiYyEb6gdVIZKPmnrI14Jz"
    "C3R1AqLKrqSW4Pv11nLxK1bk3ujDby3qDM4EH2wjhzVXC26EwG1VLXS5DVXA2g7VptLz8nuobjQEPV"
    "ejmACTMAPcOtLI442Yi8s1Vkyu)k25Ut2r3HZQAkmtH8IKLyr5rb2ZAkym7zDVOuLLavwoqe0qZ4ow"
    "Rz2jYJrdRshCUGN2pPfD22itgt4leosKG8JpqW(sS8KrnuAWn7mQB2PQDHBJCZDGvz20CVajPtFSJR"
    "bfyanmdicVp4rH3)JbpMh4dsbc4dbZYs1WJdFy4jqnL5Gpg8rtcFwo4IfDwz8HptOeWNPbyEpWhhEY"
    "uYeLmY23jBXMZK4u)4FG4dcVZ(G7HA1cNK(980Ivn8ieMYW7I2WsmAEavIMeTg1F392RX(Xo1TRSft"
    "ftg48eGw7kdDcNcUJldNghywDDB5yUvSjRDukyNB2KEWhSee6GZ4azClZJAs)MjNTqOO8Hpx0ij6EG"
    "5zAdwkseENn3EXcFVWn7f2NxNAXeo7nJtgMEeN0Or457raPVAzciyE(HdFVlhDVXPdOiByHyPMUmDt"
    "nZw(8JO9p0BGz01Z6HN1rzOn8ubUdsrsIOXhj4ib5HherLaC85PLxpBdqxfTgjvldlgnm)KnBQOrpr"
    "brEL6fJ6PO(YBsyb4H8cD7DUoHZFq49I4jNh4r2jmUJFqNNYXpa7bi4bsHecNT((y7Eh5CGurbhsJI"
    "2qguWgKtckRuugMijmzzfyq9s7aY6qKqetNPMs3kgYWfwv5qajfwodW2vXdYr)AQ5UDiphL3ACT5Ti"
    "dDfuxKBszVi)Smd(t4b(KWNcUi8PPC3psb4dip3bOJAJwsqV3xe(8UvcFoS46BGP7Va8fP8EgJ3L9)"
    "LC57Wxg(kWxvgKw2WKsPrYAxfBCO(AxOjPrs00GWxlj81rcm8miYdp1DcFt4zHNwgUeCz470f8DHVh"
    "8TGVn899a)ahAdLnfeP5WZHmehpl0lIAjTcpRAAzFxvlN2l8dLHFKhOOdPjzvhnapBXChNrGEaVm2Z"
    "RUBkXzrr8bHq5hn6bKLVAYZtWie1b1tzkuceLPqzmhbEBuwKlv5oU8vMKqm6MEKDBEkZvMrxqsXjEa"
    "gvGcvRMqQvvsBw344ONYW4fnQZrxlq0ejIoyvQBMrhoXaHJe8LlLrvpFFMKlKJOjwi2UA6(83MJTf9"
    "hwK(vVUpid3S0iQ7qjNJvgflsXNPAbAZdWEQNdwKEDzxU5PbRW8h1Yot5wKz9SSIpBvKqwrCsnu2JJ"
    "nW4Shxja9szwddOG)yDSzlGZZWapvx1ifVmLePJmU2tdpDsufGFzZw3QwKMHmJY0S(GNBiktJYBrYz"
    "xfdhnDND2E)(vNXKsFEKDUXjGpK3zlZMscCNEpRgFd(XY0f6AZTqofLArPyv4wWZlVHpkxTuq4NSjy"
    "AWpTIT5p7LHFEzAe8lGFNm8RGFn8Boi8B9aVGZG)LCWIEG)Gm8ICWVNd(J1b)PBqO0b5(Zyw887Ivh"
    "9so3rel7Q4eNuOG5O9yLyWgRaRNHcMUWkcWosbiwY8owPBOlMW9OEwpGYQvW7Ui3WSLxBWfedUkCbX"
    "kexqebXfeDwh4cYdX0PlyG86QRTcvUQYPeRRIrgosFtflU9ODFox8GILiMGi7kuAxR6KvaBR3cMLnS"
    "F9i9h5IuU)9VXl6xz9Yy8Pgj(PANCQl0EfOkmfGCqkkMvt9YZlFTHKnI)4R5qYwlZNzUuoTILbvZ87"
    "VwxLO(LotuREmE4ykBExfgz4j32nzZ7M8kxLzIQCln2zMtnM9itubnF41RzYP3ddtE37D9PCTQLjpV"
    "8RZLTqc6gMDXGebX8t2CZ9NhpYyfizakqeWbsqKPcK4cLoiddNRUmPwi56PCTw1lVHq2A1op8G1QCn"
    "zN6dBfj4egHABls5687ATWK1)zUEZR0fEG1A1UuAnRAJMr6ULEivWZiRxTR7F9GjxJZAT95GRGbrR9"
    "CWzlmgjBg7Mhsn0n(5G3sCtEdX5GFYTMZbhPJMZRfSx(Pc1rfOk266CWRx3K30Do4HQ1n5KTfpYWPo"
    "NEtdvylYn5vQgsU0TSTb)10GNVwiPNoAE4X6SGv4P7ylcsQ9nDTmMSTb)M6nDDbd)Z0rSrNUv7twbp"
    "JVbFtxBgqzBh(AkQsuRdFR9AmsJdNV5Pv0VXD4Rv7A7301M0HV5bMAIZL3oEAjXkq1WRlh(1RDYB6C"
    "4hPw7KXEyLSTyKOJikd9)N301nOW12VPRRZB6As1ynfoFVHImt8kO5zxVMjV6nVTzs1LunUPntgTIz"
    "sxoMjePCnNnEND0TEZBBMSosZUMj)L9U14MelRD(eNTPHL6F5xVYyLDt6AB3KBum5A4MCoxoFf3Krh"
    "ICo)eR48dATf5M8I7D76KvVo5)CZBn1jYTnDgPHshVdZHQaSVNRtDs9t9xhTEldF5jcts)3CBCrDjI"
    "OVtkKHOzFV4xe6)xPsn()a"
)

# ============================================================================
# v0.8 - eighth agent edit (2026-07-02): corrected reading of "dead air".
# A prior audit pass wrongly diagnosed the gap as Proc/Rotation's own
# width (255px) being narrower than the rest of the stack. Battlewrath
# corrected this: the real problem was never row WIDTH, it was the
# VERTICAL row-to-row spacing - a 6-10px gap had been applied between
# every tier transition on the assumption tiers needed breathing room
# the way icons within a row don't. Battlewrath's own reference edit
# (still rough, explicitly "needing to be cleaned up") showed every
# tier-to-tier transition sitting at 1-2px - hugging, not spaced - and
# Luxthos Mage (Classic Era)'s real aura (screenshotted directly)
# confirmed the same: icons, bar, and cast bar all touch with no visible
# air between them.
#
# This version locks that in as clean, rounded values instead of the
# reference edit's messy hand-dragged ones:
#   - ICON_GAP = 3px, uniform across Proc/Rotation/Power (was split 6/4
#     in a prior version - the reference edit showed one consistent 3px,
#     not two different sizes).
#   - FLANK_GAP = 0, GROUP_GAP = 0 - Buffs/Utility icons touch each
#     other and touch Power's outer edge directly, forming one
#     continuous row rather than three separated groups.
#   - ROW_GAP = 0 for every vertical tier transition (Proc-Rotation,
#     Rotation-Mana, Placeholder-footer) - there is no separate "tier
#     gap" convention; tiers hug exactly like icons do.
#   - Flank icons (30x20) are TOP-EDGE-aligned with Power (40x30), not
#     center-aligned - since they're shorter, they hang flush with
#     Power's top rather than centering on Power's middle. Confirmed by
#     the reference edit's own numbers once cleaned of manual-drag noise.
#   - Bar width -> 375, matching the footer's real continuous span
#     (Power + flanks, touching) instead of either the narrower
#     Proc/Rotation span (255) or the earlier over-wide 410 guess.
#
# The 255-vs-375 width difference between Proc/Rotation and the
# bar/footer is NOT something this version tries to eliminate - it's a
# real structural difference (6 icons vs. 10) and the Luxthos reference
# shows real auras have exactly this kind of width variation stacked
# with zero gap, not uniform width forced by padding.
#
# APPROVED by Battlewrath (2026-07-02) as the settled baseline at the
# time. Superseded by v0.9 below (resource bars shortened, two new
# flanking blocks added) - v0.8 is kept here as the last "pure scaffold,
# no new elements" version, not because it's still the active target.
# ============================================================================

TEMPLATE_SHADOW_V0_8_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4OO20wLqj2U5kHw1qtiUq7yjFnDQMwlB5i5AljVs2XoeQ1QDps7AVA3n7UYYYCT"
    "gOyUgWaLBTqXChA6aAOC)sXCRdp9pEyaEbyg)q5fEkpXJ8Fo7kjlf7elBtPny9G8(F0z3ZLVV)VV)D"
    "x7ASMZ1SyZIl4D10AgIeJG8ctlAOPRFWGkYZnhVHO3KAAkwY6gZgltgtIv4h9ShRL9mUX)WOOtdVy4"
    ")9LU)78p)IL4vfK0mIRjRALUVqrtgIt)GMs8geXbm4ZrgImdrjvj7bQpnfnJbD5YLBdEblznvZU4mT"
    "4nS8euwv2Yt6m4FmL8mVLHC2SedZJFAdNdFYLejPZNjtYI6eJWHgk(aJouqlmGJpVbV)5n1jkkren9"
    "SQz(04yQALa7T8SLMSVEtKCYej7LlzW84GKwxHViXOs3IBqWUXLiEOHgIJ1s6WeEfljovC6B6zX8Qo"
    "tbpxfxJedvELXWPgo7VYI8QY54PlKUapdanfuvtLSmH3KKWYGOM1s62wreNE0EmjDYAyse0ufnNN2h"
    "6sb8gmhVSkEUGx4EVn4KWBcUp8WduFllHZxosw6EMNGkA8IDfexYchMlxEeO8WjOWBAEyOvpbnLNJq"
    "pyL0oWQ9UUB3UJ7UThStotbEfI702iI0s2)nKywIEtjUuEe48oqEffVNxs2ISKbBiPZuUSgA51D6Ec"
    "CmU1LTp2MqChlzPjmJ9(YTpZfpPS4vtsYH71wKjr6GOwHszO8bCJH3I39vTPnmkc9QNorFCHcfDf(8"
    "wyZX0zKdpo0MiQ4a4onUZLroRh)5Lfl5V3SToSA3kHp3ulAsuYW4FW(wIU7k7CYYQz0mSHhpC8k6s8"
    "U1Bg7GLHMIcrSpjzfreLE2JgCyEvE9wIRWlqK0uWr0RbXulVar)GjLXOo9AQOz5nUHMWkRTb)1e1En"
    "rDutuN1e1L(DXc9zhYPzXMLRS2g9xtu71e1rnrDwtux6hJf63zoRvadsN3Yc3twzT)I)AIAVMOoQjQ"
    "ZAI6Avwu7EdIjyMEBV2q)6NGf3H3ew8QIuTK8wYkYwf92x)3GFT9MfE2JUqplzQZBm95LfTKo0sYiG"
    "LqlVHa5e7bEipL4fNkVPfrCy(z3B1az19c3Y43QVo9)GDc3kSVftZBl24FqxHFK)g7ZF3T7vyx5YB3"
    "U0BQM4H1ejb7D0KXUknZHs3vfROyXYDGx3DEA4oF5vZBsj1Af6nTPMr6uyQ6HH7coeRDEwB0Rvk44C"
    "STF4eE0VRYNtevbTCYQzPImPwuN(7uLbxqlEGJchdVshzEAFPAvPwHEuL(KcE9WbH3Oh9MOQNZqsAR"
    "lrhRNBpSDQjfkNR7EvIkFAfY5m4fLrrnPv1n0YI0At7DZ7)e7zVW9ylBvR0ZPUXIrbTiZAjnF5nz6E"
    "8lDu6NJh(r(N)f6N)QBuV2K3Ik(rKSr0k6qUxMfBlCmHl40dEyOPvqbUQ77onGjWe7gw4i63lDuNK9"
    "LDI9K6tAjNd3GmicYuHh3lwPlN8uODglYw9PQ1ZQ2Twr0qqVfwlO0JgvTqGX8c2lgEv7btEwIiRXNq"
    ")(2O5GcjlVqXjZOOPziTmRduUPCMIW(GMmW1cTTvSL9MWEP7Ajw)QIzl6CHvT0p4agYZ5DK88Iu9sV"
    "jtQ36gn0IfrNkzHjTKq4LQFvuV51SYDgStSh7z1m4ofYlsTclQakWEEdE95pVZbRuzkqLLdgfn00V7"
    "nAKTJCPFS1Pd2hWr7N4Y2lBKjJB4lfjA0qCtouObswDWOgkhZz3zCNDNAwfon6EHwwNrt15aKKo7jp"
    "LkuKb0WCGa8oG3j8UEc4jCbVhkqaVxyE2wn8(G3p8KOMYcWhc(GPGpLB4YLSNzCrox4KWN8yWIUGpm"
    "8rslrKZkzDpSjBEdID(J)Hsmm8MhaUFQvlCg63lstwvXsimKG3cTHvz08GkevrAoQ)E7VF9dIDQxhz"
    "lMkMe42vqAURe0dCw4UVc8W4jMttZskUtgBQ6plzSZ(mOf(GPGq3U1BjRtAEmd63m5SLchJlYfIfnz"
    "VdTitBWuwKWzV4UdmX3dSFpWb8yNlM0ETPFMi0sCYGgHxSpEK(QMniVXfhnYdun6bsqpHsStlmBRjG"
    "HZwZ8LRFeT)H(doNMwoxCSokbDIvf4CsYIIevUOHgleh8iiQe0nxbA6L1rGaLmhlD7Jkelc30(mKvP"
    "vuqKwREX4UkPvDrclbpQhOxpl0dCXdbVDepD7cE89ctA7h0v32(bypaExqAKqyV0paB1BlNdKkk4qg"
    "u0gYIc2GukqETIYWuPGPlRadkp3EGC2ejeX0yQP0LIUeCP1voeqsHP9jy5O4b5PFnZchbk4MYB1V(8"
    "wKHUgQlYnPSxKFwMb)rDbFm4Jdxg(euU7hOi8ULwOf6zTvtjOx7ldFgNmHpnMC9vWT7pl85O8EgJ3H"
    "9)5D47Wxa(IWtlbIvnmPuAKSgOuRJmqx8TjowY2gg(sPGVmsGHNfrE4PUh4RcFn4zKGNdUc8ndaFl4"
    "BdFD4BaFhxW31M2qztHqAo88idX2Zc9IOwsRXZQUwoW10Yd7b(EsW33fuYM0KQMsdWAlw4umc0d5HX"
    "EE69rjollG3iek)Oslqw6AjppjJq0e0mLPqjquMcLXCC4nqzrouL7(kxDAcrVxAj7wCuMReJUGKIt)"
    "qmQafQwpHuZAK2m384ORYW4L1BYwxlySKjJnCnQBgXgn5qrIg6LxjRIwHbmixkprvOy8BPTh0FN22w"
    "0Fyz6x97CJmUNNgrDhwXUSYyyskEpvlrBEi2D9COs0Jl7YTinynM)Ow25k3IeRNLv8zZIKsYctRIYE"
    "UzNyc2TReKEOeRHHKXFSj2Of0(EyGNQ16KIRsjr6iJR9mWZKcvb4QA26K1I0mKzuMMna88JqzAuEls"
    "oduksSm90txd6xzodk95X37wNa(OEMVmBkf4gvNAdvNwpsh8dKOZ2nMGHelk)IYZQqWGxqAlxpx98q"
    "4hUnOBWpQI35p(LHFszUe8tHFTe8ZHFb8lpe8RCbVO9j)ZCdl7c(DsWV1n8BCd)(MG)WMepTHV)iDR"
    "8w6QduRHMq9s2xveuduAQZWx0y8(mtoCRvW3Zrrvh8frABnbeuzMiR1w0bxWRTFF41UbaN1l73zYUL"
    "PoVYGpiwCn4dIzi(GidIpik1a4dYhXTuhab531MOfUCkMD(wGsrhn6aZepH149EbhmHINiUGi8AKD3"
    "O8L1aDnAItv37xlMgGCrAoqCBE6wwbyTjotWLESeNTlYzVuxvWRiuuYgUOaxDjoVG01hx2koMVIJl7"
    "S0FMDt5TvmxOw6)G17ZeZV45Iz2N(JfxE77Z4WiOQI76VS99xIBBvFngmksT3Apzp7ewJnvfG9XAyd"
    "gNlofEER3EJjNTUPnVG0Rk1YcSP1YqU6wMOXWfEHct7Z3GfWIkRGldrrJG24ccpvWfh80gEyqETzm1"
    "dj3iLSnk15vJYybAuzS1RI5HRxjB6E0g1mAOP0d35oKs24RJswvCPXlg7MjLSanyLYSQeQxitUJCkT"
    "AeT327JubxJ2OczXRwP8MeCUovJDttLYb22vkhR(kLZvCcsUSw(grj8MVs5DeRLx9wPCGgPsz2DlUJ"
    "uPC0U9vqnu)CZeU7k4v8gQs5g1F51yvkhyBxP8i17VCMoteD00xqRTrkUtvP869Oy(x7FxJ)RRXpx9"
    "atFD7B0j6POzKz7ENY4)6dm768VTFgzxs3)CDhF8z7W6mva2eBJNr22bC215VUmSK1783r)6J16Of8"
    "nRS2M35VEHSBYEgzb(FZZiZ3qZm1fkyLiJOqf8A0gY5Vrny()oN)XQ3GzIhtox76j7oQ8i)x8zKTjL"
    "WUP)zKfyh5zKnTs82IuO)WrNlrfG98BHNrwh(l)wy21HzN7TWmEfhMa2omeX8(YLONU7vZxd8wy2)U"
    "VfMuLlyTB)7uwmXZzvi55BBuXbR(uzMOSftGn1RHz)7(AyUUwmxWH4xXIz8rixWpXmb3WM7C3Cjv7A"
    "3mMnOMSDYmgPoNnR4izs0TXivG432niJP5z(tJ3SPU3ce(PP)h1nPGMirW7z4ZsuTEa8lc9FHvXw)p"
    "a"
)

# ============================================================================
# v0.9 - ninth agent edit (2026-07-02): shortened the resource bars and
# used the freed width for two new flanking blocks, per Battlewrath's
# request.
#
# Mana/Placeholder: 375 -> 255 (Proc/Rotation's own established span, not
# a new invented number). That frees exactly (375-255)/2 = 60px on each
# side - and 255 + 60 + 60 = 375, so bar+block+block reconstructs the
# footer's full width with 0 waste and 0 new gaps, matching the hugging
# convention locked in v0.8.
#
# New children (26 total, was 24): "Swing Timer" (left, x=-157.5) and
# "Side placeholder" (right, x=157.5, reserved for a not-yet-decided
# future element), both 60x30, vertically centered on the combined
# Mana+Placeholder stack (y=-160, spanning the same 30px height as the
# two 15-tall bars together) and touching the bars' new edge with 0 gap.
#
# This is a positional placeholder only, same as every other slot in
# this file (see AURA_BLUEPRINT.md - nothing here is a wired-up trigger
# yet). The "spinning timer/counter in the middle" visual Battlewrath
# described is a content/animation decision for when the real swing-
# timer aura gets built via the blueprint process, not something this
# scaffold encodes.
#
# TWO BUGS CAUGHT AND FIXED HERE, both live-tested, both about copying
# an existing child as a starting point for a new one without resetting
# everything that needs to be unique:
#
# Bug 1 - controlledChildren not regenerated. The first cut appended the
# 2 new children to the child list but never updated the group's own
# `controlledChildren` field, which still listed only the original 24
# ids. `encode_group_import_string` only auto-derived that field when
# absent - since this version started from v0.8's decoded `d` (which
# already had a controlledChildren of 24), the stale list carried over
# unchanged. In-game this threw `attempt to index local 'pendingPickData'
# (a nil value)` in WeakAurasOptions/OptionsFrames/Update.lua:1867 -
# confirmed by reading that file: its BuildUidMap function reads
# `d.controlledChildren` directly to build its structural map, and the
# mismatch (26 in `c`, 24 declared) pushed the update-diff logic into a
# branch that never assigns `pendingPickData`, which gets indexed
# unconditionally a few lines later. Fixed by making
# `encode_group_import_string` always regenerate `controlledChildren`
# from the actual children being encoded, unconditionally.
#
# Bug 2 - shared uid across 3 auras (caught after Bug 1's fix, still
# live-tested malformed: Power slot 1 missing, 3 placeholder-looking
# blocks with 2 overlapping and 1 out of position). Both new children
# were built by copying "Tier 2 slot Power buttons"' entire field dict
# (to avoid missing required region fields) - which also copied its
# `uid` verbatim into both new children, without generating fresh ones.
# `uid`, not `id`, is WeakAuras' real identity key - 3 auras silently
# sharing one uid meant WeakAuras' import/update logic treated them as
# "the same aura" and only reliably rendered one of the three, with the
# others landing at conflicting positions. Fixed by adding
# `generate_unique_id()` to weakaura_codec.py (a Python port of
# WeakAuras' own GenerateUniqueID from Transmission.lua, same alphabet)
# and explicitly assigning a fresh uid to each of the 2 new children.
# Verified: all 26 children now have distinct uids, confirmed
# programmatically, not just by eye.
# ============================================================================

TEMPLATE_SHADOW_V0_9_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4iP20wL02yNM0MqAJAAtioq7yjFVt10yzlhPuBj5vYo2HawR0EK2nE1UB2DLLL5"
    "AnqXCNyUvGcTyUdnqhbdL7um3kD4H)XddWlaZ4hkVWdEYWd8i)NZUsYsXj1Y2T0gSEqE)p6S75Y33)"
    "33)URDmAZ5AwOzH58SCkvDbIEa(0tkORQPTNaYsZmdVUGNeQQYMsA6thntgdIzOt2Zb27ogt)FOx0U"
    "HNp0)5cN42(ZpFjEL0IQ6XuLumt1xWijcYPThdrEDIWa685idsMIiNSK1a1NQSQ(PD4WHlD(0MsQkg"
    "DYzyYRB6oGKIKP7uzW)yi6EwtDPSzj6gh8y62h(4liqsLptMef1i6HcoySbgzWaMyahFEDEFZAOrKL"
    "dly4EzJ8PWXuXmo2BPPlnrF9gpXeXt0lxIa5XbjLMmFrIELUftNGDJlESGdoihRLuHi8YMICk403W9"
    "85vSNcUVmUgj6k8YJItnC2FP55vKYXtxiDcUhaAkGIQczrcVbjUPorjRP4nTKao9O9yc6Kv3GKwvrW"
    "ywAFOlfWtGC8sk45cEG79MGJa3hC)4H7U(wwaNVCKS09m3bKv5f6maUKtVFUC5rGYnxAzEdJ9dT4oG"
    "H0me6blLYgwT21D5YvmxT(GDWzKMxM4kLfIiUG1FdkKLO1u8lKhbopdKxw2ZzeLmjlOZgs6mLlRUAE"
    "n7UhhhJBCrRJTie3YcMQPNYAF5MN6Chrs4Yji5W9AtYeiDqqTqPmu(aUXWBY76Yw0ggfHE1tfVpUGb"
    "JSeFEtS5OAmYHBBAtyfCaCLc35YiL1TV8scL81B2wgsPl5qN68ZBqKZW4FWoxGU7kzFYskzu1TGh3C"
    "8YAI8U0Ag7GPUQSmrOprjzbeLE6dgyiEfET9gtMpnruvghrp6ed18PjA7jHeg1HhdzvtpX0vtV0QBW"
    "xnrTvtu71e1rnrDQDhSqVwHCQMSz5sRUrF1e1wnrTxtuh1e1P2byH(SNZQfWGu5nnX9KLw9V4RMO2Q"
    "jQ9AI6OMOoxMf1MNaycMHN2Qn0N2HyXT7jUjVIavljVPKSKzrp91)lZV2wP4fKuY6jHuoIU2EIljq8"
    "OvfuAo9tFW56EbdnE9jpJKGP4(wqcHZ4Q51tto0oGhYDjEHZN3WKime)0oRgiP4eUHXUrVD47b7aUr"
    "yNZNI3skY3PDe6r(BSp)DxUwIDLldgo0AQM4Hufib6DKerVmnVIMmOiurpJLzb36TDm42EPLZBqP8Q"
    "f6nLHQEQKyI8(H7a2hRDEwB0Rvs4GCmWboKBT7O85ewjTAoCpGkbLCEn6Vt1nCa71nCxWbWR0DolTV"
    "uLSKlrpQsFsc3oSh4UDR1evBDksclvl6y9m7GTtnr6YkbUwMOWNsMCkDEbjuYtCznD1SiP3WA38ehA"
    "hoHdBjQvRW0rF5LQcysM2uC2YBY094x4UOFoyOh5F(xOF(RUq1CdEtQ0ir0crROs5ArwSLSY4oGJD6"
    "9dnTek)vDF3Ubm9My1WC3P29sh1jyFzL2pH2eMirAcnDsAjQSKR5R0LJCu0SJfzPnv1yAzRwRiPq02"
    "lRfuysLQLKMX8c0lgEzRbtAAIaRXht7(VAZbzsw(0fNiJSQQU4ISoq5Mszkc7eAshxl02wYsuCCRLU"
    "Jfy9RkMnV9fwXuBpdOlnJNHZZlqvt9KiHwlxTHwOi6JjLEctreEPjsf1AEvRC7b7q7WAwnfUtH8IKl"
    "XIkGYVNrNxB2ZyFWsvMcur7arq7oT75QnYwro0oWA0bRd4O9tyrRLnYKXn8fchjsqUjgm4ajQoyu7M"
    "dyV7mM9UtnRc7gDn3ExJrtX(aKKoZroQc82zan8oac8oH3f8UFm496aEmkqaZcVp2wn8(HhhMd1u(q"
    "Whg(GjHpTl4ILSMzCHpvOeWN8aWNYb8rGpAkrIuwrZdZMS51jw5p(gm(qWBCa4euJy440VNNMSQGfy"
    "OlcVjAdlZO5bKjkc0CuF92F)A7b7uV2YwmvmrWLJa0CxrOBOh4EUe8W4jMtv1umMDgBY6pljSZE1PL"
    "fHPGqxU02Bw708O60VzYzlekkx4ZgnsIEhCEM2GbQ2YzT4UfmX3nSl3WUDBLlMWATPD8W0cGYGkYNR"
    "pEK(QKnaV(5gj8dun6bItpHsStleBRXVU9wZSLRUeloa6pWmQQ5CWX6Oi0bwZG9jjjiqu4IeC0GCWJ"
    "GOsaxCfOPx)7Bh8xYy0uTns6OH5M0RUKcTEdI4Q1lgZrj1Qls4RcN0n0R756gEB7dMaXtxoGKobEl)"
    "Go7YYpa7bK2biGecRL(UzREl5CiBffCqefTbjuWgoFsyYvlkdYjHCLvGbLNzhGQfrcrSlWutPlfe6n"
    "wt5qWueYBDctzR4bfOFn9C3ju0fL3QDT5TidDvuxKBszVi)Smd(J5a(4WNaUimpL7(bkcVhX52l9S2"
    "OPe0R9fHpRDMWNbtU(k429Nd(8uEpJXBZ()c28D4jHVi8LeHmvnmPuAnrewBz4b6KVvHrt06qWtNe("
    "YibgwarE4jom81GVo8uIW3f(EW3Yp8THVd8nGVj8moGlzrBOSPGinhEwKHy5zHErulPv5zvxl7(kA5"
    "HDdLeHVVd4hyrAsvtPbyTfZDugb6HCZypp5oPeNftJ3Mek)OqlFw8kjppoJq0e0mLPqjquMcLXCq4n"
    "qzr2uL75sxEscrRxAb9MCuMRiJUGKIJ9qmQafQwlHuJAK2mw)4OJYW4f1AYsxlq0ejIounQB6rhjXG"
    "HJe8LwkRSAHb0jxiprjDXy3qRpOVoSSTO)WI0V63(2CCnlnI6oSKvrNrXKu8oUwG28GS7jAFLOhx2L"
    "BEAWQm)rTStvUfrwplR4ZMfjeLspPck75IDIXz3mta6HISgguc)XMyJwaR7WbEIwQtkUkLePJmU2tb"
    "pvsufGRQzRDwlsZqMrzA2aWZomLPr5Ti50FPWrZ0D3DEAFYZOtPpjDUXjGN09SLztjbxO6uRO60Ar6"
    "GFOiD2E1jyiXIYVO8Skem45e3W1Zvppe(rBc6g8JR4D(tEj4NwMlb)m4xlc)c4xcp)(GFLdyrRt(N7"
    "c(noGFVi87Cb)wxWl0e8hwN4Pf89hPBL3qNTJAn0eQx06QIGQ)sN)48f1hRpJed1sf89uuu1gFrK2s"
    "tabvMjYQTfTXf8A7ZlETBaWzTY(TNSByQZRo4dIfxb(GygIpiYG4dIsna(G8rCl1gqq(DTjAHkNIzL"
    "V5VuKrImWuXIBowVN1gtO4jIlicVkz3Rw(YQGUgnXPQ79RhtdqUinhiMfpDdRaS6eNX5snA8E6K0Zf"
    "6ScEfMIswWff4QlX55eV24YgXX8vDCzRL(ZSBkVTI5c1s)pD9(mr9jCQOg9P9OXK28(m2mcQQ42(lB"
    "E)Lyww1xHbJSyBT0D2Eg3C0ZxbyF0g2GX(ItHN38n3yYzRzAZZj(AsTm)RBTmKRUHjAmCHpDHj9690"
    "fWIkRGldsrJaw4ccpvWfB80cEyqETzm1djVCkzxTuNxlkJ5VrLXwRkMhQELSj7wDeJibpVwOo2IuYg"
    "BnuYQIlnEXyxpPK5VbRuMvLq9czsTNtUf9i92wFKk4AKgvilw1kLxNGZ1OASRBQu2)MUs5O1xPCUIJ"
    "tYL107WYHw)vkVLyT8A3kL93ivkZUBXTKkLJ0L3ckb7NBQqDvbVI1qvk3O(lVoRsz)B6kLhUE)LJ3r"
    "8iJK6SQToCXTQkLxRhfZ)AxBB8Fnn(5Qhy6RlVJmE3fncpDxBvg)xBGzBN)n9Zi7cA(MPRyJnD7MhV"
    "cWgFt8mY2mGZ2o)1LHLOEN)27xB0wgPG3PLux)o)1lKDD2ZiZ))BEgzEhCQZF2cMXZiKUcEnsd583O"
    "gm)FNZ)O1BWm(JkLRnTeDfrA4xbFgzRtjSR7Fgz(3sEgztkhR1Wf6puKzIxbypZg4zK1UVYVfMTDy2"
    "6ElmJvXHXVLddriV3CX7UREv92aVfMDT9BHjz5cw7Y3wLftSCMfsCMwhr40vFQmJx2IX)661WSRTFn"
    "mxtlMZAt8RyXm2WKZ6JyeNBiJTUBUKQDTDgZvPMSTYmgXoMoRWWzI3L(WvG43Y6mJzfN3fdAqCOm0S"
    "IZda36koV76Ut(vCEFm3XvCEI6iAR40l8IR40hCHvC2gJQTIZ2Rmtoh8SfRHS1Zytoyp8JoYz92FzY"
    "2ko7ao5ko7PSAshR62FFLFg(wRFggQDTuNYByHSDgFnNHXSMHnp1FASMn08uGWpj9)kXjsRkqs7548"
    "zjkMpa(fH(VbSql)xa"
)

# ============================================================================
# v0.10 - tenth agent edit (2026-07-02): replaced the two flanking blocks
# with a 2x2 grid inside the resource-bar footprint itself, per
# Battlewrath's design (enemy-cast tracking is being handled as a
# separate future DynamicGroup module instead - variable enemy count
# doesn't fit this scaffold's fixed-channel model, see AURA_BLUEPRINT.md).
#
#   Class resource (127.5w) | Cast bar (127.5w)      <- was "Mana" row
#   Class energy   (127.5w) | Swing Timer (127.5w)   <- was "Placeholder" row
#
# Both rows shortened from 255 to 127.5 per half (0 gap between halves,
# touching). This is a real reduction from v0.9, not just a different
# shape: the resource-bar footprint goes back to 255 total, matching
# Proc/Rotation/Power's own natural span exactly, instead of extending
# to reconstruct the footer's wider 375 (v0.6/v0.9's approach). That
# was the actual, recurring "dead air" complaint from several versions
# back - solved here by no longer trying to match the footer's width for
# this row at all, rather than chasing it further.
#
# "Mana" -> "Class resource" and "Placeholder resouce" -> "Class energy"
# (resized/repositioned in place, uid preserved - they're edits to
# existing elements, not new ones). The old external "Swing Timer" block
# (60x30 @ x=-157.5) is resized/repositioned into its new grid cell
# (127.5x15 @ x=63.75, uid preserved - same concept, moved, not
# recreated). "Side placeholder" is retired entirely - its role is
# superseded by "Class energy". "Cast bar" is brand new (fresh uid via
# generate_unique_id(), per the debugging checklist - confirmed no
# duplicate uids and controlledChildren consistency before shipping).
# ============================================================================

TEMPLATE_SHADOW_V0_10_IMPORT_STRING = (
    "!WA:2!TR1wWTXvz4iPM0wL0sSttAtiTrnTjnoTjJL89mvtJLVezxBz5vYo2HawR0EK21E1UR3DLLL5"
    "AnqXCNyUvGcTyUdnqhbdL7um3kD4H)XddWlaZ4hk(bEWtEIh5)C2vxJtQTJP0gSFqE)p6C2Z58)99)"
    "9)VRoogU201kuRWCEwoUQUarpaFIje0v102BazPzMHxxWtuvvztjn9PhizsdIzWZ22b33ogr)FONZU"
    "Hxm4)EYtEN)5xmpVscrv9WQskMX7ORqr7ItBVgI86eHU15tt6JmfrowERjQdvzv9ED4WHlD(eMsQkg"
    "nZzyYRB6oGKIKP74jX)zi6EwtDPuPi6gh6462x(KliqINjzYO50i6b7QVWDpuFbmrdo(m68(M1qJil"
    "3JGH7LnYehNtfZiyVLMo)yD0EKOJfjA7CrdKbNK4AY85i6f7wyDc2nUiH7QV(4yTepiHx2uKtbx(gU"
    "NpJI9sW9vW9irxHxEyCPHR(lppVIuAE6gPzWD3qnbuuvils4nirm1jkPmfV1LeWLhThJrxS6gKeQkc"
    "gZs7dDRaEcKMxsbhl4bU)Bfok8aWdIxUNQBzbC9Yrsr9zUdiRYl0CaClN4aCPZGaLBUeY8gghaQZDa"
    "dPzi0lwkUnSA51D5Yvyx1F6M4msWltCf3crexW6)DjKIOvtKjZGaNNUZil758IsMKf0ztjDLYLsxnJ"
    "MD3JGZXox06AlcXTVGPAIPS8l32ux8Oscxjkjn6RnjJH0bb1S5ts5dOJH3K31vSOnmkc9UhpshCD1v"
    "OL4ZyInpGgJC42M20JcobUIJEUKsPC7lJKqEFTNQU(vAro45gFEdICsg)d21cuVRK9GLusQQBbpU54"
    "L1e5DPvl2btDvzzIqhIsYcik9ShA5oOopp6ed1m6jilAzsui6PYPT3OseDpn5Xqw10tyD1elvEd(QW"
    "QHkSAScRMQWQzT7Iz61YKt1KToxQ8g9vHvdvy1yfwnvHvZAhKz6ZEnRMfnINX0e9klv(34RcRgQWQX"
    "kSAQcRMxMz1GNayiMHNgQ00N2Hz2n6jIjVIavnjJPKSKzopD05RY32q(izLus5jQuAI(SDWBy6joVE"
    "TjE2dnxRlyOXRpX5Lemf3)csiogHHwhEhWzCNNxy8mgMeH(5N2zjdjfNWTmYo92KVt3eStyxZJ3mw0"
    "GVEDe8X(BS)(7UCTe7oxadCOvtf29Rkqc0(qrh4k0akAuGIqrHmwifCh35XH78vwoJbLRRMT94gQ6X"
    "JHrWhaUly)S25zTrVxXGdXXWe4WU1URcJPhLeQPXTov7j28A0VNky4a2NB4EGdI3P7EwAFPsyXwIEv"
    "X(edEtWEH71Twnur1PirTKROZ1ZTdMNASefKaCTmrHpUm5C68csOwN4YA6QPqMVHL38KhEhoHJyPMv"
    "PI0XE11OcysM2uC2cozQp(LUh6Fhk4J9p)l0)(RUqzCdEtQMir0crlkp5ArMTLEYOoGJ37bGAwc19k"
    "53TBaJRjwnm3DRD)0zDm2hwX7JPnMjYFgttNKqIQh5A(ID5OhdZYXSSeLkLrAzRwlQLq02hRfursLk"
    "IKGX8c0oAEfRjtAAIaRXNq7bVwRbzsk(e5glPSQQU4ISoq5MsjZb7cQrh3l02wYsnCuRTUJfy9ReMn"
    "V9nwXuBVDRlnJNbZWlqLr9enQwDxRPwihMatkXyMIi8kQklKtR2Y252t2H3H1QAk0tH8IylXSYI6UN"
    "xNxB2ZBFXsfxcu16aHW8CA331AMTSCODW1OdwxWr7NWIwBBKjJo8f6juOU4gRVU6oAPjJMN5G2ENrS"
    "9ovSlSB01C7BnMnf7lqs6mh9ykWBNb0W7aiW7eExW7(jG3Rd4jOabml8(yUA49dpjmhQP8HGpm8bJb"
    "FAxWLYBTY465CbJcFYdcFkhWhb(OXfjsPenpcBXMrNyf)4RVi9dpu3WjPzGHtq)CEAWQcwzHUi8W0g"
    "wMrZditueOXO(AVZo12l2P2TLTyQyIGRr2zZnC6wAkancweAfAdUVldpko80QQMIHTJBJv9yLWo7vN"
    "wvegicT4sBFPSd2hqN(jtuBHGdW1Zfgiu027BEMcHHKaHZAlE7y4VBy3UH942kImQ1ou7e9qR)jjFc"
    "YfPsZOAvaE9loupNQK1PIqhqE2WcYCq(1TDqZwO4sS2aOZaZOQM2bhRJIqtyjd2dssqGOWfQRH7IdE"
    "meBc4Illnil8o96RfuR1FEJHJ3WqjgOhUj8QlPqR5GiwU0XioYRwANcFv4SUH2DpxRWBB)Wyi0wWXc"
    "XCc8wjiAUfReey)GeoabKHy5f2dZryPVdPkkPdIOkoiHk4W4XGjkxLgKJbPlijdkp3oavlMfcEtYKx"
    "P7kKlySM6JGPiKXAatzlbczPFm9C3nKZfLiRD9jYiLTmUmswP0zKWwGs)XCaFC4taxcMNsM)a5G3J4"
    "C7JoQnBmc9EFj4ZAhA8zWOTVc60)CWNNgiWcbSdh(c2baWtdFr4ljcjlLbLYU1erWTUb7Uz(6fgoA9"
    "9dpBm4lJCzybKeap1rGVg81HNre(UW3d(w(HVn8DGVb8nHNZbCzlgeLy1fY4HNVazXktgMHIMOQSmz"
    "v1YEUQwEu3qEr477a(bw8N4vuWawXXChJXLoJBgf6P3fL9Syc8PMqrjfA10Ixnd6jzSIAGAP0fklIs"
    "xO0MdbVzkvYMVCFx(ktqiATtRV3KJsIfzCgKzC8ZW4du8ATKxnQqWZy9dMokGLxsRgl1Uaden6a9xH"
    "MN(adfTVEc11RSukz1SDRtMmdrjrUW3s9N2xtwjZOFXI0p60(PECnl1IMZyjRkqhaJxXhaBbAZ9XEe"
    "P9NNEDHCFZtnkRKauB7CfArK1Zc5byRIOIsjMqbLbDXgye2Z2eGEPiRH(KWVSg2SfW6bEGNQUQeOlX"
    "lrojJW9mWZedLc4kLc2o0f5AiZOaxRB45hKs3OKxKH6pFpdKS1wBUxFYZOtPpXCU5jGN19SfytXOkw"
    "ERh5ZRfPd(HI0v71MGHelk)IYZksWGxqCtxLx18q4hDdq3GFCXmQ)Kxb(Pf4sWpd(1IWVa(LWlUF4x"
    "5aw0AW)CxWVXb87fHFNl436cEPAG)W6epTGV)i1vEln3iQmqdOEzR7kcQ(Zp(j4ZPpshgr7VUI475O"
    "OQn(IiTLMacQS8jLNM0gxW7TpV49EdaoRv0V9IDttDETbFqS4QWheZq8brgeFquAdGpiFeDP2acYVR"
    "mqlyHqmR4n)5dnuOUNkCeZrA)c2ycfprCbr4YKDVwXlLbDB0aNsPWFJyyaYfPXaHT4PBAfGYdCgLl("
    "WrARzsBt2Cr8QhkkzbxuGRQaNxq86JlBMmMVMJlBT0Fw6McUvmwOs6FVvNNzaFcNBaJo0E8Ws345zS"
    "zeuvXTZVCJNFjSvQ6RkbJSyd11AQ2g1C4XlcSp(gobJ9nNcppYTTXKZwZWMxq81LAz(x3AzixDtt0y"
    "4cFISt41BVzXIklIl9rrJaw4ccpfXfB80cEyqELrmvdjVAkzxRqNxpkJ5FJkJTwvm3F1kzt0Q6qgH6"
    "ACTGnTfPKnYAOKvcx24fJDZKsM)nyLYSQeQwitQX0Y1PhQ9g6GuexdTrfYcxQs51j4CDQg7MMkL9Fd"
    "xP8avxPC6CJssNY07GYbx)vkVLKA51Vvk7FJuPm7Pf3sQuoulEZQ0vNCtfSLI4v4nuLYB08lVbRsz)"
    "3Wvkpy15xortrcnu8lOw)G52QQuETEvm)RDVDI)RBIFUQbMoAX7qJ2AoJEMULTQe)xFGz7m)3WVJSj"
    "18ntlHhz6gnprrGnYnW7i7gbC2oZFvryrRoZFJDQnCDdL170sQR)m)vlKDt27iZ))BEhzE7BQXVqwZ"
    "ijfsueVgAdL5FJMG5)7Y8pC1jyg9XLs3Gw0wcjn4)fFhzRtjSB6Fhz(3sEhztihU(EY2zWqZePiWE("
    "nX7iRrFf(vy2odZw3VcZifZW43kddriJ30rATL2v9Ub(vy292)kmXkuWAl(2QsXeoTz2ONV(He6T0B"
    "Lz0cPy8VU(zy292)mmx3umxWM4xmfZidsUGpIreU(n26E4sQ212rmxJAY2kJyeBA6ucdMmsl6dweIF"
    "lRZiMvDEpx1rhJIpR68GWDSQZ7TQhNFvNpa98l9qR68KvX2w1Px4Lx1PpyYvD2aJVTQZglUCUyPtYu"
    "58U2gzI(AJF4HUG3olW7w1ztWzx1zB2Uj25BR0jE7mRC0YoSBfon0q8vEGcN2TKR8GWDSYXa1vEy65"
    "WAYvEe4iRCk2XuBfVSZK2k(yhiTvAGUtyhURvE0chKRcZi90zv4CkUshLD(TWvp9mHrpax3(kDYo2w"
    "wNGl6U8Tw2r4ID4USo2FL27(ZFUEh3mY0IMbefl)CzTsqO9v6P2P(tJuRHMNSe(jOh7XXsOkqs45e8"
    "PikMNkf9C8ZBseQ7)a"
)

# ============================================================================
# v0.11 - eleventh agent edit (2026-07-03): restored the flanking blocks
# that used to sit alongside the resource-bar grid, after Battlewrath
# clarified a misread - the ask was never to rename/replace Tier 3/4
# (an agent misunderstanding, computed but never shipped as a wrong
# "v0.11" - discarded, not present in this history). The actual point:
# v0.10 moved "Swing Timer" into the new 2x2 grid, vacating its old
# position (x=+-157.5, 60x30) - without anything there, the resource-
# grid area shrank to 255 wide while the footer (Tier 3/4 flanks still
# 375 wide) stayed the same, so the footer now sticks out starkly
# against the narrower area above it. The old blocks were what made that
# area read as width-matched/cohesive with the footer in the first
# place, not incidental filler.
#
# Restored at the exact vacated position/size (x=+-157.5, y=-160,
# 60x30 - matching v0.9's Swing Timer/Side placeholder footprint
# precisely) as two new, generic "class accent" color blocks - not
# functional trackers, not a Tier 3/4 rename. Both sides: "Class Accent
# Left"/"Class Accent Right", fresh uids (brand new elements, not
# clones-in-place of anything existing). Tier 3/4 themselves are
# completely untouched - still "Tier 3 Buffs 2/3" and "Tier 4 Standard
# utility CD 2/3", same ids/uids/positions as v0.10.
#
# Result: the resource-bar area is back to reaching +-187.5 (375 wide),
# matching the footer's own span exactly, same as v0.9 achieved -
# except this time via two purpose-flexible accent blocks rather than
# Swing Timer/a placeholder, since Swing Timer already has its own home
# in the 2x2 grid now.
# ============================================================================

TEMPLATE_SHADOW_V0_11_IMPORT_STRING = (
    "!WA:2!TV1wWTXvz4iPM0wL0sSttAtiTrnTjnoTjJL8fzNPAAKSLJKRSS8kzh7qaRvAps7AVA3n7UYY"
    "YCTgiyUdoCTuGwZDOHlAagkxlMBfOdZ)4Hb4fGz8df9ap4jpXJCoND11yNAzB6LG1dY7)rNDpNZ)33"
    ")3))U7XwgP5mnZ1m3CowoHSkhs1hBYj5uLvu2RprHzMHvLZrmzzrDbf1PhmvknKEGZ29b33ogv9FQM"
    "3SHNpW)5sN8o)lpFbwPK8YQrKfK0t0J)WX8ZOSxnEwvexFQSzqHqtHeJxWyG6rwuwTFlwSytLnPUGS"
    "KwNmA6SQ629jijOBprk8F04TpRUQq60ivTdDCvZdV8cCOeztLkwEfKAa)HI03WH8PJnyyZQY6AwnfK"
    "Oyqon7lRLnbEmL0JI7TW0fgVhVrJnE0yEzI5llEqsOiYMhPwUBrur4UXenI)qHyOTKiaIvuNNrcp91"
    "SpFwjZPG9RHxJivjwXrWtn8S)QZZkjKHLSq6eS3h0Kpjzj0IiwnuuDvKuAD(BDjo80J0JXjtwvnusz"
    "joTzj9HSuah(YWkiHpxWbC)3kCu4bGheF4EQVLfWZxguAIpZUprzwUo9HxYjpatMSyGYotsrwnTdaT"
    "y3NMWmiYblLWewn862SzlITwpDhmAjzfr2syGi8ly8x)CPrknf9szXaNJ(Ykk6488c6OfuPdjzMYKw"
    "voRIz3JIhJDUOXXgeIBFbD5Ktz4xUTPU4rf4UwmugSVwhnoMoWjNRqkcFa7yy1zTDndAdLIqU6jI2d"
    "JF)HxInRoU5bvOKd7M0MGs4bWwcSNlLqA7UYkWvWL30TmGKBXaNBI51qIPO8pyxlq8UcMNSGukzvd4"
    "XodROcpRnLMXDqxvwueX1dVGihgLE6dVCpeNNdvKMCw1KOfnmrsi105v2BmbKQJoCOjkR7iIQCYLQU"
    "bx1y1wnwTxJvh1y1PYDrnDAyYiRtNNlvDJUQXQTASAVgRoQXQtLdsnDzoNLZHnsKvxh7vwQ6FXvnwT"
    "vJv71y1rnwDUm1Qnh(WHyAoARwtxkhMA3UJO6SsCe1KS6cIc65D0tVVm)ABfIMtqkTJyczqQZ2dRMU"
    "JeSQknzGiEtMehE6iekLUsZ10eJqAE9Mt(0hEUUwqtHvDYZlWPZV)feWWDukOE4DaNXEbwUjYQPJ4g"
    "GDARvmeKSc3YO70zhUoDhWoHDnpEmPbnU63sGh7Vt)8pSzBj6vUeuzrPPAShqMd5Z7WXg8AK4osWIe"
    "xz9oAKhCh35XH78LwoRgjKqoN3eAYQjIJd0paCxW(PTZsBJCTIdhIHcDWHTRCxLoNGsjLZG9qejQ4Z"
    "Rq(DIUIfyF2H7boi(kD3Zs6lrPl(sKJk3N4WBa2lCV2vAIO9ofkMHQgzSE2Dq9uJNSKsHTLrsSjerN"
    "tLLta7G5xwrvonoarZWBEYdVdRWrme9Qv46yV8sz(0rtRZpBjNmXh)c3d5ZHc8y)R)k5ZFZgwTxJvN"
    "iDI4nq0YQy2wKABi7mMf449FaOPLWYJv87MnGd)rgnm3DRC)KrDC6xgYcJRmUoMMnUIkkPar2Y28L7"
    "Yrpgozi1Yq7QsIRLnATSKtAL9rBblCjt0AsszE(8InVMXGjmnIJ24tO8GR1CqeLMnz(XtjklRYViTd"
    "eUPqQ8WUGMuXRfsBlziAoMXs3Yc0(vbZM38clPRS3(ufMXXqzz5iQToIftPL1AO5YJZZjKCCDEm8Yl"
    "lYLxP5Qw5Md2H3HXSAkSNcZlIVe1khwE(8QSkZEEZdwQ8uGiQ7lmoDOY9TwJSHLfLdUkDW4ags)4w0"
    "yzJzYyh(cbdh2pZ4H83xSkdgjD0bn9oJA6DQzvy2OT523QmAsMhGjPVTJEmj4TtbA4DaPH3j8UGN4j"
    "G3Rf4Dtac49axM6QH3hmh8bWAkFi4ddFW4WN2gCLcgZmMGNlqm4tEq4tzb(iWhnbpIOnDe6KnRkYi("
    "XvOOdapuFWjjjQHtq(EEsWQeUaevE4HjnSmLM7tejXrIrD5T3Ev2lUtEnLTOQy8GTr3zNTDA3D4Jeb"
    "ZdDbDd33vHhfF6zKL15Jyg3gV(Zva3zNQKINWbIGBBk7lTzW(GQKVPIAleyqMGxyWWX8gAEQcHMahI"
    "XyjE74WF7WUTd7XUrezmJvOYjcsktkfBs0fjk4y1kFSQxC4GNQI1PIsoHc0tla1b5r10bnBPAqXLqa"
    "96Bgz5mwyODKh6axzH5jjWXHKyc7Fe)mWJHXgF2yYrcYIStNUCJ1A9uqBKeTnCYbdYmPtvbjsPji(Q"
    "Log1sb5kRu4RcN1o41(CDbX3pWIH2sowiHviPrcIoDBKGa3paR5McZqm8c7H6im03bHYs6WeyvCysS"
    "coighYuTknifhKljjdkp7oGlzWSWGNgvELSQ05HSRQ(imfpKZ4eM2uceYt(AM5UB4TAJqKvUXezmLT"
    "kUmMSsOZycBjk9hZc8XH5HRaFccz(9NhMLFU9roRnAmc5AFf4ZAgA8zWrBFfSt)ZbpfjqGgcygo85n"
    "daGVa8fHNMh4RKbLWUXXhEk0Yq91jBRCJeR1bGfIdFjmxg(Yysa8Khb(AWxhEgE47cFp4B5bEw4QW3"
    "a(MW32c8DmyqeILFmJhkuISyKjdNHIKOQQmz11YEUUwEu7W3Nh(bwGFOb)HRMcgWvCm3XOCPZyNsHE"
    "QDryplMeFZvyrjjsr38xpd6YuwrtqZe6cHfrOleAZHG3iHkzYxUVRETjrifVKBdqNHqI5PCgmZ44NH"
    "Yhi41QjVQvJGN26hmTuclVIstgQD(gmwSbhOgnp1bhowOGH9)slLwuoxFQOlLfjLmFKBP1t7QdJKzK"
    "FyrYx9AEZr2MLyrYzSKrHQdIJxX3N2cKMdrVtQ9xGCCPCFZtmQQKaS225k1cpTNLYdqNfX4fsoPewg"
    "0g9eJsVfiFKd5Pnesa)JnrhnFg3xe8KTuNaDfEjMtsjCpd8mXXsbmvsbBg6I5AyMrjUwFqHHi0nc5f"
    "Zq9ui4GP6QRo73L4mQe6tcRBCc4zTpBj2uCIILZwX85vJ0b)iEYSDTjyyIfHFr4zLjyWZXVHRYREEi"
    "8J3e0n4NuoJ6p9LGFwjUe8ZHFdp88WVewC)WVYc8Rno5FHn43Ab(98Wlyd(D2G)qtWFCDINgW3FI4k"
    "VLoBhRmqcOErJRkgu9uyItWMxD0E0InqlLX3Zrqvt8fJ0gAcyqLMpP60KM4c(A7Yj(A3aGZQf9Boz3"
    "WuNxzWhmwCD4dgZW4dgzW4dgLAa8bZhXUutabZVRnqlqPqmJ4npfcpC4(Mksu9r9EbtmHGNyCbJWvj"
    "7UwXlvbDnAGtLu4VEmmaZfjXarm4PByfGQdCgJjXir7Utu3xQZY4vqckzaxeGRUaNNJ)gJlBKmMVIJ"
    "lBT0FA6MsUvCSqT0)(RppZGU4o3GA9O84re285zmzeevXTZVS5ZVeXiv91LGrKVTw6kD3JPpYeLb2h"
    "VHtWyEXjWZJCBnMC2Qg28C8VMulZZ6wldZv3WenkUWMm3KoD2FoCrLLXLqe0WNbUGHNY4IjEAapuiV"
    "2iM6HKxoLS1k051IYyEAuzSvRI5bQxjBYUKhwlS)juc0XwKs2ORIswfCPXlg7MjLmpnyLY0QeQxitO"
    "9mITOg2BB9GkJRHBuHSivQuEDco3GQXUPPszpB6kLhS(kLZKFmuM06ohsmW6Vs5TKulV2TszpnsLY0"
    "7wClPs5WUDMtYFVmtfWDz8ksdvPCJMF51zvk7ztxP8q1NF5eDen8WjUGCRdLFRQs5v7rX8V392j(VH"
    "j(zQhy6XTZHhRR8AbN29wvI)BmWSDM)n9Zi7skUMXDKrNUD9tugyJUjEgzBgWz7m)1fHfR(m)T3RYi"
    "TmCoNtliV(Z8xVq2nzpJmpV68mYCgAQjUqo9OP4swgVgUHY83Ojy()Um)JuFcMXECHmTPeZDyHH(F4"
    "ZiBDkHDt)ZiZZwYZiBsXiTgmxVbcpt0Ya753apJS2Dv6TWSDgMTU3cZOLZW4XiddIlRZmr7YTxzNnW"
    "BHz3B)wyIxQGv3U2QsXejJEUyNV1H56VYtLzSsPy8SUEnm7E7xdZnmfZfmj(LtXm6qOl4cPfLzaTTU"
    "BUKODTDeZAut2wzedFhtNMBOurDRouzi(nToJywX69CDBDmc(SI1dc3XkwV36UD(vS(aK9V0dTI1tw"
    "hBBfRoHxCfRUaTvS2gLVTI12lpDUyLDYu18UUhDYqDZoYWxWzVL4DRyTd4SRyTBt3eD)TvzhVDMIhT"
    "Qn7wPDdnWv8bkTB34l(GWDu8yWLk(WK9HLwXhbosXtr3MAfDs3tAfDr3qAfBJSsOBURIpAPnYvPrKS"
    "7SkTpfl2tv7Fl8SNSNWiBGRBVyV0TTLXo4ISkFZvTfUOBUlJT9xL1UNcNR)j0JonVUpE(Q3xwfdaEl"
    "gCvxN4iKnZs0Z1TejooYKzdTeFlR1smpEXne)5Z0g)iP6EyNVAT4ISzwCJFJwC9nsk3Df290(7m41V"
    "4AEQ)8OnRP4ihIDsYgwD8KYCOKoobBAKK(Pst(h1GvhX1Y)f"
)

# ============================================================================
# v0.12 - twelfth agent edit (2026-07-03): fixed regionType for
# "Class Accent Left/Right", after a false start.
#
# Battlewrath's note on v0.11 ("them being buttons instead of bars, it's
# messier to reason with") was initially misread backwards - the agent
# assumed "should be bars" and converted "Swing Timer" from icon to
# aurabar. That was wrong and never shipped (computed, not appended to
# this file). Battlewrath clarified directly: the desired state is
# BUTTONS (icon regionType), and confirmed the scope - "Swing Timer" and
# both "Class Accent" blocks should be icon; "Class resource"/"Cast
# bar"/"Class energy" stay as aurabar (bars), since those genuinely show
# a fill percentage and a bar is the right shape for that.
#
# "Swing Timer" was actually already icon-type in v0.11 (its original
# v0.9 type, never actually broken) - only "Class Accent Left/Right"
# needed changing, since they were built in v0.11 by cloning the
# "Class resource" aurabar template. Rebuilt both from the icon template
# instead (same fields aurabar/icon need are genuinely different -
# barColor/spark/orientation vs. cooldown/animation - confirmed by
# inspecting both templates' key sets before rebuilding, not assumed),
# preserving their existing uid/id/position/size.
# ============================================================================

TEMPLATE_SHADOW_V0_12_IMPORT_STRING = (
    "!WA:2!TV1wWTXvz4iPM0wL0sSttAtiTrnTjnoTjJL8fzNPAAKSLJKRSS8kzh7qaRvAps7AVA3n7UYY"
    "YCTgiyUdoCTuGwZDOHlAagkxlMBfOdZ)4Hb4fGz8df9ap4jpXJCoND11yNAz7wAdwpiV)hD29Co)FF"
    ")F))7UhBzKMZ0mxZCZ5y5eYQCivFSjNKtvwrzV(efMzgwvohXKLf1fuuNEWuP0q6boB3hCF7yu1)PA"
    "EZgE(a)NlDY78V88fyLsYlRgrwqsprp(dhZpJYE14zvrC9PYMbfcnfsmEbJbQhzrz1(TyXInv2K6cY"
    "sADYOPZQQB3NGKGU9ePW)rJ3(S6QcPtJu1o0Xvnp8YlWHsKnvQy5vqQb8hksFdhYNo2GHnRkRRz1uq"
    "IIb50SVSw2e4XuspkU3ctxy8E8gn24rJ5LjMVS4bjHIiBEKA5UfrfH7gt0i(dfIH2sIaiwrDEgj80x"
    "Z(8zLmNc2VgEnIuLyfhbp1WZ(RopRKqgwYcPtWEFqt(KKLqlIy1qr1vrsP15V1L4WtpspgNmzv1qjL"
    "L40ML0hYsbC4ldRGe(CbhW9FRWrHhaEq8H7P(wwapFzqPj(m7(eLz560hEjN8amzYIbk7mjfz10oa0"
    "IDFAcZGihSucty1WRBZMTi2A90DWOLKvezlHbIWVGXF9ZLgP0u0lLfdCo6lROOJZZlOJwqLoKKzktA"
    "v5SkMDpkEm25IghBqiU9f0LtoLHF52M6IhvG7AXqzW(AD04y6aNCUcPi8bSJHvN121mOnukc5QNiAp"
    "m(9hEj2S64MhuHsoSBsBckHhaBjWEUucPT7kRaxbxEt3YasUfdCUjMxdjMIY)GDTaX7kyEYcsPKvnG"
    "h7mSIk8S2uAg3bDvzrrexp8cICyu6Pp8Y9qCEourAYzvtIw0WejHutNxzVXeqQo6WHMOSUJiQYjxQ6"
    "gCvJvB1y1EnwDuJvNk3f10PHjJSoDEUu1n6QgR2QXQ9AS6OgRovoi10L5Cwoh2irwDDSxzPQ)fx1y1"
    "wnwTxJvh1y15YuR2C4dhIP5OTAnDPCyQD7oIQZkXrutYQlikON3rp9(Y8RTviAobP0oIjKbPoBpSA6"
    "osWQQ0KbI4nzsC4PJqOu6knxttmcP51Bo5tF456Abnfw1jpVaNo)(xqad3rPG6H3bCg7fy5MiRMoIB"
    "a2PTwXqqYkClJUtND460Da7e2184XKg04QFlbES)o9Z)WMTLOx5sqLfLMQXEazoKpVdhBWRrI7ibls"
    "CL17OrEWDCNhhUZxA5SAKqc5CEtOjRMiooq)aWDb7N2olTnY1koCigk0bh2UYDv6CckLuod2drKOIp"
    "Vc53j6kwG9zhUh4G4R0DplPVeLU4lroQCFIdVbyVW9AxPjI27uOygQAKX6z3b1tnEYskf2wgjXMqeD"
    "ovwobSdMFzfv504aendV5jp8oSchXq0RwHRJ9YlL5thnTo)SLCYeF8lCpKphkWJ9V(RKp)nBy1EnwD"
    "I0jI3arlRIzBrQTHSZywGJ3)bGMwclpwXVB2ao8hz0WC3TY9tg1XPFzilmUY46yA24kQOKcezlBZxU"
    "lh9y4KHuldTRkjUw2O1YsoPv2hTfSWLmrRjjL55Zl28AgdMW0ioAJpHYdUwZbruA2K5hpLOSSk)I0o"
    "q4McPYd7cAsfVwiTTKHO5yglDllq7xfmBEZlSKUYE7tvyghdLLLJO26iwmLwwRHMlpopNqYX15XWlV"
    "SixELMRALBoyhEhgZQPWEkmVi(suRCy55ZRYQm75npyPYtbIOUVW40Hk33AnYgwwuo4Q0bJdyi9JBr"
    "JLnMjJD4lemCy)mJhYFFXQmyK0rh007mQP3PMvHzJ2MBFRYOjzEaMK(2o6XKG3ofOH3bKgENW7cEIN"
    "aEVwG3nbiG3dCzQRgEFWCWhaRP8HGpm8bJdFABWvkymZycEUaXGp5bHpLf4JaF0e8iI20rOt2SQiJ4"
    "hxHIoa8q9bNKKOgob575jbRs4cqu5HhM0WYuAUprKehjg1L3E7vzV4o51u2IQIXd2gDND22PD3Hpse"
    "mp0f0nCFxfEu8PNrwwNpIzCB86pxbCNDQskEchicUTPSV0Mb7dQs(MkQTqGbzcEHbdhZBO5PkeAcCi"
    "gJL4TJd)Td72oSh7grKXmwHkNiiPmPuSjrxKOGJvR8XQEXHdEQkwNkk5ekqpTauhKhvth0SLQbfxcb"
    "0RVzKLZyHH2rEOdCLfMNKahhsIjS)r8ZapggB8zJjhjilYoD6YnwR1tbTrs02WjhmiZKovfKiLMG4R"
    "w6yulfKRSsHVkCw7Gx7Z1feF)algAl5yHewHKgji60TrccC)aSMBkmdXWlShQJWqFheklPdtGvXHjX"
    "k4GyCit1Q0GuCqUKKmO8S7aUKbZcdEAu5vYQsNhYUQ6JWu8qoJtyAtjqip5RzM7UH3Qncrw5gtKXu2"
    "Q4YyYkHoJjSLO0FmlWhhMhUc8jiK53FEyw(52h5S2OXiKR9vGpRzOXNbhT9vWo9ph8uKabAiGz4WN3"
    "maa(cWxeEAEGVsguc7ghF4Pqld1xNSTYnsSwhawio8LWCz4lJjbWtEe4RbFD4z4HVl89GVLh4zHRcF"
    "d4BcFBlW3XGbriw(XmEOqjYIrMmCgksIQQYKvxl756A5rTdFFE4hyb(Hg8hUAkyaxXXChJYLoJDkf6"
    "P2fH9Sys8nxHfLKifDZF9mOltzfnbntOleweHUqOnhcEJeQKjF5(U61MeHu8sUnaDgcjMNYzWmJJFg"
    "kFGGxRM8QwncEARFW0sjS8kknzO25BWyXgCGA08uhC4yHcg2)lTuAr5C9PIUuwKuY8rULwpTRomsMr"
    "(HfjF1R5nhzBwIfjNXsgfQoioEfFFAlqAoe9oP2FbYXLY9npXOQscWABNRul80EwkpaDweJxi5Ksyz"
    "qB0tmk9wG8roKN2qib8p2eD08zCFrWt2sDc0v4LyojLW9mWZehlfWujfSzOlMRHzgL4A9bfgIq3iKx"
    "md1tHGdMQRU6SFxIZOsOpjSUXjGN1(SLytXjkwoBfZNxnsh8J4jZ21MGHjwe(fHNvMGbph)gUkV65H"
    "WpEtq3GFs5mQ)0xc(zL4sWph(n8WZd)syX9d)klWV24K)f2GFRf43ZdVGn43zd(dnb)X1jEAaF)jIR"
    "8w6SDSYajG6fnUQyq1tHjobBE1r7rl2aTugFphbvnXxmsBOjGbvA(KQttAIl4RTlN4RDdaoRw0V5KD"
    "dtDE1bFWyX1HpymdJpyKbJpyuQbWhmFe7snbem)U2aTaLcXmI38ui8WH7BQir1h17fmXecEIXfmcxL"
    "S7AfVuf01ObovsH)6XWamxKedeXGNUHvaQoWzmMeJeT7orDFPolJxbjOKbCraU6cCEo(BmUSrYy(Qo"
    "US1s)PPBk5wXXc1s)7V(8md6I7CdQ1JYJhryZNNXKrquf3o)YMp)seJu1xxcgr(2APR0DpM(itugyF"
    "8gobJ5fNappYT1yYzRAyZZX)AsTmpRBTmmxDdt0O4cBYCt60z)5WfvwgxcrqdFg4cgEkJlM4Pb8qH8"
    "AJyQhsE5uYwRqNxlkJ5PrLXwTkMhOELSj7sEyTW(NqjqhBrkzJUkkzvWLgVySBMuY80GvktRsOEHmH"
    "2Zi2IAyVT1dQmUgUrfYIuPs51j4CdQg7MMkL9SPRuEW6Ruot(XqzsR7CiXaR)kL3ssT8A3kL90ivkt"
    "VBXTKkLd72zoj)9Ymva3LXRinuLYnA(LxNvPSNnDLYdvF(Lt0r0WdN4cYTou(TQkLxThfZ)E3BN4)g"
    "M4NPEGPh3ohESUYRfCA3Bvj(VXaZ2z(30pJSlP4Ag3rgD621przGn6M4zKTzaNTZ8xxewS6Z83EVkJ"
    "0YW5CoTG86pZF9cz3K9mY88)MNrMZqtnXfYPhnfxYY41WnuM)gnbZ)3L5FK6tWm2JlKPnLyUdlm0RG"
    "pJS1Pe2n9pJmpBjpJSjfJ0AWC9gi8mrldSNFd8mYA3vP3cZ2zy26ElmJwodJhJmmiUSoZeTl3ELD2a"
    "VfMDV9BHjEPcwD7ARkftKm65ID(whMR)kpvMXkLIXZ661WS7TFnm3WumxWK4xofZOdHUGlKwuMb026"
    "U5sI212rmRrnzBLrm8DmDAUHsf1T6qLH4306mIzfR3Z1T1Xi4ZkwpiChRy9ER725xX6dq2)sp0kwpz"
    "DSTvS6eEXvS6c0wXABu(2kwBV805Iv2jtvZ76E0jd1n7idFbN9wI3TI1oGZUI1UnDt093wLD82zkE0"
    "Q2SBL2n0axXhO0UDJV4dc3rXJbxQ4dt2hwAfFe4ifpfDBQv0jDpPv0fDdPvSnYkHU5Uk(OL2ixLgrY"
    "UZQ0(uSypvT)TWZEYEcJSbUU9I9s32wg7GlYQ8nx1w4IU5Um22Fvw7EkCU(Nqp6086(45REFzvma4T"
    "yW6bfCWX6bp8044XBbkKVgKyi(ZNPn(rs19WoxvKG4TR6zs8k)mC86NH9nsk3Df290(7m4AWvOZWMN"
    "6ppAZAkoYHyNKS1rhpPmhkPJtWMgjPFQ0K)Ljy1rCT8Fba"
)

# ============================================================================
# v0.13 - thirteenth agent edit (2026-07-03): reserved positional
# placeholders for the Buffs/Utility dynamic-overflow design settled in
# HUD_DESIGN.md this session - 6 new slots under each of Tier 3 (Buffs)
# and Tier 4 (Utility), matching the static icons' own size (30x20) and
# 0-gap convention, numbered "3 dynamic" through "8 dynamic" (continuing
# after the 2 existing static slots).
#
# Positioned touching POWER's bottom edge (y=-205), not Tier 3/4's own
# bottom edge (y=-195) - a real geometric constraint, not a stylistic
# choice: Power (30 tall) extends further down than Tier 3/4 (20 tall,
# top-aligned with Power rather than centered), so a row placed directly
# under Tier 3/4 alone would overlap Power's still-live footprint down to
# -205. Centered under each static pair's own x-center (-157.5 for
# Buffs, 157.5 for Utility - both already established anchor points,
# matching Class Accent Left/Right's position).
#
# This is the widest this scaffold gets: 495px total (+-247.5) when both
# dynamic rows are fully populated, vs. 375px everywhere else. That's
# expected and not a problem to fix - per HUD_DESIGN.md's settled design,
# this row only appears out of combat and only shows what's actually
# missing (0-6 icons per side in practice, rarely all 6 at once).
#
# All 12 new children are positional-only placeholders, same as
# everything else in this file - no trigger/Load/Condition logic is
# wired up here (that's the actual aura-building work, via
# AURA_BLUEPRINT.md's process, once real buffs/utility items are chosen
# to track).
# ============================================================================

TEMPLATE_SHADOW_V0_13_IMPORT_STRING = (
    "!WA:2!TV1wWTT1zAtH40eM4ul5yN4uNewN4ePKypIuIKszcNesjkrjtrrbsjrPn7kbsCibKabGbaff"
    "vVKg1DtvV3QEBVKDtQ6Uz32g3DxU3V0mPAAAtB3l)v9sY0zA7m6Hu9qFqJFQp2Z5aqWlMYrYwTkn16"
    "bACo8aG)Z577)77hGh7yI2Y3gFB8R4AZ0kA8iTqCzMNxtrv9OHKexAjonExjvuKmev1wC0Sz1rgrEI"
    "Ep5XoukTFUwjRoE5i)Ql8q32p(LlZjNrqrlUIOSr6(chlzyw1JQlWPH4hqJlpkkAbK0SLnVr9PiPOn"
    "Sdhoy04YyiQiR7Jv3GtZWzirzrdNPZI)hDbNlBOjMlhst)UEanRdFM14rPlKnBYsQiTiHJgFGXJgYa"
    "3GLRGgNNL1vrssdXR7Ct9cPX3tzJe4rlUy5z6lyIKZKizq2KHkGVjPvL4kH0ShwCneEySjIhoAuwAp"
    "PJG4KmeyLXHVUZvliBfcoVeEoI0K5KMahA4O)IRYjlMNJmr8bohaAnKSImADeNokHHgsoNHW7ydEC4"
    "rgXmKGvthLrrMxFzYyitfWvO8CIY4ZfCbV73bCA4(G7hF4T2ypRHJxwuoYAMZqskC8(cHNYzobB(cy"
    "GYjBgjoD9taD4mKU4siYbBK2cwnx1zyyIZ0558YQNHtcXK2erewZ8FdZNdP2AIluadCUgOGKKRjfen"
    "qRPrVLKiLnNMsbvRHNaFpo86MhBsiU51muYSG56YnTWtEAr(lLeLhVwBGMbth4vkwolHpGxy4m4yUK"
    "jTHsrix90j6JnC4yBWvWa39OQuYHtlAZqY4BatA8kxwXCo9uqKVSNG56yez)srgCUv1rszP8p4gxJS"
    "6kADYIYzv0mHhNSCsQcCmQTHhGHMIKeIVpbrjEmk98TVzFKfpxAiDLcAzqRB2ejJ0Yvs9OjfrAU86s"
    "xsXWvCnLmBuBhEQRvx11Q76A5TUw(uVDAt3MnzvmOX5g12PN6A1vDT6UUwERRLp1tsB6XkMvkIBKUG"
    "HbEvzJA)gp11QR6A1DDT8wxlFBsB1LRq4umDxDvFtpQNI2UBxjm4K5jQjfmeLenk5QV(Ft(2UkNOOO"
    "CoxjfZJ0wUpoDdxP50uB1ercMjdo90vuuwd12QRlwXCcgQNO(WYfFjCkSyMg6V7DOFV7q)(2H(9Vd9"
    "3JD)3)vAMURgv37Qr5DxnkF7Qr5Fxnk75yBzE(2xPN10v50MFsrEdHJVMioflbnr6uhcEuNL54NRGU"
    "bIFeUfBPAdr5wGBi1HD71Z58chgUXvX4mvOYZWoI84)u6F)mgMnOx5kPhouBTU2JOWJcfC8KJEjIwh"
    "rGsM32JHQ2bh52Ea42EJnlOtKHukgmTUIw6zXIRNaUD440(5O9rUwZc3flnDboLt1BVY5mKCgL8ywj"
    "Xwy2vvjFprl3bCmNWDcNeFLUJLjJL4Um7gKJShZSW7eokC3ovBL43TakPPtc5E9IhIUsntMkQZmBIK"
    "5slHguJJxetQf2uvtjhwus3C18Ho1HAbUxtJM6nloZBU9rid0IgclxzrMSg)Q3j5V7kYJ)lEnYFVod"
    "2HvNZGyxHemruBNdM1PTnL6NYb8adFcO1nWwsvx3T6al5Im7yL7q9DtURZq)WukEg1zmWP2ZOQHYis"
    "Skyw1EiN(m4cqOTm9lQwSWMM9AlZRREmApyZcfI(EgkZluqCZlzEZexeXt78PvV)DkgKq54YuAMSsk"
    "kAcRthaHBkMTeCJqRA45cPVnmnQMYCQ7yn64QIzRADHLnup6aAIl5AScC8ehoxjtQ2XoDRTsEMXqad"
    "Vcks8LuBRMzU1n7uhYmQwaVsH5fZUbTvrSL4KACQlpP1bByhceJ0qXWLGOEp70D2SLd1t2KbyEalzC"
    "8RBoTXmz8c(Adflwy2zIgEGKvVzKsaoP1QtkRvN6MfwDYSYXAYDt26amjDLtFgz4dtbA4Ja6Whf(yW"
    "h)PHpTd4tsac4tbRsxQHpd8zHppwt5pf(ZGVWSWxIbEUYMrg7qdgjj8fpjSMd4ph(lslGi(b3lnylO"
    "HmZF8enXiWdoa8qKIJG2jFUkjzvgx0NMa8WKo2KsZdjHK5j5OEc2F)QhfpOGwYwuvmbGj1H911587n"
    "ejdwa6b6fUNlcpg(0ZROyie3kVD2gpxr8GDRrkyfNic(zupwoRK9r1iFsf1wlYOSdn9OXsgm6QufcD"
    "rEeR5u8MXP)oHBXjCRonZitAodvBFisPPz5YGEsIRjwTkeN2to(qNTARZMGCcLPNwe6cuanRfOLRu3"
    "pUSnO)qlPOK3blDGcGxC1CwNKippsMnw4jcZcpogBcXWwKKKf)WU94hR1gOS(eP7A8mJoe78U1eLjL"
    "dIeQv6iLJYkvNPqz4jCcbDUspG0XH8yOTYclGDhumni8530Gapo4coanmdXCv4wPleM67qbBjDybSk"
    "oueRGdloluQwvAyPzH3tfjz49(IhcEFMmlm49uu5vYS6diapDt1hHLfGpO5j8hBjbc)jKpEMvUd4dX"
    "qiYQxzImMYwdxgtwj0zmHTcL(zDa)LWFf8CWZtiZFUsWNqyLJroRR2CeY1(5G)gRuJ)AC22)iEr)Vf"
    "(7ijc0uaR0HVSvca8vGVk8IcGrvhuc7(9lGb3ogBaFCDYprYohb(AZc)9yUm8pGjbWlCVW)e8pdxua"
    "(VHVo8Vfa(3H)d4Fb(xH)thW)LjdIqScJz8WlvHSy6KHDOigv14K1qp36L1ZJ5eEzb4B4aw3K)Owxb"
    "d4kow5muU0J6KsHE2BKWEwpd(bAXIsYKh0r4YzqpdLv0k0gHUqyre6cH2CxW7IqLS4l3ZfV08iKAqY"
    "JEzWsiXcuodMz8apkLpqWRMjVQxNGN(UhmDublFo1wnv7cnAYKJosDAEAJoEYOdfl8BSrojLIdOHUq"
    "bKCMsXVHopNhVMMzKVyDYh9B9aPmltAr8m2W8HdgfNVIF241iDhL(0RhVm54kEFRsAutjbyTTbR0Ja"
    "DKv8bOrrsbXmZlJLbzONyc6JDgICOaTJOI4VSv6DlK5ZIcVqhniqxLxI5Kuc3fHlolwkGTQfSvQlMR"
    "Hzgv4AdaV0ye6gH8IzObkp0Oz7PhFd7rAjnc9rULREc4t4C5kSPzjkwU7eZNBgPd(McKODNjyyIfHF"
    "r4z2em4veUQRYRrEi8TUgOBW322r9vFd47uHlbFx47la)pW)l8)DC4)3baMN83Jb2Wb8JeGFid8dyG"
    "FCRWRTlXtt47NqwkVbFDJvgijuVU5vfdQbkpx7CL0s1NEYr6WgFhKGQw4lgPn1eWGk1pPwBslCbFT9"
    "4gFT3dGtZY(Tc2RAQZVDWhmwCz4dgZW4dgzW4dgL2d4dMpIxsTaem)U(eTivsXmZ3cuo24XgyH4jms"
    "fCAlmHGNyCbJW1i7Ut5l1aD71eNQw4)UyAaMlsYbIBYtVQvaQnXzk20tKOxFOEVGpB8AickzcxeGRH"
    "eNxr4kJlxnoM)whx2FP)u7MklR4CH6P)d3OpZOE4hCu9(upFCXRDFglgbrv86(lx7(lXnTQVmdgjHU"
    "6ONC9oLXeZzdSNFpBWyDXjWZJCt7n5SMM28kcVLullWUwldZvVQjAuCHltX5D7E4I4IkTXLOe0iKjU"
    "GHhBCXcpnHhkKxFgtJqYBMs2oL68wrzSa7vzSMvX8inQKnFpkJRhl8CQr8UpPKLQjkzvXL9EXyVDsj"
    "lWESszAvcnkKj2DEPo0IfSR(q24AS9Qqw8QvkVlbNRq1yVTPs5axZvkpAJvkNV0uO85mCpMuKDFLY7"
    "lwlV1Ts5a7LkLPpT4(sLYX87UOC4(zxiIFB8k(EQs59Q)YVJvPCGR5kLhRr)L29Mi24PNwPZXkTFvP"
    "CZEvm)YB56g)xrJF2gbM(87E8P6PK(ql6F)Y4)kdmx35)A(DKDbvpl5pEQf72ODBGnX1W7i7AbCUUZ"
    "FdzyjB05V7(vNOJXl6ErrLDVZFJczVn7DKf4G5DK5o6cZnDrJez5ZyJxJVNC(3Rgm)ENZ)enAWm15f"
    "Z3LAs)Xeh73GVJSDPe2B7Fhzb2xEhzZlfVZHk2FKylLWgyN8Q4DK1TNk)kmx3Hz)7xHjLTdtathgeF"
    "b35t0J)GkU3d)km3Y1)vyMTsbR(9SFzXepVrXKt2548dx9TYmvflMa7QFgMB56)mmxrlMPTi(2wmPg"
    "dnThKEc2r03)E4sI211Zy2HAY2pZye8Uyo(XYMWV2y2q8FWUmJz7wUZlBRJrWNTB5KWr2UL7UHhNF7"
    "wUpY(x6b3ULhQb222T4gE9TBXd8uB3sxu(22T0TD48Kv3jt1Y76n18r7LBIXN2D)v4DB3Ix4j2ULET"
    "wMO7VTQ74ThDRtxZMDRYUHgu36(QSB3m26(HJS1zG33wpmzFy9uB9iW9U1zPBtTTCt3tAB5HUH02Ql"
    "YmHU5U26XQSrUQChj7oRk7tXT6RM9Vfo6j7jmYg46M3QF622YChCrML)H1SfUOBUlZT9x15EGYdo8C"
    "gjwuWiKGqT7lRTIab3AOgbfCYXUbpcS3XJ)i4LkvhsmMWK57syIS9oU7MIeKv7AENe)MpcNPXiCGjY"
    "6VNy(xmSVH2bUs9riZrOr479ivJqMBdhHmTrvr2M5oRgJmNKM9UnJRMzU5PlAQ62mpioEzEyZKUIre"
    "ho1WtUq8KvFhOZ2qs32mpsL0UTzolEgZCUAt92hJWoBsekF(UNswy657rRt7iK7GkcTK7QpctYPm6s"
    "D6bnqIs2ry6dSiS7MeHtmwpjm6HpAIbR(8UzoWIq3njc7FGutgVxbpD4N1oc5pGIWBONMeG54MiXur"
    "BpO75h0oarhmby8MgG9Uy3Xk1EOXYmVODaM9akaBogBGMo8CIf9PPwvFm3bwe2S8KULufgp2G6Dm8a"
    "2rOWbwe2mTMl4D(mHlosxT7Dc7iu8GkcBQETANNFE2LoFPusPSJW5oWIWM55D(urfxA6otF(PYzhHZ"
    "VRIW2w4hMQnDvxfrCZt(p0Xmzu4rzC1oxoKSXzZr(ppkNbIVJFn"
)

# ============================================================================
# v0.14 - fourteenth agent edit (2026-07-03): corrected v0.13 on two
# points, both live-tested and caught by Battlewrath, not by the agent's
# own verification:
#
# 1. Count was wrong. "Should be limited to 6 buttons each" meant 6
#    TOTAL per side (2 static + 4 dynamic), not 6 new dynamic slots
#    stacked on top of the 2 static ones (8 total, what v0.13 built).
#    Checked reference_library.py for a specific count before assuming -
#    Fojji's "Reminders" section doesn't specify one - but the scaffold's
#    own internal convention does: Proc/Rotation/Power all cap at 6.
#    Reading "6 each" as a total brings Buffs/Utility in line with that
#    same ceiling instead of being the one row that runs to 8.
#
# 2. Spatial arrangement was wrong. v0.13 placed the 6 new slots in one
#    wide row far below the footer, touching Power's bottom edge -
#    correctly avoiding a collision, but "not spatially related to
#    anything" (Battlewrath's words) to the static Buffs/Utility pairs
#    they were meant to extend. The actual intent: a compact 2-wide x
#    3-tall rectangle per side, where the 2 existing static icons form
#    the top row/rank UNMOVED, and the 4 new dynamic icons fill in as
#    two more rows directly below, at the exact same two x-positions
#    ("file") as the static pair - not spread into a separate wide row.
#    This also sidesteps the Power-collision concern entirely: since the
#    static Buffs/Utility icons already sit outside Power's own
#    x-range, stacking straight down in the same two columns never
#    enters Power's footprint, no matter how far down it goes.
#
# New children (8 total, was 12 in v0.13 - v0.13 kept in history as a
# real, tested, wrong version, not erased): "Tier 3 Buffs 4/5/6/7
# dynamic" (2x2 stack below "Tier 3 Buffs 2/3"), "Tier 4 Standard
# utility CD 4/5/6/7 dynamic" (2x2 stack below "...2/3"). All still
# positional placeholders only - no trigger/Load/Condition logic yet.
# ============================================================================

TEMPLATE_SHADOW_V0_14_IMPORT_STRING = (
    "!WA:2!TVvwuTX1zylM40gfhxdo2jo1jrXXobsI9bjqiiNOtIeiqIiKeJeyWnTWinxPzGrZmEMriePB"
    "H2Ms3BP7nDjLUM2KUOUNtBpj099)sZjTp0LZHhs5H(ah)uFS37DgnAXGdGjXjPMhKN)RUZm)3)VV)V"
    "))z01ogTL8TW3c)cUwnTIgpslixMP51uuvpqqjX5MJtJ3vkffjdrvTzJNnRoYi891Zro4Egt7FPvYA"
    "GNk8)9S3X(F2NQmNCgbfTekIYgP7nuSuHyvpGUaNgIVFnU8OOOzqstw28g1RIKI2GoC4GrJlJHOISE"
    "xS6gCAgodkklA4mDw8)Ol4CEdnXC5qA63WTPzD4dVepkDHSztvsfPfou0e9ps0GgydwUcACEMxxfjj"
    "fHx35Q6fsJVNYgjXZwC2Yt0BGKPMizQaSPcwaFtsRkXvcPzpTeAi80ytMiu0OS0rshgXjziWkJDFDN"
    "lwq2YfCEo8AePjZjnk21WE)tSiNSyEoYcPlWz)qZbLvKrlJ40rjn0qY5meEvRWJDpYmMG4SA6OmkY8"
    "6ZtMdzPaUcMNtugFUGl4wEvWXGBfoo(W914ilH9xwuosmZzqjfo(UcIxYzomB(cyGYjBgjoD9ddT5m"
    "OU4CiYbRK2cwnJ6mmmjyA)uEz1ZWjHysBIiclz(VH4ZHuBo5zlGbox9xqsY1PfenqlPrVLepLnNMsb"
    "vRPNeFp27YMhBsiUQLmuYmJzC5vpZdCmr(ZLcLhhRnqtGPd8kflNLWhWbgodoMZzsBOueYvpDYEzdf"
    "k2kCfmWdhxLsoCArBIiJVbmPXrUSI5C6PGiFzpbY12qY(KcpWulQJKYs5FWvUej6kADYIYzv0mHhNS"
    "CsQcCmQTGNGHMIKeIVxbrjEmk9OhF1EjbpxAiDLcAzqlBAIKrA5kPEGuIinxEDPlPy4kHMsMvQDap1"
    "z1rDwDwNL36S6s9APMUnnzvmO(5k1oON6S6OoRoRZYBDwDPEeQPhlFwPi2iDbddCuzLA)gp1z1rDwD"
    "wNL36S6AvQvhUcItX0D1r9MEupk1Utxjn4K5jQjfmeLenk5Q3(EE(2okNSOOCoxPeZJ0MVxoDdxP50"
    "uB2ercKjdo90vuuwd1wQBiwXCcgQhUo)Otx8LWPWIzAyCVBY4DTjJ7ZE8JFb88o3sZY7wAwDTLMLTF"
    "1sMh94l09s6QCAtFArEdHdTKiMMNKsMp6EG72zzo(PkOBG4hIB2MQAik3eCfJTx3E9CkVWEHRCrCSM"
    "kw4zqhHV3)b9V)jdZk0RCfkQd1MRZEifEuWaJKk(5i6nerczEBDEQIdCn7)2G9)CRwqNifOumqADfT"
    "0tIf4omCTWHOJZrhJCTMeUbwkLfoQt1RTY5eroJsEmZGinp5IQKVNON6aoOt46HJGVsx38K5su4NCf"
    "Yr2Zzs41ahaUrNQntQ5mdkLPAo5E947HgPMitffsMvrYCPLqdOXXlIjwcRQQPKdlmOBgnVJJUNMGB2"
    "uSVEb7t88lHh0anRHW8vcYKy8V(6j)DdHV3)9FL83FJbxLtNZGuYajyIO2Q3mltTnLBh3bCBdEyO5v"
    "WLfQg3Tgal7HmhyHRt9wi31jOFykhoH6eg40Rju1qzejY1mlApLJDcCtaultn7QfSx1CuBPwf1dshb"
    "lyRq0yZqzEbdGnpN5ntCwepDWhs94BMpiHYXLP0ezLuu0ewMobc3umBj4kHM1WRfYyRywSyCZLUJLO"
    "ZRkMTO1fw2q9a9RjoNRHlWXtQY4kvk122SBTvYZegcy4vqrIVKAl1SYTUzhDpME1m4ifMxm5kuRI4Y"
    "sNwJtD(tBDWk2UaPywWy42auVPn7oBA5q9iBWempGLmp(Lnx2yMmoGVuKyXcXor0q9NQ6nJug(iwrN"
    "XSIo1TkSgKzHdUb3nzRdWK03(XoHm8oOan8WGc8oHfG31dbVphW7HaeW7fE)0qn8bGpiSiwt5JaFu4"
    "dpj85yGhPSPNXgzGWPGpZrGpRd4JbF80ciIM8ntD2cAiZ8hprtoeC79d3bPbfOvYNlsswLXnEPja3j"
    "zGvP08GsizEsoQNa91N6bWtkGLSfvftaygBVD1XP85nijdwa6g6bUPNaUh8PNxrXqiHvE7KnEUI4j7"
    "wJ00iore8XOEWCwj7X1iFsf1wkCC2iNjESubIUivHqxKhXAUeVkC6Vt4QDc7ZPzgzkZvOARriThMLl"
    "d6bivUWQvb50EGrICYQwNmj5ektpTW0aKFnRa08v69g36e0xW5uuY7GLorbWlUJkRtsKNhjZgl0OHy"
    "H7fJnbzylssYsSx3E8H1A9xwF00DmsM4ryN2TMOmPLmKqTshJ5OSs1vk8nG7ZjeW5cDdchceXqBLal"
    "mvtW0Mfi6YNzbc88G8oazmdXmkSpAGWuFhoRTKoOHvXbDScoymjuOwvAyMjHIvKKHzF89aLmzwyW7b"
    "PYRKv1BuaEtBO(i8MfG3I5j8wTKaHhI8X8lCDWBJHqKvVWezmLTgUmMSsOZycBfk9NWb8jHpf8iWNM"
    "qM)qLG3TWchKCw70CeY1(rGpVvQXJIZ2EcCq)laFrsIanfWkD4lzLaaFz4RaFvbqTAfuc7Eobm422W"
    "93fx78JMQ9HGV2KWxhZLHhhtcGLUz4BcFl4XeGFi8JGVJF47cFp4BdLHVVd4hyYGieRqygp8KvilMv"
    "YWvOifQQPswdJSVZBK7Xj8JfGFId4NAYFKQRHbChhlCckx6UDsPqF6RKWEwod(HkXIsYKh2q48zqpm"
    "Lv0m0cHUqyre6cH2CdWRLqLS4l30tCUPri1aKh)XGLqIfOCgmZ42UBkFGGxBK8QEDcE6BDW0rfS8ru"
    "B2uTly8uPIpuDAEAXhjv0iXc9CRKtsPy)AOZwajNPuIRO9t5XRzXmYxSm5J(SEOqM5jwKAgRy2GECC"
    "(k(5txImCu6tqEOYKJRu7BrIrnTeG12gOYic0zwPoa1lsjiMzAzSmid9etsF0VGKdfOdeve)LntVBb"
    "nFEqyP2AqGUkVeZjPeUhdESjXsbSvlbBL6I5AyMrfUw)WtomHUriVygQ)YrINT7U7AqpsZPrOpt10o"
    "NaEFoNVcBAsIIL72X85nI0bpLaXB3CcgMyr4xeEMnbdEAHDCxEnYdHLViOBWpZUI6p)5GFrfUe8lH)"
    "Ga8RHFd8Bpe87Ca)EZt(xXa)rhWFwaag4pXaR0m8x2I4Pj89SKq5v0vNyLbsc1ZyEvXGQ)Yt1kxjTX"
    "6vp1qTzJVdqqvl8fJ0MAcyqLwpP2YKw4c(A7Xn(AVnaNnk73Yz3XuNxCWhmwCE4dgZW4dgzW4dgL2g"
    "4dMpIdPwacMFxFIw4kPyM5B(lhBKy9ptIKgJf4mwycbpX4cgHRr2DZYxQb62UjovlH)YX0amxKKdKW"
    "KNUJvaQnXzC20JMSNUq9C2USXRieuYeUiaxdjopTWfgx2jvmFrhx2DP)0YnvcR4CH6P)d2yDM4E4hi"
    "UEVQ3FcXl(6mwmcIQ4LRVCXxFjHzP6ZRaJKqhT1DUEg3y0PSb27FBxGX6ItGN76vV9KZ2W0MNw4LKA"
    "z(3YAzyU6oMOrXfUmfN2T7blIBQ0gxIsqJGM4cgESXfl80eEOqE9zmncjpFkzBwQZlfLX8VDLX2OoM"
    "hQrLSP7wze9yHMsnS3DjLSX2aLSQ4Y2VzSxjPK5FB2PmTlHgfYe7mVuBAXc0rViBCn22vilr1oL3IG"
    "ZfOBSxX0PS)l6oLJ3yNY5lnokFod3dlfER3P8UsPLx62PS)TtNY0NwCxPt5y(CxuouFSZe2NnELyB1"
    "P82T(YlZ6u2)fDNYd3y9Lw9Mm2iPpJs7dxA3Qt5n6vX8FU6lx4)cw4NTrGPxFUhz8UlPhzwF7wf(VW"
    "aZLR8Fr)oYoRQN58LySz70OvBGn5fX7i7IbCUCL)gYWs1yL)o7tD02gPO7zfv26v(Bui7vyVJm)xAE"
    "hzUJoZuNPOrYS8zSXRr2wv(3Ufy()Uk)J2ybMXVFX8DOMYxmXHFb8DKTfLWEf)7iZ)UY7iBAPeThPy"
    "FHJnxsBG907G3rwNEQ8RWC5km7E)kmJzxHXVzfgeFb35t2TVakU3g)kmx9L)vyMSsdR(8SBvIjrEJI"
    "PoD7JWpy13kZ4vkX4Fl9ZWC1x(NH5cwI5mweF7smJnm6mEq6jzhsF37HljAxxoJzt6jB3mJrW7S54h"
    "oBsFAdBdXVUTygZ6nD9N3whJGpR30rGRz9MUXgEC(1B6wj7FPBF9MUJgyBR3KB4zwVjpWdUEtDq5BR"
    "3uN2UZduDNmvlVRNXMoApCJoYzC3xfE36n5fUV1BQhRWeD)TvDhVD3RDSA2SBv2n0G0A3ALD7M6Ahh"
    "UM1obuAT7KSpSEW1Ul4Mx7K0TP2AUP7jT18q3qAR1bzLq3CxRDpv2ixvUJKDNvL9P4A9wZ(3c79K9e"
    "gzdCDvR1hDBBzUdUiRYxFnBHl6M7YCB)vDT7V8adoLrYzfmckiu7(YATWqG1I0iOGto2k4H)TpE8gG"
    "NSuDiXWcNoFhcJMTNrCVHibjAxZ7K4fEpCIg9W(hnRVUJ5B2qDfzt4k17Hmxd1d)77RQhYSFShY0cv"
    "fzDMRVQpYCeA276mUUaf3wN52X(lZDAM0nqRr7PO35cNX9C2(8KnK0ToZDvjTBDMtIxXmNQ2uVDrpS"
    "ZnWdB90rdnq)9O7T9y2Ei3oYdp6(FHjgoSNizvAn3ai9S2Ey6lzE4gfd9K7mdej5yQSCLS9WmxAq5e"
    "BShAKumsNPg0J75632d5VK5HBek3EYefthy8CXdpKThIU0GYBsmCM(tio0u9hotQ2T9WSxY8WnmtzU"
    "ZMiEc(ZMCKQ)2(52sEylZ8mJ1IUQRIiUPjBL(jYOWJY4QvUCizJtMJ8FDoodeFB)pa"
)
