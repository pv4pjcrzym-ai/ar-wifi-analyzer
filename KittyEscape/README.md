# Kitty Escape! 🐈

Et hybrid-casual puzzlespil til iPhone (Swift + SpriteKit + SwiftUI).

**Gameplay:** Brættet er fyldt med katte, og hver kat kigger i én retning (pilen i panden).
Tryk på en kat for at få den til at løbe ud af brættet. Står der en anden kat i vejen,
støder den ind i den, og du mister et liv. Få alle kattene ud for at klare banen.

Det er samme genre som dem der ligger i top 10 lige nu (Block Out!, Meowdoku!, Magic Sort!):
man forstår det på 3 sekunder, det spilles med én tommelfinger, og katte-temaet giver et twist.

## Kom i gang

1. Åbn `KittyEscape.xcodeproj` i Xcode 16 eller nyere.
2. Vælg dit team under *Signing & Capabilities*, og ret bundle-id'et `com.example.kittyescape`.
3. Vælg en iPhone-simulator eller din egen iPhone, og tryk ▶︎.

Alle filer i mappen `KittyEscape/` kommer automatisk med i projektet, så nye filer skal bare lægges der.

## Hvad er der med

- Uendelige levels, der genereres ud fra levelnummeret (alle spillere får de samme baner).
  Generatoren sikrer, at alle baner kan løses, og at man aldrig kan låse sig fast.
- Sværhedsgraden stiger: brættet vokser fra 3×4 til 8×11 med flere katte og farver.
- 3 liv pr. bane, 1–3 stjerner, mønter som belønning.
- Hint (30 mønter) og "Continue" efter man har mistet alle liv (50 mønter).
  Her kobles belønnede reklamer på senere.
- "Juice": pop-in-animation, hjerter og støv når en kat slipper ud, rystelse og
  vibration når man rammer forkert, konfetti når banen er klaret.
- Fremskridt gemmes lokalt.

## Filer

| Fil | Indhold |
|---|---|
| `Board.swift` | Spillets regler (ren logik) |
| `LevelGenerator.swift` | Laver banerne og styrer sværhedsgraden |
| `GameSession.swift` | Liv, stjerner, mønter, hint, continue |
| `GameScene.swift` | SpriteKit: tegner brættet, håndterer tryk og animationer |
| `CatArt.swift` | Tegner katten (vektor, gemmes som tekstur) |
| `GameView.swift` / `HomeView.swift` | SwiftUI-skærme og HUD |
| `PlayerProgress.swift` | Gemt level og mønter |

## Næste skridt mod top 10

1. **Spil det selv og finjustér** sværhedskurven i `LevelGenerator.spec(for:)`.
2. **Lyd:** miav, pop og baggrundsmusik.
3. **Analytics** (f.eks. Firebase eller GameAnalytics): retention dag 1/7, hvor folk stopper.
4. **Reklamer:** AppLovin MAX eller AdMob. Belønnet video til Continue og hint,
   pauseskærm efter hver 3. bane fra level 5 og frem, og køb af "Fjern reklamer".
5. **Meta-lag:** daglig belønning, samling af kattetyper, events.
6. **Test markedet:** lav 15–30 sekunders videoer af gameplay, og mål pris pr. installation
   og dag-1-retention. Send tallene til publishers (Voodoo, Homa, Supersonic, CrazyLabs).
7. **Soft launch** i et par lande, derefter globalt.
