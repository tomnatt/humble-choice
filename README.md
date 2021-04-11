# Humble Choice markup

Humble Choice options marked up as YAML, enriched with Steam IDs.

Output YAML can be seen in `output/` - [here](https://github.com/tomnatt/humble-choice/tree/main/output). Steam IDs included where possible, but not that some games are from Battle.net, so there are some empty `steam_id` fields.

Original data is reformatted from [this public spreadsheet of Humble Monthly / Choice games](https://docs.google.com/spreadsheets/d/1Y5ySEXPLZdmKFNdMOrGlCEVl6nb_G0X3nYCFSWIdktY/edit#gid=0) with updates since this spreadsheet was abandoned.

Note that the source data has been updated for best-guess matches against the Steam ID list. There is no guarantee of 100% accuracy. This data is maintained independently of Humble.

## Running the code

To run, do `bundle exec rake` or to generate and output files containing games without Steam IDs do `bundle exec rake generate`.
