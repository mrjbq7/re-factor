! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs assocs.extras google http.client io json.reader
kernel locals namespaces sequences urls urls.secure utils ;

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

: translate ( text source target -- text' )
    translate-url http-get nip json>
    { "data" "translations" } deep-at
    first "translatedText" swap at ;

:: all-translations ( text source -- assoc )
    languages [
        dup source = [ drop text ] [
            [ text source ] dip translate
        ] if
    ] assoc-map ;

:: translation-party ( text source target -- )
    text dup print [
        dup source target translate dup print
        target source translate dup print
        swap dupd = not
    ] loop drop ;

: translatortron ( text targets -- )
    dup rest zip [ translate dup print ] assoc-each drop ;
