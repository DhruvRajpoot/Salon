#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SHOW_SERVICES(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
      echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
  SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g')

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
  
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| $//g')

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME"
    read SERVICE_TIME

    APPOINTMENT_INSERT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SHOW_SERVICES "Welcome to My Salon, how can I help you?"