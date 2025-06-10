#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON APPOINTMENT SCHEDULER ~~~~~\n"

# Function to display services
DISPLAY_SERVICES() {
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
}

# Ask for service
echo "Welcome to My Salon, how can I help you?"
DISPLAY_SERVICES
read SERVICE_ID_SELECTED

# Validate service_id
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
while [[ -z $SERVICE_NAME ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

# Ask for phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # New customer, ask for name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Ask for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmation message
echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
