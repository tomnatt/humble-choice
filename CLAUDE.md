# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project does

A Ruby tool that pulls Humble Choice/Monthly game data from a Google Sheets spreadsheet, enriches it with Steam App IDs and SteamSpy genre tags, then outputs the results as YAML and JSON files in `output/`.

## Environment setup

Two environment variables are required:
- `HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY` — path to a Google Cloud service account key JSON file (the actual key is at `keys/humble-choice-bdafc2a7f786.json`)
- `STEAM_API_KEY` — Steam Web API key

## Common commands

```bash
bundle exec rake                        # Default: monthly task (generate + Steam IDs + tags)
bundle exec rake monthly                # Same as default — run this when adding new games
bundle exec rake regenerate             # Full rebuild: refresh Steam store + regenerate all output
bundle exec rake get_steam              # Refresh local Steam datastore (steam/steam-store.yml)
bundle exec rake generate_games         # Regenerate output without touching Steam IDs or tags
bundle exec rake missing_steam_ids      # List games without Steam IDs
bundle exec rake missing_tags           # List games without SteamSpy tags
bundle exec rake add_missing_tags       # Fetch tags for games that have a Steam ID but no tags
bundle exec rake add_tags[2,2024]       # Add tags for Feb 2024 (month,year — either can be blank)
bundle exec rake generate_with_steam_ids[,2024]  # Update Steam IDs for 2024 games only
```

Linting:
```bash
bundle exec rubocop
```

There is no test suite.

## Architecture

### Data flow

1. `GoogleData` authenticates with the Google Sheets API and reads two worksheets from [the source spreadsheet](https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk): the first sheet (Humble Monthly era) and the last sheet (Humble Choice era). Both are merged into a sorted list of `Game` objects tagged with `humble_scheme: "monthly"` or `"choice"`.

2. `HumbleChoiceGenerator` orchestrates generation. Its `generate_list` method merges freshly fetched Google data with the existing on-disk data (reading from `output/yaml/humble-choice-all.yml`) so that Steam IDs and tags accumulated over time are preserved. New games get `Game` objects with nil Steam IDs.

3. `SteamStore` maintains a local YAML cache at `steam/steam-store.yml` of every app on Steam (name → appid). The cache is built by paginating through the Steam `IStoreService/GetAppList` API. Name matching normalises emoji variation selectors before comparing.

4. `SteamSpy` fetches genre tags from the SteamSpy API (1 req/sec rate limit enforced with `sleep 1`). Running `add_tags` without parameters takes ~18 minutes for the full dataset; prefer `add_missing_tags`.

5. `GamesListFiles` writes output: per-year files (`output/yaml/humble-choice-YYYY.yml`, `output/json/humble-choice-YYYY.json`) plus combined all-years files.

### Key files

| File | Role |
|------|------|
| `lib/config.rb` | Centralises output paths and the `years` range — **update `years` each January** |
| `lib/game.rb` | Data model: `name`, `month`, `year`, `humble_scheme`, `steam_id`, `tags` |
| `lib/google_data.rb` | Reads source spreadsheet, parses game names (handles ` + ` bundles and `OR` variants) |
| `lib/humble_choice_generator.rb` | Orchestrates generation and ID enrichment |
| `lib/games_list_files.rb` | Reads/writes YAML and JSON output; handles ignore list |
| `lib/steam_store.rb` | Local Steam app cache |
| `lib/steam_spy.rb` | SteamSpy tag fetching |
| `ignore-list.txt` | Games deliberately excluded from missing-ID/tag reports; lines starting with `#` are comments |
