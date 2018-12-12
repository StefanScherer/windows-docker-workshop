#!/bin/sh
set -e

password_length=12
number_of_machines=${1:-60}
username=training
dns_prefix=wdw

if [ ! -z "${CIRCLE_TAG}" ]; then
  dns_prefix=${CIRCLE_TAG%%-*}
  number_of_machines=${CIRCLE_TAG#*-}
fi

if [ ! -z "${PASSWORDS_TF_URL}" ]; then
  echo "Downloading passwords.tf"
  curl --fail -L -o passwords.tf "${PASSWORDS_TF_URL}"
else
  echo "Creating passwords.tf with $number_of_machines passwords"
  i=0
  echo 'variable "admin_password" {
    default = [' > passwords.tf

  rm -f machines.md
  for password in $(pwgen $password_length "$number_of_machines"); do
    echo "    \"$password\"," >> passwords.tf
    if [ $((i%6)) -eq 0 ]; then
      echo "# Accounts $((i+1)) - $((i+6))" >> machines.md
      echo "" >> machines.md
    fi
    # shellcheck disable=SC2129
    echo "| FQDN     | $dns_prefix-$(printf "%02d" $((i+1))).westeurope.cloudapp.azure.com |" >> machines.md
    echo "|----------|-------------------------------------|" >> machines.md
    echo "| Username | \`$username\` |" >> machines.md
    echo "| Password | \`$password\` |" >> machines.md
    echo "" >> machines.md

    i=$((i+1))
  done

  echo '    "dummy"
    ]
  }' >> passwords.tf
fi

exists()
{
  command -v "$1" >/dev/null 2>&1
}

if [ -f machines.md ]; then
  if exists mdpdf; then
    mdpdf machines.md
  fi
fi
