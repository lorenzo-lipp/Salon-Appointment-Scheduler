#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Hair Salon ~~~~~\n"

echo -e "Welcome to the salon, how can I help you?\n"

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]$ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done

  SELECT_SERVICE
}

SELECT_SERVICE() {
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE ]]
  then
    MENU "I could not find this service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      SAVE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    echo -e "\nWhat time would you like your $(echo "$SERVICE" | sed -E 's/ *//g'), $(echo "$CUSTOMER_NAME" | sed -E 's/ *//g')?"
    read SERVICE_TIME
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SAVE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo "$SERVICE" | sed -E 's/ *//g') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed -E 's/ *//g')."
  fi
}

MENU