USING: calendar kernel math prettyprint qw sequences ;
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
    crave cross scold shirk tasty unlit
}

: wordle. ( date -- )
    2021 6 19 <date> time- duration>days >integer
    wordles [ length mod ] [ nth ] bi . ;
