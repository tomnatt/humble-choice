# Humble Choice markup

Humble Choice (formerly Humble Monthly) game selections marked up as YAML, enriched with Steam IDs.

Output YAML can be seen in `output/` - [here](https://github.com/tomnatt/humble-choice/tree/main/output). Steam IDs included where possible, but note that some games have been withdrawn from the platform, and others are from other platforms (eg Battle.net), so there are some empty `steam_id` fields. Games with omitted IDs are listed in `ignore-list.txt` along with the reason.

Humble Choice data is drawn from [this public spreadsheet of Humble Monthly / Choice games](https://docs.google.com/spreadsheets/d/1VZHuYi0OB6kc9Ma31RG57S7GqX2ND3Gk3FFfgDkToIk/edit?usp=sharing) with credit to the owner of [this public spreadsheet](https://docs.google.com/spreadsheets/d/1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY/edit#gid=0) which has been copied, reformatted a bit and updated since the original was abandoned.

Steam IDs are pulled from the [Steam API](https://steamapi.xpaw.me/#IStoreService) (unofficial docs).

Note that the source data has been updated for best-guess matches against the Steam ID list. There is no guarantee of 100% accuracy. This data is maintained independently of Humble.

## Running the code

You require a Google Cloud Service Account. See [this guide](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#service-account) to create one. Download the key in JSON format and point to it using the `HUMBLE_CHOICE_SERVICE_ACCOUNT_KEY` environment variable.

You also require a [Steam API key](https://steamcommunity.com/dev) stored in an environment variable `STEAM_API_KEY`.

Code is written in Ruby and requires `bundler`.

To run:

* `bundle exec rake get_steam` to generate steam database - needed first time, then occasionally update
* `bundle exec rake` to generate all Humble output files

All rake tasks (run through bundle, obv):

```
rake delete_steam     # Delete Steam datastore
rake generate         # Generate everything with output (default)
rake generate_games   # Generate Game objects and YAML with no Steam Ids
rake generate_silent  # Generate everything silently
rake get_steam        # Create Steam datastore
```
