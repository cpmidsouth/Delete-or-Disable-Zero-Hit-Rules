This script is designed to search a specified 'Access Policy' for rules with ZERO HITS. This supports both MDS and SMS environments. This script is made to run directly on the managment station.

It is highly recommended to run the 'DISABLE' version prior to running a 'DELETE' it will treat it as a staging for full deletion

You have the option to export the commands to 'DISABLE' or 'DELETE' the rules with Zero Hits.

## How to Use ##
 - Move script the management station
 - ./cleanup-zero-hits.sh
  - Enter IP address of SMS or CMA you wish check
  - Follow remaining prompts for options
    - uid or name
      - The script will ask if you want to export with uid or name. UID is more accurate as it does not change with position.   This will prevent a situation where another admin is adding/removing rules from the rulebase before you are able to run the output file.

You can take the delete/disable command file and run it.
  - chmod 755 Output-Filename.txt
  - ./Output-Filename.txt
