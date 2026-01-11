#!/bin/bash

## Grab Authorization token
TOKEN=$(curl -u wazuh-wui:Reproduction38Assignment\? -k -X POST "https://wazuh:55000/security/user/authenticate?raw=true")

## Delete disconnected agents older than 15 days
curl -k -X DELETE "https://wazuh:55000/agents?older_than=15d&agents_list=all&status=disconnected&pretty=true" -H "Authorization: Bearer ${TOKEN}"
