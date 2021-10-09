# Humble Choice markup

Humble Choice options marked up as YAML, enriched with Steam IDs.

Output YAML can be seen in `output/` - [here](https://github.com/tomnatt/humble-choice/tree/main/output). Steam IDs included where possible, but not that some games are from Battle.net, so there are some empty `steam_id` fields.

Data is drawn from [this public spreadsheet of Humble Monthly / Choice games](https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit?usp=sharing) with credit to the owner of [this public spreadsheet](https://docs.google.com/spreadsheets/d/1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY/edit#gid=0) which has been copied, reformatted a bit and updated since the original was abandoned.

Steam ids are pulled from [this list](https://api.steampowered.com/ISteamApps/GetAppList/v0002/) or [this list](http://api.steampowered.com/ISteamApps/GetAppList/v0002/?key=STEAMKEY&format=json) which for some reason give different data. Source is set in `lib/steam_ids.rb`

Note that the source data has been updated for best-guess matches against the Steam ID list. There is no guarantee of 100% accuracy. This data is maintained independently of Humble.

## Running the code

You requires a Google Cloud Service Account. See [this guide](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#service-account) to create one. Download the key in JSON format and point to it using the `HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY` environment variable.

To run:

* `bundle exec rake` to generate output files silently
* `bundle exec rake generate` to generate output files with match data
* `bundle exec rake generate_games` to generate output files without Steam Ids
