#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~ \n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  if [[ -z $SERVICES ]]
    then
      echo "I could not find that service. What would you like today?"
    else
      echo "$SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done

      read SERVICE_ID_SELECTED
      if [[ !$SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
        then
          MAIN_MENU "I could not find that service. What would you like today?"
        else
          AVAILABLE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          if [[ -z $AVAILABLE_SERVICE ]]
            then
              MAIN_MENU "I could not find that service. What would you like today?"
            else
              echo -e "\nWhat's your phone number?"
              read CUSTOMER_PHONE
              CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
              
              if [[ -z $CUSTOMER_NAME ]]
                then
                  echo -e "\nWhat is your name?"
                  read CUSTOMER_NAME
                  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
              fi
            
            echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
            read SERVICE_TIME
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            
            if [[ $SERVICE_TIME ]]
              then
                INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
                if [[ $INSERT_SERV_RESULT ]]
                  then
                    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
                fi    
            fi   
          fi
      fi
  fi  
}

MAIN_MENU
