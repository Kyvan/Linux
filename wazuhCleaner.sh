#!/bin/bash

## Grab Authorization token
TOKEN=$(curl -u wazuh-wui:Reproduction38Assignment\? -k -X POST "https://fedora:55000/security/user/authenticate")

## Delete disconnected agents older than 15 days
curl -k -X DELETE "https://fedora:55000/agents?older_than=1d&agents_list=all&status=disconnected&pretty=true" -H "Authorization: Bearer ${TOKEN}"
curl -u wazuh-wui:Reproduction38Assignment\? -k -X POST "https://fedora:55000/security/user/authenticate"
