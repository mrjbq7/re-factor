USING: ascii calendar calendar.format io kernel math prettyprint
qw sequences ;
IN: wordle

CONSTANT: wordles qw{
    cigar rebut sissy humph awake blush focal evade naval serve
    heath dwarf model karma stink grade quiet bench abate feign
    major death fresh crust stool colon abase marry react batty
    pride floss helix croak staff paper unfed whelp trawl outdo
    adobe crazy sower repay digit crate cluck spike mimic pound
    maxim linen unmet flesh booby forth first stand belly ivory
    seedy print yearn drain bribe stout panel crass flume offal
    agree error swirl argue bleed delta flick totem wooer front
    shrub parry biome lapel start greet goner golem lusty loopy
    round audit lying gamma labor islet civic forge corny moult
    basic salad agate spicy spray essay fjord spend kebab guild
    aback motor alone hatch hyper thumb dowry ought belch dutch
    pilot tweed comet jaunt enema steed abyss growl fling dozen
    boozy erode world gouge click briar great altar pulpy blurt
    coast duchy groin fixer group rogue badly smart pithy gaudy
    chill heron vodka finer surer radio rouge perch retch wrote
    clock tilde store prove bring solve cheat grime exult usher
    epoch triad break rhino viral conic masse sonic vital trace
    using peach champ baton brake pluck craze gripe weary picky
    acute ferry aside tapir troll unify rebus boost truss siege
    tiger banal slump crank gorge query drink favor abbey tangy
    panic solar shire proxy point robot prick wince crimp knoll
    sugar whack mount perky could wrung light those moist shard
    pleat aloft skill elder frame humor pause ulcer ultra robin
    cynic aroma caulk shake dodge swill tacit other thorn trove
    bloke vivid spill chant choke rupee nasty mourn ahead brine
    cloth hoard sweet month lapse watch today focus smelt tease
    cater movie saute allow renew their slosh purge chest depot
    epoxy nymph found shall stove lowly snout trope fewer shawl
    natal comma foray scare stair black squad royal chunk mince
    shame cheek ample flair foyer cargo oxide plant olive inert
    askew heist shown zesty trash larva forgo story hairy train
    homer badge midst canny shine gecko farce slung tipsy metal
    yield delve being scour glass gamer scrap money hinge album
    vouch asset tiara crept bayou atoll manor creak showy phase
    froth depth gloom flood trait girth piety goose float donor
    atone primo apron blown cacao loser input gloat awful brink
    smite beady rusty retro droll gawky hutch pinto egret lilac
    sever field fluff agape voice stead berth madam night bland
    liver wedge roomy wacky flock angry trite aphid tryst midge
    power elope cinch motto stomp upset bluff cramp quart coyly
    youth rhyme buggy alien smear unfit patty cling glean label
    hunky khaki poker gruel twice twang shrug treat waste merit
    woven needy clown irony ruder gauze chief onset prize fungi
    charm gully inter whoop taunt leery class theme lofty tibia
    booze alpha thyme doubt parer chute stick trice alike recap
    saint glory grate admit brisk soggy usurp scald scorn leave
    twine sting bough marsh sloth dandy vigor howdy enjoy valid
    ionic equal floor catch spade stein exist quirk denim grove
    spiel mummy fault foggy flout carry sneak libel waltz aptly
    piney inept aloud photo dream stale begin spell rainy unite
    medal valet inane maple snarl baker there glyph avert brave
    axiom prime drive feast itchy clean happy tepid undue study
    eject chafe torso adore woken amber joust infer braid knock
    naive apply spoke usual rival probe chord taper slate third
    lunar excel aorta poise extra judge condo impel havoc molar
    manly whine skirt antic layer sleek belie lemon opera pixie
    grimy sedan leapt human koala spire frock adopt chard mucky
    alter blurb matey elude count maize beefy worry flirt fishy
    crave cross scold shirk tasty unlit dance ninth apple flail
    stage heady debug giant usage sound salsa magic cache avail
    kiosk sweat ruddy riper vague arbor fifty syrup worse polka
    moose above squat trend toxic pinky horse regal where revel
    email birth blame surly sweep cider mealy yacht credo glove
    tough duvet staid grout voter untie guano hurry beset bread
    every march stock flora ratio smash leafy locus ledge snafu
    under qualm borax carat thief agony dwelt whiff hound thump
    plate kayak broke unzip ditto joker metro logic circa cedar
    plaza range sulky horde guppy below anger ghoul aglow cocoa
    ethic broom snack acrid scarf canoe latte plank shorn grief
    flask brash igloo clerk utter bagel swine ramen skimp mouse
    kneel agile jazzy humid nanny beast ennui scout hater crumb
    balsa again guard wrong plunk crime maybe strap ranch shyly
    kazoo frost crane taste covet grand rodeo guest about tract
    diner straw bleep mossy hotel irate venom windy donut cower
    enter folly earth whirl barge fiend crone topaz droop flyer
    tonic flank burly froze whale hobby wheel heart disco ethos
    curly bathe style tenth beget party chart anode polyp brook
    bully lover empty hello quick wrath snaky index scrub amiss
    exact magma quest beach spice verve wordy ocean choir peace
    write caper audio bride space onion await giddy birch gnash
    dwell rouse lucky quote older whisk clear rayon exert angel
    music frank close snare stone brush carol right rocky loyal
    smile coach azure daddy beret merry while spurt bunch chime
    viola binge truth snail skunk knelt uncle agent leaky graph
    adult mercy splat occur smirk given tempo cause retry pique
    noble mason phony grail bleak noise until ardor mania flare
    trade limit ninja glaze leash actor meant green sassy sight
    trust tardy think queue candy piano pixel queen throw guide
    solid tawny scope sushi resin taken genre adapt worst young
    woman sleep sharp shift chain house these spent would topic
    globe bacon funny table small built touch slope grace evoke
    phone daisy learn child three salty bulky expel leggy ember
    snake aloof block relic still tweak north large thing stole
    court blond lunch doing heard route brief threw liner final
    stony cable lunge scant twirl aging mural alive cleft micro
    verge repel which after place stiff fried never pasta scram
    talon ascot stash psalm ridge price match build heavy apart
    piper smith often sense devil image forty urban state flame
    hunch teary clone early cheer grasp pesky heave local since
    erupt toxic snort spelt abide lingo shade decay risen towel
    sally mayor stung speak realm force taboo frond serum plait
    climb wrist finch voila breed merge broth louse whiny steel
    blimp equip shank tithe facet raise lucid jolly laser rover
    overt intro vapid gleam prune craft prowl diary slice ebony
    value decal shave musty pious jerky media tidal outer cumin
    amass pinch stall tutor briny hitch nicer dingo exalt swish
    glide titan bevel skier minus papal gummy chaos basin bravo
    stark groom organ ether melon hence crowd manga swung deter
    angst vault proud grind prior cover terse scent paint edict
    bugle dolly savor knead order drove zebra buddy adage inlay
    thigh debut crush scoff canon shape blare gaunt cameo jiffy
    enact video swoon decoy quite nerdy refer shaft speck cadet
    prong forte porch awash juice smock super feral penne chalk
    flake scale lower ensue anvil macaw saucy ounce medic scone
    skiff neigh shore acorn brace storm lanky meter delay mulch
    brute leech filet skate stake crown lithe flunk knave spout
    mushy camel faint stern widen rerun owner drawn debit rebel
    aisle brass harsh broad recur honey beaut fully press smoke
    seven teach steam handy torch thank faith brain rider cloud
    modem shell wagon title miner lager flour joint mommy carve
    gusty stain prone gamut corer grant halve stint fiber dicey
    spoon shout goofy bossy frown wreak sandy bawdy tunic easel
    weird sixth snoop blaze vinyl octet truly event ready swell
    inner stoic flown primp uvula tacky visor tally frail going
    niche spine pearl jelly twist brown witch slang chock hippo
    dogma mauve guile shaky crypt endow shove hilly hyena flung
    patio plumb vying boxer drool funky boast scowl hefty stray
    flash blade brawn sauna eagle share affix grain decry mambo
    stare lemur nerve chose cheap relax cyber sprig atlas draft
    wafer crawl dingy total cloak fancy knack flint prose silly
    rower squid icing reach upper crepe crisp sunny shunt fever
    udder false toast rivet chore revue tooth pedal pupil swath
    steep bonus goody score rapid rumba ditty crook suave trail
    indie madly roach clove cream otter gland dryer award lodge
    fuzzy hover deity spear check scrum alert troop navel greed
    spite track mango chase piece ladle stamp lasso timer spark
    baste nudge amble dopey angle shelf elbow sheet verse sorry
    quota booty jewel curse shear krill foamy villa hazel spare
    wheat turbo arrow nurse laugh crest ashen moral stood dirge
    inbox patch spate artsy ozone genie known clash weedy dummy
    bliss idler adept whose patsy trout shush suite macho balmy
    tripe yeast dowel bicep aware bongo eager fifth grown livid
    pitch borne alarm folio shuck suede grift drone sport polar
    quash idiom habit rough preen admin cease datum edify reuse
    lease board taffy plaid vixen bilge ghost quail petty prank
}

: wordle. ( date -- )
    2021 6 19 <date> time- duration>days >integer
    wordles [ length mod ] [ nth ] bi . ;

: all-wordles. ( -- )
    2021 6 19 <date> wordles [
        over
        [ timestamp>ymd write bl ]
        [ >upper print ]
        [ 1 days time+ ] tri*
    ] each drop ;
