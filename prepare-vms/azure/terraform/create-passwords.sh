#!/bin/bash
set -e

password_length=12
number=100
username=training

i=0
echo 'variable "admin_password" {
  default = [' > passwords.tf

rm -f machines.md
for password in $(pwgen $password_length $number); do
  echo "    \"$password\"," >> passwords.tf
  if [ $(($i%6)) -eq 0 ]; then
    echo "# Accounts $((i+1)) - $((i+6))" >> machines.md
    echo "" >> machines.md
  fi
  echo "| FQDN     | ba-win-$(printf "%02d" $((i+1))).westeurope.cloudapp.azure.com |" >> machines.md
  echo "|----------|-----------------------------------------|" >> machines.md
  echo "| Username | \`$username\` |" >> machines.md
  echo "| Password | \`$password\` |" >> machines.md
  echo "" >> machines.md

  i=$((i+1))
done

echo '    "dummy"
  ]
}' >> passwords.tf

mdpdf machines.md
