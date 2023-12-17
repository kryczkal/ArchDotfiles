# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Set the desired locale
LOCALE="en_US.UTF-8"

# Uncomment the desired locale in /etc/locale.gen
sed -i "/^#.* ${LOCALE} /s/^#//" /etc/locale.gen

# Set the system-wide locale and LC_* variables
{
  echo "LANG=${LOCALE}"
  echo "LC_CTYPE=${LOCALE}"
  echo "LC_NUMERIC=${LOCALE}"
  echo "LC_TIME=${LOCALE}"
  echo "LC_COLLATE=${LOCALE}"
  echo "LC_MONETARY=${LOCALE}"
  echo "LC_MESSAGES=${LOCALE}"
  echo "LC_PAPER=${LOCALE}"
  echo "LC_NAME=${LOCALE}"
  echo "LC_ADDRESS=${LOCALE}"
  echo "LC_TELEPHONE=${LOCALE}"
  echo "LC_MEASUREMENT=${LOCALE}"
  echo "LC_IDENTIFICATION=${LOCALE}"
} > /etc/locale.conf

# Generate the locale
locale-gen

# Confirmation message
echo "Locale settings updated to ${LOCALE} and generated successfully."

