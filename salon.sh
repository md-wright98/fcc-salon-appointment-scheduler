#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# print introduction
  echo -e "\n~~ Welcome to Elisa's Salon! ~~\n"

SALON () {

  # take message as argument to be printed
  if [[ $1 ]]
    then
      echo -e "\n$1"
    fi

  # retrieve AVAILABLE_SERVICES
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available services
  echo "Here are the services we have available:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # take input: SELECTED_SERVICE_ID
  echo -e "\nWhich service can we book you in for today? Please choose a number from the list."
  read SERVICE_ID_SELECTED
  
  # retrieve SERVICE_ID from services
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  # if SERVICE_ID not in list of services
  if [[ -z $SERVICE_NAME ]]
    then

      # return to list of services
      SALON "Sorry, that is not a valid service number.\n"
  
    # if SERVICE_ID in list
    else
      # take input: CUSTOMER_PHONE
      echo -e "\nPlease enter your phone number."
      read CUSTOMER_PHONE

      # retrieve CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if CUSTOMER_PHONE not in customers table
      if [[ -z $CUSTOMER_NAME ]]

      # take input: CUSTOMER_NAME
      then
        echo -e "\nPlease provide your name."
        read CUSTOMER_NAME  

        # Insert CUSTOMER_PHONE and CUSTOMER_NAME into customers
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

        # Check if added successfully
        if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
        then
          echo -e "\nThank you $CUSTOMER_NAME, we have added you to our customer database!\n"
        fi
      fi
      
      # take input: SERVICE_TIME
      echo -e "\nWhat time would you like to book your appointment for?"
      read SERVICE_TIME

      # retrieve CUSTOMER_ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # insert CUSTOMER_ID, SERVICE_ID, SERVICE_TIME into appointments
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
 
      # print confirmation message
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi

}

SALON