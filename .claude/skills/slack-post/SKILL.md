---
name: slack-post
description: Wysyła wiadomości na Slack używając predefiniowanych aliasów kanałów. Użyj gdy user chce wysłać coś na Slack bez podawania ID kanału.
---

# Slack Post Skill

Wysyłanie wiadomości na Slack z predefiniowanymi kanałami.

## Trigger Patterns

Aktywuj ten skill gdy użytkownik:
- Mówi "wyślij na slack...", "napisz na slack...", "post na slack..."
- Używa `/slack-post <kanał> <wiadomość>`
- Podaje nazwę kanału i treść wiadomości

## Mapowanie kanałów

| Alias | Channel ID | Opis |
|-------|------------|------|
| better-stack | C0A70D07N4S | Monitoring, BetterStack |
| ai | C04DVJDUSD6 | Sztuczna inteligencja |
| random | C0QAR55PX | Luźne tematy |
| general | C0QAV1FUN | Ogólny |
| devtoys | C1MNNGJ6R | Narzędzia deweloperskie |
| hazard | C2XF7ER4Z | Hazard, zakłady |
| kulinaria | C72DPAX6H | Gotowanie, jedzenie |
| tvseries | C1EGT64PL | Seriale, spoilery |
| profit | C0SRQ2B6V | Finanse, opcje |
| busy | C01H4D4RL0Z | Status, dostępność |

## Instrukcje

1. Znajdź kanał w mapowaniu powyżej
2. Użyj `mcp__slack__slack_post_message` z odpowiednim `channel_id`
3. Jeśli kanał nie istnieje w mapowaniu:
   - Sprawdź `mcp__slack__slack_list_channels`
   - Lub poproś użytkownika o Channel ID
4. Błąd `not_in_channel` = bot nie jest członkiem kanału - poinformuj użytkownika

## Przykłady użycia

### Prosty post
```
User: wyślij na better-stack: Deploy v2.1.0 zakończony!
Claude: [używa channel_id C0A70D07N4S]
```

### Z formatowaniem
```
User: slack-post ai jakąś ciekawostkę o AI
Claude: [komponuje ciekawostkę i wysyła na C04DVJDUSD6]
```

### Wątek
Aby odpowiedzieć w wątku, użyj `mcp__slack__slack_reply_to_thread` z `thread_ts`.

## Dodawanie nowych kanałów

Aby dodać nowy kanał do mapowania:
1. Pobierz Channel ID ze Slacka (View channel details → Channel ID)
2. Dodaj wpis do tabeli mapowania w tym pliku
