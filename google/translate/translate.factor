! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs google http.client io json.reader kernel locals
namespaces sequences urls urls.secure ;

IN: google.translate

CONSTANT: languages H{
    { "Afrikaans" "af" }
    { "Albanian" "sq" }
    { "Arabic" "ar" }
    { "Belarusian" "be" }
    { "Bulgarian" "bg" }
    { "Catalan" "ca" }
    { "Chinese Simplified" "zh-CN" }
    { "Chinese Traditional" "zh-TW" }
    { "Croatian" "hr" }
    { "Czech" "cs" }
    { "Danish" "da" }
    { "Dutch" "nl" }
    { "English" "en" }
    { "Estonian" "et" }
    { "Filipino" "tl" }
    { "Finnish" "fi" }
    { "French" "fr" }
    { "Galician" "gl" }
    { "German" "de" }
    { "Greek" "el" }
    { "Haitian Creole" "ht" }
    { "Hebrew" "iw" }
    { "Hindi" "hi" }
    { "Hungarian" "hu" }
    { "Icelandic" "is" }
    { "Indonesian" "id" }
    { "Irish" "ga" }
    { "Italian" "it" }
    { "Japanese" "ja" }
    { "Latvian" "lv" }
    { "Lithuanian" "lt" }
    { "Macedonian" "mk" }
    { "Malay" "ms" }
    { "Maltese" "mt" }
    { "Norwegian" "no" }
    { "Persian" "fa" }
    { "Polish" "pl" }
    { "Portuguese" "pt" }
    { "Romanian" "ro" }
    { "Russian" "ru" }
    { "Serbian" "sr" }
    { "Slovak" "sk" }
    { "Slovenian" "sl" }
    { "Spanish" "es" }
    { "Swahili" "sw" }
    { "Swedish" "sv" }
    { "Thai" "th" }
    { "Turkish" "tr" }
    { "Ukrainian" "uk" }
    { "Vietnamese" "vi" }
    { "Welsh" "cy" }
    { "Yiddish" "yi" }
}

:: translate-url ( text source target -- url )
    URL" https://www.googleapis.com/language/translate/v2"
        google-api-key get-global "key" set-query-param
        source "source" set-query-param
        target "target" set-query-param
        text "q" set-query-param ;

: translate ( text source target -- seq )
    translate-url http-get nip json>
    { "data" "translations" } [ swap at ] each
    [ "translatedText" swap at ] map ;

: translate. ( text source target -- )
    translate [ print ] each ;
