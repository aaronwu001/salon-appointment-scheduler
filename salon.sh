#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services")


MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo -e "\nHow may I help you today?\n"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "Service selected invalid."
  else
    # get customer info
    echo -e "\n What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer name not found
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get customer name
      echo -e "What's your name?"
      read CUSTOMER_NAME
      # insert new customer
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # get service time
    echo -e "\n When do you want the service?"
    read SERVICE_TIME
    # insert appointment
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
    then
      echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      MAIN_MENU "error setting appointment"
    fi
  fi
}

MAIN_MENU


