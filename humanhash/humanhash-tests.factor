USING: tools.test ;

IN: humanhash

{ { 205 128 156 96 } } [
    { 96 173 141 13 135 27 96 149 128 130 151 } 4 compress-bytes
] unit-test

{ "sodium-magnesium-nineteen-hydrogen" } [
    "60ad8d0d871b6095808297" humanhash
] unit-test
