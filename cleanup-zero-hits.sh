today="$(date +%Y-%m-%d)"
from="$(date --date="6 months ago" +%Y-%m-%d)"
timestamp="$(date +%Y-%m-%d-%H-%M-%S)"

printf  "This script will search a specific policy package for rules with a ZERO hit count.\nUse with caution for deleting rules..\nIf for any reason you make a typo and need to exit use CTRL+C.\nPress ENTER  to continue"
read ANYKEY

printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nListing Access Policy Package Names\n"
mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)'

printf "\nWhat is the Policy Package Name?\n"
read POL_NAME
POL2=$(echo $POL_NAME | tr -d ' ')

printf "\nDetermining Rulesbase Size\n"
total=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" --format json |jq '.total')
printf "There are $total rules in $POL_NAME\n"

printf "\nDo you want to output disable commands or delete commands?[disable/delete]\n"
read DISDEL

  if [ "$DISDEL" = "disable" ]; then
  printf "\nDo you want to export using Rule Number or UID?\nRule Number will allow for more manual checking but UID\nis more accurate if another admin could potentially be editing a policy\nPlease enter uid or name. [uid/name]\n"
  read EXPORT_TYPE1

    if [ "$EXPORT_TYPE1" = "name" ]; then
    printf "\nDoes Your Policy Contain Section Title Headers?[y/n]\n"
    read SECHEAD

      if [ "$SECHEAD" = "y" ]; then
      printf "\nCreating Disable Scripts. This may take a minute depending on Rulebase size.\n"
      for I in $(seq 0 500 $total)
      do
        mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | .rulebase[] | select(.hits.value == 0) | (" set access-rule rule-number  " + (."rule-number"|tostring) + " enabled false layer")' >> $POL2-tmp.txt
      done
      sed "s,$, '$POL_NAME' comments 'disabled by API Zero Hit'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-disable-unused.txt; rm *tmp.txt
      printf "\nDisable commands for zero hit count rules are now located in $POL2-disable-unused.txt\n"

      elif [ "$SECHEAD" = "n" ]; then
      printf "\nCreating Disable Scripts. This may take a minute depending on Rulebase size.\n"
      for I in $(seq 0 500 $total)
      do
        mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | select(.hits.value == 0) | (" set access-rule rule-number " + (."rule-number"|tostring) + " enabled false layer")' >> $POL2-tmp.txt
      done
      sed "s,$, '$POL_NAME' comments 'disabled by API Zero Hit'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-disable-unused.txt; rm *tmp.txt
      printf "\nDisable commands for zero hit count rules are now located in $POL2-disable-unused.txt\n"
      fi
    elif [ "$EXPORT_TYPE1" = "uid" ]; then
    printf "\nDoes Your Policy Contain Section Title Headers?[y/n]\n"
    read SECHEAD

      if [ "$SECHEAD" = "y" ]; then
      printf "\nCreating Disable Scripts. This may take a minute depending on Rulebase size.\n"
      for I in $(seq 0 500 $total)
      do
        mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | .rulebase[] | select(.hits.value == 0) | (" set access-rule uid  " + (.uid|tostring) + " enabled false layer")' >> $POL2-tmp.txt
      done
      sed "s,$, '$POL_NAME' comments 'disabled by API Zero Hit'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-disable-unused.txt; rm *tmp.txt
      printf "\nDisable commands for zero hit count rules are now located in $POL2-disable-unused.txt\n"

      elif [ "$SECHEAD" = "n" ]; then
      printf "\nCreating Disable Scripts. This may take a minute depending on Rulebase size.\n"
      for I in $(seq 0 500 $total)
      do
        mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | select(.hits.value == 0) | (" set access-rule uid " + (.uid|tostring) + " enabled false layer")' >> $POL2-tmp.txt
      done
      sed "s,$, '$POL_NAME' comments 'disabled by API Zero Hit'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-disable-unused.txt; rm *tmp.txt
      printf "\nDisable commands for zero hit count rules are now located in $POL2-disable-unused.txt\n"
      fi
    fi
  elif [ "$DISDEL" = "delete" ]; then
    printf "\nDo you want to export using Rule Number or UID?\nRule Number will allow for more manual checking but UID\nis more accurate if another admin could potentially be editing a policy\nPlease enter uid or name. [uid/name]\n"
    read EXPORT_TYPE2

    if [ "$EXPORT_TYPE2" = "name" ]; then
      printf "\nDoes Your Policy Contain Section Title Headers?[y/n]\n"
      read SECHEAD2

      if [ "$SECHEAD2" = "y" ]; then
        printf "\nCreating Deletion Scripts. This may take a minute depending on Rulebase size.\n"
        for I in $(seq 0 500 $total)
        do
          mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | .rulebase[] | select(.hits.value == 0) | (" delete access-rule rule-number " + (."rule-number"|tostring) + " layer")' >> $POL2-tmp.txt
        done
        sed "s,$, '$POL_NAME'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-delete-unused.txt; rm *tmp.txt
        printf "\nDelete commands for zero hit count rules are now located in $POL2-delete-unused.txt\n"

      elif [ "$SECHEAD2" = "n" ]; then
        printf "\nCreating Deletion Scripts. This may take a minute depending on Rulebase size.\n"
        for I in $(seq 0 500 $total)
        do
          mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | select(.hits.value == 0) | (" delete access-rule rule-number " + (."rule-number"|tostring) + " layer")' >> $POL2-tmp.txt
        done
        sed "s,$, '$POL_NAME'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-delete-unused.txt; rm *tmp.txt
        printf "\nDelete commands for zero hit count rules are now located in $POL2-delete-unused.txt\n"
        fi
    elif [ "$EXPORT_TYPE2" = "uid" ]; then
      printf "\nDoes Your Policy Contain Section Title Headers?[y/n]\n"
      read SECHEAD2

      if [ "$SECHEAD2" = "y" ]; then
        printf "\nCreating Deletion Scripts. This may take a minute depending on Rulebase size.\n"
        for I in $(seq 0 500 $total)
        do
          mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | .rulebase[] | select(.hits.value == 0) | (" delete access-rule uid " + (.uid|tostring) + " layer")' >> $POL2-tmp.txt
        done
        sed "s,$, '$POL_NAME'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-delete-unused.txt; rm *tmp.txt
        printf "\nDelete commands for zero hit count rules are now located in $POL2-delete-unused.txt\n"

      elif [ "$SECHEAD2" = "n" ]; then
        printf "\nCreating Deletion Scripts. This may take a minute depending on Rulebase size.\n"
        for I in $(seq 0 500 $total)
        do
          mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" offset $I limit 500 use-object-dictionary true show-hits true hits-settings.from-date $from hits-settings.to-date $today --format json | jq --raw-output --arg RBN "$POL_NAME" '.rulebase[] | select(.hits.value == 0) | (" delete access-rule uid " + (.uid|tostring) + " layer")' >> $POL2-tmp.txt
        done
        sed "s,$, '$POL_NAME'," $POL2-tmp.txt > $POL2-2tmp.txt; sed "s/^/mgmt_cli -r true -d $DOMAIN/" $POL2-2tmp.txt >$POL2-delete-unused.txt; rm *tmp.txt
        printf "\nDelete commands for zero hit count rules are now located in $POL2-delete-unused.txt\n"
    fi
  fi
fi
