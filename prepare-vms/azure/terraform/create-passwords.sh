#!/bin/sh
set -e

password_length=12
number_of_machines=60
username=training

echo "Creating passwords.tf with $number_of_machines passwords"
i=0
echo 'variable "admin_password" {
  default = [' > passwords.tf

rm -f machines.md
for password in $(pwgen $password_length $number_of_machines); do
  echo "    \"$password\"," >> passwords.tf
  if [ $(($i%6)) -eq 0 ]; then
    echo "# Accounts $((i+1)) - $((i+6))" >> machines.md
    echo "" >> machines.md
  fi
  echo "| FQDN     | ba-$(printf "%02d" $((i+1))).westeurope.cloudapp.azure.com |" >> machines.md
  echo "|----------|-------------------------------------|" >> machines.md
  echo "| Username | \`$username\` |" >> machines.md
  echo "| Password | \`$password\` |" >> machines.md
  echo "" >> machines.md

  i=$((i+1))
done

echo '    "dummy"
  ]
}' >> passwords.tf

exists()
{
  command -v "$1" >/dev/null 2>&1
}

if exists mdpdf; then
  mdpdf machines.md
fi
