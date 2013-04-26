! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;

IN: ta-lib.ffi

<< "ta-lib" {
    { [ os windows? ] [ "libta_lib.dll" ] }
    { [ os macosx?  ] [ "libta_lib.dylib" ] }
    { [ os unix?    ] [ "libta_lib.so" ] }
} cond cdecl add-library >>

LIBRARY: ta-lib

FUNCTION: c-string TA_GetVersionString ( ) ;
FUNCTION: c-string TA_GetVersionMajor ( ) ;
FUNCTION: c-string TA_GetVersionMinor ( ) ;
FUNCTION: c-string TA_GetVersionBuild ( ) ;
FUNCTION: c-string TA_GetVersionDate ( ) ;
FUNCTION: c-string TA_GetVersionTime ( ) ;

TYPEDEF: int TA_RetCode

FUNCTION: TA_RetCode TA_Initialize ( ) ;
FUNCTION: TA_RetCode TA_Shutdown ( ) ;

ENUM: RetCode
    TA_SUCCESS,
    TA_LIB_NOT_INITIALIZE,
    TA_BAD_PARAM,
    TA_ALLOC_ERR,
    TA_GROUP_NOT_FOUND,
    TA_FUNC_NOT_FOUND,
    TA_INVALID_HANDLE,
    TA_INVALID_PARAM_HOLDER,
    TA_INVALID_PARAM_HOLDER_TYPE,
    TA_INVALID_PARAM_FUNCTION,
    TA_INPUT_NOT_ALL_INITIALIZE,
    TA_OUTPUT_NOT_ALL_INITIALIZE,
    TA_OUT_OF_RANGE_START_INDEX,
    TA_OUT_OF_RANGE_END_INDEX,
    TA_INVALID_LIST_TYPE,
    TA_BAD_OBJECT,
    TA_NOT_SUPPORTED
    { TA_INTERNAL_ERROR 5000 }
    { TA_UNKNOWN_ERR 0xFFFF } ;

ENUM: MA_Type
    TA_MAType_SMA,
    TA_MAType_EMA,
    TA_MAType_WMA,
    TA_MAType_DEMA,
    TA_MAType_TEMA,
    TA_MAType_TRIMA,
    TA_MAType_KAMA,
    TA_MAType_MAMA,
    TA_MAType_T3 ;

FUNCTION: TA_RetCode TA_MOM ( int startIdx, int endIdx, double* inReal, int optInTimePeriod, int* outBegIdx, int* outNBElement, double* outReal ) ;
FUNCTION: int TA_MOM_Lookback ( int optInTimePeriod ) ;
