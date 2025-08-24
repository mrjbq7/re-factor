! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data combinators
combinators.short-circuit formatting kernel locals math
math.order sequences sequences.private specialized-arrays
ta-lib.ffi ;

IN: ta-lib

SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: int

<PRIVATE

: ta-check-success ( ret_code -- )
    {
        { 0 [ f ] }
        { 1 [ "Library Not Initialized (TA_LIB_NOT_INITIALIZE)" ] }
        { 2 [ "Bad Parameter (TA_BAD_PARAM)" ] }
        { 3 [ "Allocation Error (TA_ALLOC_ERR)" ] }
        { 4 [ "Group Not Found (TA_GROUP_NOT_FOUND)" ] }
        { 5 [ "Function Not Found (TA_FUNC_NOT_FOUND)" ] }
        { 6 [ "Invalid Handle (TA_INVALID_HANDLE)" ] }
        { 7 [ "Invalid Parameter Holder (TA_INVALID_PARAM_HOLDER)" ] }
        { 8 [ "Invalid Parameter Holder Type (TA_INVALID_PARAM_HOLDER_TYPE)" ] }
        { 9 [ "Invalid Parameter Function (TA_INVALID_PARAM_FUNCTION)" ] }
        { 10 [ "Input Not All Initialized (TA_INPUT_NOT_ALL_INITIALIZE)" ] }
        { 11 [ "Output Not All Initialized (TA_OUTPUT_NOT_ALL_INITIALIZE)" ] }
        { 12 [ "Out-of-Range Start Index (TA_OUT_OF_RANGE_START_INDEX)" ] }
        { 13 [ "Out-of-Range End Index (TA_OUT_OF_RANGE_END_INDEX)" ] }
        { 14 [ "Invalid List Type (TA_INVALID_LIST_TYPE)" ] }
        { 15 [ "Bad Object (TA_BAD_OBJECT)" ] }
        { 16 [ "Not Supported (TA_NOT_SUPPORTED)" ] }
        { 5000 [ "Internal Error (TA_INTERNAL_ERROR)" ] }
        { 65535 [ "Unknown Error (TA_UNKNOWN_ERR)" ] }
        [ "Unknown Error (%d)" sprintf ]
    } case [ throw ] when* ;

ERROR: different-array-lengths ;

: check-array ( real -- real' )
    dup double-array? [ double >c-array ] unless ;

:: check-length2 ( a1 a2 -- n )
    a1 length :> len1
    a2 length :> len2
    len1 len2 = [ different-array-lengths ] unless
    len1 ;

:: check-length3 ( a1 a2 a3 -- n )
    a1 length :> len1
    a2 length :> len2
    a3 length :> len3
    len1 len2 = [ different-array-lengths ] unless
    len2 len3 = [ different-array-lengths ] unless
    len1 ;

:: check-length4 ( a1 a2 a3 a4 -- n )
    a1 length :> len1
    a2 length :> len2
    a3 length :> len3
    a4 length :> len4
    len1 len2 = [ different-array-lengths ] unless
    len2 len3 = [ different-array-lengths ] unless
    len3 len4 = [ different-array-lengths ] unless
    len1 ;

:: check-begidx1 ( a1 -- n )
    a1 [ fp-nan? not ] find drop [ a1 length 1 - ] unless* ;

:: check-begidx2 ( a1 a2 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: check-begidx3 ( a1 a2 a3 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
            [ a3 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: check-begidx4 ( a1 a2 a3 a4 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
            [ a3 nth-unsafe fp-nan? ]
            [ a4 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: make-double-array ( len lookback -- seq )
    len double (c-array) :> out
    len lookback min [ 0/0. swap out set-nth-unsafe ] each-integer
    out ;

:: make-int-array ( len lookback -- seq )
    len int (c-array) :> out
    len lookback min [ 0 swap out set-nth-unsafe ] each-integer
    out ;

PRIVATE>

:: ACCBANDS ( high low close timeperiod -- realupperband realmiddleband reallowerband )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ACCBANDS_Lookback begidx + :> lookback
    len lookback make-double-array :> outrealupperband
    len lookback make-double-array :> outrealmiddleband
    len lookback make-double-array :> outreallowerband
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outrealupperband lookback tail-slice outrealmiddleband lookback tail-slice outreallowerband lookback tail-slice TA_ACCBANDS ta-check-success
    outrealupperband outrealmiddleband outreallowerband ;

:: ACOS ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_ACOS_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_ACOS ta-check-success
    outreal ;

:: AD ( high low close volume -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    volume check-array :> involume
    inhigh inlow inclose involume check-length4 :> len
    inhigh inlow inclose involume check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_AD_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice involume begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_AD ta-check-success
    outreal ;

:: ADD ( real0 real1 -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_ADD_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_ADD ta-check-success
    outreal ;

:: ADOSC ( high low close volume fastperiod slowperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    volume check-array :> involume
    inhigh inlow inclose involume check-length4 :> len
    inhigh inlow inclose involume check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    fastperiod  slowperiod TA_ADOSC_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice involume begidx tail-slice fastperiod slowperiod outbegidx outnbelement outreal lookback tail-slice TA_ADOSC ta-check-success
    outreal ;

:: ADX ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ADX_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ADX ta-check-success
    outreal ;

:: ADXR ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ADXR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ADXR ta-check-success
    outreal ;

:: APO ( real fastperiod slowperiod matype -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    fastperiod  slowperiod  matype TA_APO_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice fastperiod slowperiod matype outbegidx outnbelement outreal lookback tail-slice TA_APO ta-check-success
    outreal ;

:: AROON ( high low timeperiod -- aroondown aroonup )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_AROON_Lookback begidx + :> lookback
    len lookback make-double-array :> outaroondown
    len lookback make-double-array :> outaroonup
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice timeperiod outbegidx outnbelement outaroondown lookback tail-slice outaroonup lookback tail-slice TA_AROON ta-check-success
    outaroondown outaroonup ;

:: AROONOSC ( high low timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_AROONOSC_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_AROONOSC ta-check-success
    outreal ;

:: ASIN ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_ASIN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_ASIN ta-check-success
    outreal ;

:: ATAN ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_ATAN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_ATAN ta-check-success
    outreal ;

:: ATR ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ATR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ATR ta-check-success
    outreal ;

:: AVGPRICE ( open high low close -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_AVGPRICE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_AVGPRICE ta-check-success
    outreal ;

:: AVGDEV ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_AVGDEV_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_AVGDEV ta-check-success
    outreal ;

:: BBANDS ( real timeperiod nbdevup nbdevdn matype -- realupperband realmiddleband reallowerband )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  nbdevup  nbdevdn  matype TA_BBANDS_Lookback begidx + :> lookback
    len lookback make-double-array :> outrealupperband
    len lookback make-double-array :> outrealmiddleband
    len lookback make-double-array :> outreallowerband
    0 endidx inreal begidx tail-slice timeperiod nbdevup nbdevdn matype outbegidx outnbelement outrealupperband lookback tail-slice outrealmiddleband lookback tail-slice outreallowerband lookback tail-slice TA_BBANDS ta-check-success
    outrealupperband outrealmiddleband outreallowerband ;

:: BETA ( real0 real1 timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_BETA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_BETA ta-check-success
    outreal ;

:: BOP ( open high low close -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_BOP_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_BOP ta-check-success
    outreal ;

:: CCI ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_CCI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_CCI ta-check-success
    outreal ;

:: CDL2CROWS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL2CROWS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL2CROWS ta-check-success
    outinteger ;

:: CDL3BLACKCROWS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3BLACKCROWS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3BLACKCROWS ta-check-success
    outinteger ;

:: CDL3INSIDE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3INSIDE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3INSIDE ta-check-success
    outinteger ;

:: CDL3LINESTRIKE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3LINESTRIKE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3LINESTRIKE ta-check-success
    outinteger ;

:: CDL3OUTSIDE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3OUTSIDE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3OUTSIDE ta-check-success
    outinteger ;

:: CDL3STARSINSOUTH ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3STARSINSOUTH_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3STARSINSOUTH ta-check-success
    outinteger ;

:: CDL3WHITESOLDIERS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDL3WHITESOLDIERS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDL3WHITESOLDIERS ta-check-success
    outinteger ;

:: CDLABANDONEDBABY ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLABANDONEDBABY_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLABANDONEDBABY ta-check-success
    outinteger ;

:: CDLADVANCEBLOCK ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLADVANCEBLOCK_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLADVANCEBLOCK ta-check-success
    outinteger ;

:: CDLBELTHOLD ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLBELTHOLD_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLBELTHOLD ta-check-success
    outinteger ;

:: CDLBREAKAWAY ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLBREAKAWAY_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLBREAKAWAY ta-check-success
    outinteger ;

:: CDLCLOSINGMARUBOZU ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLCLOSINGMARUBOZU_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLCLOSINGMARUBOZU ta-check-success
    outinteger ;

:: CDLCONCEALBABYSWALL ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLCONCEALBABYSWALL_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLCONCEALBABYSWALL ta-check-success
    outinteger ;

:: CDLCOUNTERATTACK ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLCOUNTERATTACK_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLCOUNTERATTACK ta-check-success
    outinteger ;

:: CDLDARKCLOUDCOVER ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLDARKCLOUDCOVER_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLDARKCLOUDCOVER ta-check-success
    outinteger ;

:: CDLDOJI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLDOJI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLDOJI ta-check-success
    outinteger ;

:: CDLDOJISTAR ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLDOJISTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLDOJISTAR ta-check-success
    outinteger ;

:: CDLDRAGONFLYDOJI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLDRAGONFLYDOJI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLDRAGONFLYDOJI ta-check-success
    outinteger ;

:: CDLENGULFING ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLENGULFING_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLENGULFING ta-check-success
    outinteger ;

:: CDLEVENINGDOJISTAR ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLEVENINGDOJISTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLEVENINGDOJISTAR ta-check-success
    outinteger ;

:: CDLEVENINGSTAR ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLEVENINGSTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLEVENINGSTAR ta-check-success
    outinteger ;

:: CDLGAPSIDESIDEWHITE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLGAPSIDESIDEWHITE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLGAPSIDESIDEWHITE ta-check-success
    outinteger ;

:: CDLGRAVESTONEDOJI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLGRAVESTONEDOJI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLGRAVESTONEDOJI ta-check-success
    outinteger ;

:: CDLHAMMER ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHAMMER_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHAMMER ta-check-success
    outinteger ;

:: CDLHANGINGMAN ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHANGINGMAN_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHANGINGMAN ta-check-success
    outinteger ;

:: CDLHARAMI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHARAMI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHARAMI ta-check-success
    outinteger ;

:: CDLHARAMICROSS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHARAMICROSS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHARAMICROSS ta-check-success
    outinteger ;

:: CDLHIGHWAVE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHIGHWAVE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHIGHWAVE ta-check-success
    outinteger ;

:: CDLHIKKAKE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHIKKAKE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHIKKAKE ta-check-success
    outinteger ;

:: CDLHIKKAKEMOD ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHIKKAKEMOD_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHIKKAKEMOD ta-check-success
    outinteger ;

:: CDLHOMINGPIGEON ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLHOMINGPIGEON_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLHOMINGPIGEON ta-check-success
    outinteger ;

:: CDLIDENTICAL3CROWS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLIDENTICAL3CROWS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLIDENTICAL3CROWS ta-check-success
    outinteger ;

:: CDLINNECK ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLINNECK_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLINNECK ta-check-success
    outinteger ;

:: CDLINVERTEDHAMMER ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLINVERTEDHAMMER_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLINVERTEDHAMMER ta-check-success
    outinteger ;

:: CDLKICKING ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLKICKING_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLKICKING ta-check-success
    outinteger ;

:: CDLKICKINGBYLENGTH ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLKICKINGBYLENGTH_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLKICKINGBYLENGTH ta-check-success
    outinteger ;

:: CDLLADDERBOTTOM ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLLADDERBOTTOM_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLLADDERBOTTOM ta-check-success
    outinteger ;

:: CDLLONGLEGGEDDOJI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLLONGLEGGEDDOJI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLLONGLEGGEDDOJI ta-check-success
    outinteger ;

:: CDLLONGLINE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLLONGLINE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLLONGLINE ta-check-success
    outinteger ;

:: CDLMARUBOZU ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLMARUBOZU_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLMARUBOZU ta-check-success
    outinteger ;

:: CDLMATCHINGLOW ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLMATCHINGLOW_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLMATCHINGLOW ta-check-success
    outinteger ;

:: CDLMATHOLD ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLMATHOLD_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLMATHOLD ta-check-success
    outinteger ;

:: CDLMORNINGDOJISTAR ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLMORNINGDOJISTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLMORNINGDOJISTAR ta-check-success
    outinteger ;

:: CDLMORNINGSTAR ( open high low close penetration -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    penetration TA_CDLMORNINGSTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice penetration outbegidx outnbelement outinteger lookback tail-slice TA_CDLMORNINGSTAR ta-check-success
    outinteger ;

:: CDLONNECK ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLONNECK_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLONNECK ta-check-success
    outinteger ;

:: CDLPIERCING ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLPIERCING_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLPIERCING ta-check-success
    outinteger ;

:: CDLRICKSHAWMAN ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLRICKSHAWMAN_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLRICKSHAWMAN ta-check-success
    outinteger ;

:: CDLRISEFALL3METHODS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLRISEFALL3METHODS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLRISEFALL3METHODS ta-check-success
    outinteger ;

:: CDLSEPARATINGLINES ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSEPARATINGLINES_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSEPARATINGLINES ta-check-success
    outinteger ;

:: CDLSHOOTINGSTAR ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSHOOTINGSTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSHOOTINGSTAR ta-check-success
    outinteger ;

:: CDLSHORTLINE ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSHORTLINE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSHORTLINE ta-check-success
    outinteger ;

:: CDLSPINNINGTOP ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSPINNINGTOP_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSPINNINGTOP ta-check-success
    outinteger ;

:: CDLSTALLEDPATTERN ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSTALLEDPATTERN_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSTALLEDPATTERN ta-check-success
    outinteger ;

:: CDLSTICKSANDWICH ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLSTICKSANDWICH_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLSTICKSANDWICH ta-check-success
    outinteger ;

:: CDLTAKURI ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLTAKURI_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLTAKURI ta-check-success
    outinteger ;

:: CDLTASUKIGAP ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLTASUKIGAP_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLTASUKIGAP ta-check-success
    outinteger ;

:: CDLTHRUSTING ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLTHRUSTING_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLTHRUSTING ta-check-success
    outinteger ;

:: CDLTRISTAR ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLTRISTAR_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLTRISTAR ta-check-success
    outinteger ;

:: CDLUNIQUE3RIVER ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLUNIQUE3RIVER_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLUNIQUE3RIVER ta-check-success
    outinteger ;

:: CDLUPSIDEGAP2CROWS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLUPSIDEGAP2CROWS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLUPSIDEGAP2CROWS ta-check-success
    outinteger ;

:: CDLXSIDEGAP3METHODS ( open high low close -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inopen inhigh inlow inclose check-length4 :> len
    inopen inhigh inlow inclose check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    TA_CDLXSIDEGAP3METHODS_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inopen begidx tail-slice inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_CDLXSIDEGAP3METHODS ta-check-success
    outinteger ;

:: CEIL ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_CEIL_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_CEIL ta-check-success
    outreal ;

:: CMO ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_CMO_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_CMO ta-check-success
    outreal ;

:: CORREL ( real0 real1 timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_CORREL_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_CORREL ta-check-success
    outreal ;

:: COS ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_COS_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_COS ta-check-success
    outreal ;

:: COSH ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_COSH_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_COSH ta-check-success
    outreal ;

:: DEMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_DEMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_DEMA ta-check-success
    outreal ;

:: DIV ( real0 real1 -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_DIV_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_DIV ta-check-success
    outreal ;

:: DX ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_DX_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_DX ta-check-success
    outreal ;

:: EMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_EMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_EMA ta-check-success
    outreal ;

:: EXP ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_EXP_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_EXP ta-check-success
    outreal ;

:: FLOOR ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_FLOOR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_FLOOR ta-check-success
    outreal ;

:: HT_DCPERIOD ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_DCPERIOD_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_HT_DCPERIOD ta-check-success
    outreal ;

:: HT_DCPHASE ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_DCPHASE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_HT_DCPHASE ta-check-success
    outreal ;

:: HT_PHASOR ( real -- inphase quadrature )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_PHASOR_Lookback begidx + :> lookback
    len lookback make-double-array :> outinphase
    len lookback make-double-array :> outquadrature
    0 endidx inreal begidx tail-slice outbegidx outnbelement outinphase lookback tail-slice outquadrature lookback tail-slice TA_HT_PHASOR ta-check-success
    outinphase outquadrature ;

:: HT_SINE ( real -- sine leadsine )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_SINE_Lookback begidx + :> lookback
    len lookback make-double-array :> outsine
    len lookback make-double-array :> outleadsine
    0 endidx inreal begidx tail-slice outbegidx outnbelement outsine lookback tail-slice outleadsine lookback tail-slice TA_HT_SINE ta-check-success
    outsine outleadsine ;

:: HT_TRENDLINE ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_TRENDLINE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_HT_TRENDLINE ta-check-success
    outreal ;

:: HT_TRENDMODE ( real -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_HT_TRENDMODE_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inreal begidx tail-slice outbegidx outnbelement outinteger lookback tail-slice TA_HT_TRENDMODE ta-check-success
    outinteger ;

:: IMI ( open close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    open check-array :> inopen
    close check-array :> inclose
    inopen inclose check-length2 :> len
    inopen inclose check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_IMI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inopen begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_IMI ta-check-success
    outreal ;

:: KAMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_KAMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_KAMA ta-check-success
    outreal ;

:: LINEARREG ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_LINEARREG_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_LINEARREG ta-check-success
    outreal ;

:: LINEARREG_ANGLE ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_LINEARREG_ANGLE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_LINEARREG_ANGLE ta-check-success
    outreal ;

:: LINEARREG_INTERCEPT ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_LINEARREG_INTERCEPT_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_LINEARREG_INTERCEPT ta-check-success
    outreal ;

:: LINEARREG_SLOPE ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_LINEARREG_SLOPE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_LINEARREG_SLOPE ta-check-success
    outreal ;

:: LN ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_LN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_LN ta-check-success
    outreal ;

:: LOG10 ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_LOG10_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_LOG10 ta-check-success
    outreal ;

:: MA ( real timeperiod matype -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  matype TA_MA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod matype outbegidx outnbelement outreal lookback tail-slice TA_MA ta-check-success
    outreal ;

:: MACD ( real fastperiod slowperiod signalperiod -- macd macdsignal macdhist )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    fastperiod  slowperiod  signalperiod TA_MACD_Lookback begidx + :> lookback
    len lookback make-double-array :> outmacd
    len lookback make-double-array :> outmacdsignal
    len lookback make-double-array :> outmacdhist
    0 endidx inreal begidx tail-slice fastperiod slowperiod signalperiod outbegidx outnbelement outmacd lookback tail-slice outmacdsignal lookback tail-slice outmacdhist lookback tail-slice TA_MACD ta-check-success
    outmacd outmacdsignal outmacdhist ;

:: MACDEXT ( real fastperiod fastmatype slowperiod slowmatype signalperiod signalmatype -- macd macdsignal macdhist )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    fastperiod  fastmatype  slowperiod  slowmatype  signalperiod  signalmatype TA_MACDEXT_Lookback begidx + :> lookback
    len lookback make-double-array :> outmacd
    len lookback make-double-array :> outmacdsignal
    len lookback make-double-array :> outmacdhist
    0 endidx inreal begidx tail-slice fastperiod fastmatype slowperiod slowmatype signalperiod signalmatype outbegidx outnbelement outmacd lookback tail-slice outmacdsignal lookback tail-slice outmacdhist lookback tail-slice TA_MACDEXT ta-check-success
    outmacd outmacdsignal outmacdhist ;

:: MACDFIX ( real signalperiod -- macd macdsignal macdhist )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    signalperiod TA_MACDFIX_Lookback begidx + :> lookback
    len lookback make-double-array :> outmacd
    len lookback make-double-array :> outmacdsignal
    len lookback make-double-array :> outmacdhist
    0 endidx inreal begidx tail-slice signalperiod outbegidx outnbelement outmacd lookback tail-slice outmacdsignal lookback tail-slice outmacdhist lookback tail-slice TA_MACDFIX ta-check-success
    outmacd outmacdsignal outmacdhist ;

:: MAMA ( real fastlimit slowlimit -- mama fama )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    fastlimit  slowlimit TA_MAMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outmama
    len lookback make-double-array :> outfama
    0 endidx inreal begidx tail-slice fastlimit slowlimit outbegidx outnbelement outmama lookback tail-slice outfama lookback tail-slice TA_MAMA ta-check-success
    outmama outfama ;

:: MAVP ( real periods minperiod maxperiod matype -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    periods check-array :> inperiods
    inreal inperiods check-length2 :> len
    inreal inperiods check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    minperiod  maxperiod  matype TA_MAVP_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice inperiods begidx tail-slice minperiod maxperiod matype outbegidx outnbelement outreal lookback tail-slice TA_MAVP ta-check-success
    outreal ;

:: MAX ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MAX_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MAX ta-check-success
    outreal ;

:: MAXINDEX ( real timeperiod -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MAXINDEX_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outinteger lookback tail-slice TA_MAXINDEX ta-check-success
    lookback len outinteger <slice> [ begidx + ] map! drop
    outinteger ;

:: MEDPRICE ( high low -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_MEDPRICE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_MEDPRICE ta-check-success
    outreal ;

:: MFI ( high low close volume timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    volume check-array :> involume
    inhigh inlow inclose involume check-length4 :> len
    inhigh inlow inclose involume check-begidx4 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MFI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice involume begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MFI ta-check-success
    outreal ;

:: MIDPOINT ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MIDPOINT_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MIDPOINT ta-check-success
    outreal ;

:: MIDPRICE ( high low timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MIDPRICE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MIDPRICE ta-check-success
    outreal ;

:: MIN ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MIN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MIN ta-check-success
    outreal ;

:: MININDEX ( real timeperiod -- integer )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MININDEX_Lookback begidx + :> lookback
    len lookback make-int-array :> outinteger
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outinteger lookback tail-slice TA_MININDEX ta-check-success
    lookback len outinteger <slice> [ begidx + ] map! drop
    outinteger ;

:: MINMAX ( real timeperiod -- min max )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MINMAX_Lookback begidx + :> lookback
    len lookback make-double-array :> outmin
    len lookback make-double-array :> outmax
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outmin lookback tail-slice outmax lookback tail-slice TA_MINMAX ta-check-success
    outmin outmax ;

:: MINMAXINDEX ( real timeperiod -- minidx maxidx )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MINMAXINDEX_Lookback begidx + :> lookback
    len lookback make-int-array :> outminidx
    len lookback make-int-array :> outmaxidx
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outminidx lookback tail-slice outmaxidx lookback tail-slice TA_MINMAXINDEX ta-check-success
    lookback len outminidx <slice> [ begidx + ] map! drop
    lookback len outmaxidx <slice> [ begidx + ] map! drop
    outminidx outmaxidx ;

:: MINUS_DI ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MINUS_DI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MINUS_DI ta-check-success
    outreal ;

:: MINUS_DM ( high low timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MINUS_DM_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MINUS_DM ta-check-success
    outreal ;

:: MOM ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_MOM_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_MOM ta-check-success
    outreal ;

:: MULT ( real0 real1 -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_MULT_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_MULT ta-check-success
    outreal ;

:: NATR ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_NATR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_NATR ta-check-success
    outreal ;

:: OBV ( real volume -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    volume check-array :> involume
    inreal involume check-length2 :> len
    inreal involume check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_OBV_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice involume begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_OBV ta-check-success
    outreal ;

:: PLUS_DI ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_PLUS_DI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_PLUS_DI ta-check-success
    outreal ;

:: PLUS_DM ( high low timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_PLUS_DM_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_PLUS_DM ta-check-success
    outreal ;

:: PPO ( real fastperiod slowperiod matype -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    fastperiod  slowperiod  matype TA_PPO_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice fastperiod slowperiod matype outbegidx outnbelement outreal lookback tail-slice TA_PPO ta-check-success
    outreal ;

:: ROC ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ROC_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ROC ta-check-success
    outreal ;

:: ROCP ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ROCP_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ROCP ta-check-success
    outreal ;

:: ROCR ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ROCR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ROCR ta-check-success
    outreal ;

:: ROCR100 ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_ROCR100_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_ROCR100 ta-check-success
    outreal ;

:: RSI ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_RSI_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_RSI ta-check-success
    outreal ;

:: SAR ( high low acceleration maximum -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    acceleration  maximum TA_SAR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice acceleration maximum outbegidx outnbelement outreal lookback tail-slice TA_SAR ta-check-success
    outreal ;

:: SAREXT ( high low startvalue offsetonreverse accelerationinitlong accelerationlong accelerationmaxlong accelerationinitshort accelerationshort accelerationmaxshort -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    inhigh inlow check-length2 :> len
    inhigh inlow check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    startvalue  offsetonreverse  accelerationinitlong  accelerationlong  accelerationmaxlong  accelerationinitshort  accelerationshort  accelerationmaxshort TA_SAREXT_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice startvalue offsetonreverse accelerationinitlong accelerationlong accelerationmaxlong accelerationinitshort accelerationshort accelerationmaxshort outbegidx outnbelement outreal lookback tail-slice TA_SAREXT ta-check-success
    outreal ;

:: SIN ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_SIN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_SIN ta-check-success
    outreal ;

:: SINH ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_SINH_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_SINH ta-check-success
    outreal ;

:: SMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_SMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_SMA ta-check-success
    outreal ;

:: SQRT ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_SQRT_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_SQRT ta-check-success
    outreal ;

:: STDDEV ( real timeperiod nbdev -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  nbdev TA_STDDEV_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod nbdev outbegidx outnbelement outreal lookback tail-slice TA_STDDEV ta-check-success
    outreal ;

:: STOCH ( high low close fastk-period slowk-period slowk-matype slowd-period slowd-matype -- slowk slowd )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    fastk-period  slowk-period  slowk-matype  slowd-period  slowd-matype TA_STOCH_Lookback begidx + :> lookback
    len lookback make-double-array :> outslowk
    len lookback make-double-array :> outslowd
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice fastk-period slowk-period slowk-matype slowd-period slowd-matype outbegidx outnbelement outslowk lookback tail-slice outslowd lookback tail-slice TA_STOCH ta-check-success
    outslowk outslowd ;

:: STOCHF ( high low close fastk-period fastd-period fastd-matype -- fastk fastd )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    fastk-period  fastd-period  fastd-matype TA_STOCHF_Lookback begidx + :> lookback
    len lookback make-double-array :> outfastk
    len lookback make-double-array :> outfastd
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice fastk-period fastd-period fastd-matype outbegidx outnbelement outfastk lookback tail-slice outfastd lookback tail-slice TA_STOCHF ta-check-success
    outfastk outfastd ;

:: STOCHRSI ( real timeperiod fastk-period fastd-period fastd-matype -- fastk fastd )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  fastk-period  fastd-period  fastd-matype TA_STOCHRSI_Lookback begidx + :> lookback
    len lookback make-double-array :> outfastk
    len lookback make-double-array :> outfastd
    0 endidx inreal begidx tail-slice timeperiod fastk-period fastd-period fastd-matype outbegidx outnbelement outfastk lookback tail-slice outfastd lookback tail-slice TA_STOCHRSI ta-check-success
    outfastk outfastd ;

:: SUB ( real0 real1 -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real0 check-array :> inreal0
    real1 check-array :> inreal1
    inreal0 inreal1 check-length2 :> len
    inreal0 inreal1 check-begidx2 :> begidx
    len 1 - begidx - :> endidx
    TA_SUB_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal0 begidx tail-slice inreal1 begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_SUB ta-check-success
    outreal ;

:: SUM ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_SUM_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_SUM ta-check-success
    outreal ;

:: T3 ( real timeperiod vfactor -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  vfactor TA_T3_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod vfactor outbegidx outnbelement outreal lookback tail-slice TA_T3 ta-check-success
    outreal ;

:: TAN ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_TAN_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_TAN ta-check-success
    outreal ;

:: TANH ( real -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    TA_TANH_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_TANH ta-check-success
    outreal ;

:: TEMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_TEMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_TEMA ta-check-success
    outreal ;

:: TRANGE ( high low close -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    TA_TRANGE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_TRANGE ta-check-success
    outreal ;

:: TRIMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_TRIMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_TRIMA ta-check-success
    outreal ;

:: TRIX ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_TRIX_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_TRIX ta-check-success
    outreal ;

:: TSF ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_TSF_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_TSF ta-check-success
    outreal ;

:: TYPPRICE ( high low close -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    TA_TYPPRICE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_TYPPRICE ta-check-success
    outreal ;

:: ULTOSC ( high low close timeperiod1 timeperiod2 timeperiod3 -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod1  timeperiod2  timeperiod3 TA_ULTOSC_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod1 timeperiod2 timeperiod3 outbegidx outnbelement outreal lookback tail-slice TA_ULTOSC ta-check-success
    outreal ;

:: VAR ( real timeperiod nbdev -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod  nbdev TA_VAR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod nbdev outbegidx outnbelement outreal lookback tail-slice TA_VAR ta-check-success
    outreal ;

:: WCLPRICE ( high low close -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    TA_WCLPRICE_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice outbegidx outnbelement outreal lookback tail-slice TA_WCLPRICE ta-check-success
    outreal ;

:: WILLR ( high low close timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    high check-array :> inhigh
    low check-array :> inlow
    close check-array :> inclose
    inhigh inlow inclose check-length3 :> len
    inhigh inlow inclose check-begidx3 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_WILLR_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inhigh begidx tail-slice inlow begidx tail-slice inclose begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_WILLR ta-check-success
    outreal ;

:: WMA ( real timeperiod -- real )
    0 int <ref> :> outbegidx
    0 int <ref> :> outnbelement
    real check-array :> inreal
    inreal length :> len
    inreal check-begidx1 :> begidx
    len 1 - begidx - :> endidx
    timeperiod TA_WMA_Lookback begidx + :> lookback
    len lookback make-double-array :> outreal
    0 endidx inreal begidx tail-slice timeperiod outbegidx outnbelement outreal lookback tail-slice TA_WMA ta-check-success
    outreal ;

STARTUP-HOOK: [ TA_Initialize ta-check-success ]
