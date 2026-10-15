# Kitty Escape! 🐈

Et hybrid-casual puzzlespil til iPhone (Swift + SpriteKit + SwiftUI, iOS 17+).

**Gameplay:** Brættet er fyldt med katte, og hver kat kigger i én retning (pilen i panden).
Tryk på en kat for at få den til at løbe ud af brættet. Står der en anden kat i vejen,
støder den ind i den, og du mister et liv. Få alle kattene ud for at klare banen.

## Kom i gang

1. Åbn `KittyEscape.xcodeproj` i Xcode 16 eller nyere.
2. Vælg dit team under *Signing & Capabilities*, og ret bundle-id'et `com.example.kittyescape`
   til dit eget (f.eks. `dk.ditnavn.kittyescape`). Ret også produkt-id'erne i `Store.swift`
   og `KittyEscape.storekit`, så de passer.
3. Test køb lokalt: *Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration*,
   og vælg `KittyEscape.storekit`.
4. Vælg en iPhone eller en simulator, og tryk ▶︎.

Alle filer i mappen `KittyEscape/` kommer automatisk med i projektet.

## Indhold

**Spillet**
- Uendelige levels, der genereres ud fra levelnummeret (alle spillere får de samme baner).
  Alle baner kan løses, og man kan aldrig låse sig fast.
- Sværhedsgraden stiger fra 3×4 til 8×11, med flere katte og farver.
- Sovende katte fra level 6: de skal have et tryk for at vågne først.
- HARD-baner hvert 5. level fra level 10, med dobbelt så mange mønter.
- 3 liv, 1–3 stjerner, hint (30 mønter) og continue (50 mønter eller en reklame).
- Tutorial på level 1: en finger viser, hvor man skal trykke.

**Fornemmelse ("juice")**
- Lyde: pop (stiger i tone ved combo), miav, bump, vækning, sejr, mønter og klik. Plus baggrundsmusik.
- Vibration, rystelse, støv og hjerter når en kat slipper ud, combo-tekst og konfetti.

**Ting man kommer tilbage for**
- 12 katteracer man låser op undervejs. De dukker op på banerne og kan vælges som favorit.
- Daglig gave med en serie over 7 dage (20 → 150 mønter).

**Indtjening**
- StoreKit 2: "Fjern reklamer" (engangskøb), 500 og 3000 mønter, samt gendannelse af køb.
- Pladser til reklamer (`Ads` i `Services.swift`): belønnet video ved continue og pauseskærm
  hver 3. bane fra level 5. Det virker, når der er sat et reklame-SDK på.
- Pladser til analytics (`Analytics.log`): level_start, level_complete, level_fail, hint, revive, purchase og daily.

**Andet:** startskærm, indstillinger (lyd, musik, vibration), app-ikon og gemt fremskridt.

## Filer

| Fil | Indhold |
|---|---|
| `Board.swift` | Spillets regler (ren logik) |
| `LevelGenerator.swift` | Baner og sværhedskurve |
| `GameSession.swift` | Liv, stjerner, mønter, hint, continue og oplåsning |
| `GameScene.swift` | SpriteKit: brættet, tryk, animationer og tutorial |
| `CatArt.swift` / `CatBreed.swift` | Kattetegningen og de 12 racer |
| `PlayerProgress.swift` | Gemt fremskridt, indstillinger og daglig gave |
| `SoundManager.swift` / `Haptics.swift` | Lyd og vibration |
| `Store.swift` | Køb i appen (StoreKit 2) |
| `Services.swift` | Pladser til reklamer og analytics, samt app-info |
| `HomeView.swift`, `GameView.swift`, `MenuSheets.swift`, `Components.swift` | Skærmene |
| `Sounds/` | Lydeffekter og musik (lavet med kode, så der er ingen rettigheder at betale for) |
| `../AppStore/` | Udkast til App Store-tekster, nøgleord og privatlivspolitik |

## Det du selv skal gøre før udgivelse

1. **Apple Developer-konto** (99 USD om året) og en app oprettet i App Store Connect.
2. **Køb i appen** skal oprettes i App Store Connect med de samme produkt-id'er.
3. **Privatlivspolitik:** udfyld `AppStore/privacy-policy.md`, læg den online, og ret `AppInfo.privacyPolicyURL`.
4. **Reklamer:** opret en AppLovin MAX- eller AdMob-konto, tilføj SDK'et via Swift Package Manager
   og udfyld `Ads`. Husk App Tracking Transparency-dialogen og `SKAdNetworkItems` i Info.plist.
5. **Analytics:** tilføj Firebase eller GameAnalytics i `Analytics.log`.
6. **Screenshots og video** (se `AppStore/metadata.md`).
7. **TestFlight:** lad 10–20 personer spille og se, hvor de stopper.
8. **Soft launch** i et par mindre lande, mål retention og pris pr. installation, og skalér derefter.
