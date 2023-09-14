# Referenční cvičení pro test znalostí a rozvoj kandidáta
Cílem je implementovat jednoduchou aplikaci na vyhledávání entit - soutěže, týmy, hráči, pomocí Livesport Search Service API

## Funkční požadavky
- Aplikace bude mít 2 obrazovky - výpis výsledků a detail.
- Výpis bude obsahovat titulek (např. Výsledky), vyhledávací pole, tlačítko pro
vyhledání a list výsledků.
- Vyhledávání musí mít možnost filtrace dle typu entity (viz parametry API):
    - všechny typy - id 1,2,3,4
    - pouze soutěže - id 1
    - pouze participanti - id 2,3,4
- Aplikace bude vhodně zobrazovat stav stahování dat - loading.
- V případě jakékoliv chyby - nedostupný internet, serverová chyba (viz. API níže), ... se
zobrazí alert s příslušnou zprávou a “retry” tlačítkem.
- Každý řádek musí zobrazovat minimálně:
    - název entity - např. Arsenal FC, Roger Federer, apod.
    - logo/fotku, případně placeholder jestli chybí
- Seznam výsledků bude seskupen dle sportu do sekcí, každá sekce bude mít hlavičku
s názvem sportu.
- Každý řádek bude navigovat na detail.
- Detail bude obsahovat titulek s názvem entity, větší fotku/logo/placeholder, zemi
soutěže/týmu/hráče, dle uvážení další dostupné informace.

## Technické požadavky
- SwiftUI pro uživatelské rozhraní - barevnost a styl dle libosti.
- Architektura The Composable Architecture: https://github.com/pointfreeco/swift-composable-architecture.
- Pro práci s daty využít Combine popřípadě async/await.
- Podpora iOS 15+.
- Vyvíjeno v posledním stable Xcode.
- Minimální pokrytí testy (unit):
    - networking 
    - TCA
    - services
- Využít git a práci průběžně a logicky commitovat.
- Git repo prosím NESDÍLET veřejně!
- Po vypracování repo nasdílet na jedno z následujícího:
    - GitLab: jiri.pospisil@livesport.eu, martin.strambach@livesport.eu, michal.klement@livesport.eu, tomas.krasnay@livesport.eu
- Použití knihoven třetích stran možné, ale zvážit nutnost. Použít výhradně SPM

## Livesport Search Service API
### Endpoint
- https://s.livesport.services/api/v2/search
