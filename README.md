This script is designed to search a specified 'Access Policy' for rules with ZERO HITS. This supports both MDS and SMS environments. This script is made to run directly on the managment station.

You have the option to export the commands to 'DISABLE' or 'DELETE' the rules with Zero Hits.

## How to Use ##
 - Move script to managment station
 - ./cleanup-zero-hits.sh
  - Enter IP address of SMS or CMA you wish check
  - Follow remaining prompts for options

You can take the delete/disable command file and run it.
  - chmod 755 Output-Filename.txt
  - ./Output-Filename.txt
