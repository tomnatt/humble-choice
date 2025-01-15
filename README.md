# Humble Choice markup

Humble Choice (formerly Humble Monthly) game selections marked up as YAML and JSON, enriched with Steam IDs.

Output in `output/` - [here](https://github.com/tomnatt/humble-choice/tree/main/output). Output in both JSON and YAML formats. Steam IDs included where possible, but note that some games have been withdrawn from the platform, and others are from other platforms (eg Battle.net), so there are some empty `steam_id` fields. Games with omitted IDs are listed in `ignore-list.txt` along with the reason.

Both formats have file output by year and a combined file.

Humble Choice data is drawn from [this public spreadsheet of Humble Monthly / Choice games](https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit?usp=sharing) with credit to the owner of [this public spreadsheet](https://docs.google.com/spreadsheets/d/1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY/edit#gid=0) which has been copied, reformatted a bit and updated since the original was abandoned.

Steam IDs are pulled from the [Steam API](https://steamapi.xpaw.me/#IStoreService) (link to unofficial docs).

Tags are courtesy of the [SteamSpy API](https://steamspy.com/). Full regeneration of Tags will be VERY slow - we hit the SteamSpy API once per second at full throttle, [as per their API instructions](https://steamspy.com/api.php) and it may not complete. Methods are in place for partial update so generate Tags data in chunks rather than attempting everything at once. Running everything at once will take approx 18 mins at last update. Note that `add_tags` without params (see below) will fully regenerate - if you want to add the missing tags use `add_missing_tags`.

Note that the source data has been updated for best-guess matches against the Steam ID list. There is no guarantee of 100% accuracy. This data is maintained independently of Humble.

## Running the code

Config (such as file output paths) has been refactored into `lib/config.rb`. This also includes the years considered - needs updating each year.

You require a Google Cloud Service Account. See [this guide](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#service-account) to create one. Download the key in JSON format and point to it using the `HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY` environment variable.

You also require a [Steam API key](https://steamcommunity.com/dev) stored in an environment variable `STEAM_API_KEY`.

Code is written in Ruby and requires `bundler`.

To run:

* `bundle exec rake get_steam` to generate steam database - needed first time, then occasionally update
* `bundle exec rake` to generate all Humble output files

Or `bundle exec rake regenerate` will do it all in a single step.

Incremental update of Steam Ids can be done thus (same command format with Tags):

```
bundle exec rake generate_with_steam_ids[,2016]   # Update all Steam Ids for 2016 games
bundle exec rake generate_with_steam_ids[2,]      # Update all Steam Ids for February games
bundle exec rake generate_with_steam_ids[2,2016]  # Update all Steam Ids for February 2016 games
bundle exec rake generate_with_steam_ids          # Omit params - update all Steam Ids for all games
```

All rake tasks (run through bundle, obv):

```
rake add_missing_tags                     # Add missing tags
rake add_tags[month,year]                 # Add tags - very slow with no params
rake delete_steam                         # Delete local Steam datastore
rake generate_games                       # Generate Game objects with no change to Steam Ids
rake generate_games_list                  # Generate Game objects with no Steam Ids
rake generate_with_steam_ids[month,year]  # Generate Game objects with Steam Ids
rake get_steam                            # Create local Steam datastore
rake missing_steam_ids                    # Show missing Steam Ids
rake missing_tags                         # Show missing Tags
rake monthly                              # Monthly task - run when adding new games (default)
rake regenerate                           # Regenerate all listings and Steam datastore with missing game output - retains Tags unchanged
```
