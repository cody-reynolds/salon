#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome to the Bash Hair Salon! ~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to the Hair Salon. How can we make you look good today?"
  SERVICES_OFFERED=$($PSQL "SELECT * FROM services")
  echo -e "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  1) SCHEDULING_PROMPT ;;
  2) SCHEDULING_PROMPT ;;
  3) SCHEDULING_PROMPT ;;
  4) SCHEDULING_PROMPT ;;
  5) SCHEDULING_PROMPT ;;
  *) MAIN_MENU "I could not find that service. How can we make you look good today?"
  esac
}

SCHEDULING_PROMPT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //g')
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  # check to see if customer is already listed
  CUSTOMER_CHECK=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_CHECK ]]
    then
    # PROCESS FOR A NEW CUSTOMER
    # ask for a name
    echo -e "\nIt looks like this is your first time with us. What is your name?"
    read CUSTOMER_NAME
    # then create the customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    # ask the customer for a time
    echo -e "\nWhat time would you like your appointment for, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # create the appointment and provide confirmation
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    else
    # PROCESS FOR A RETURNING CUSTOMER
    CUSTOMER_ID=$($PSQL"SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # ask the customer for a time
    echo -e "\nWhat time would you like your $SERVICE_NAME for, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # create the appointment and provide confirmation
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU