#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~ Number Guessing Game~~~~\n"

echo "Enter your username:"
read USERNAME

# found username
USERNAME_SELECTED=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# games played
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
# best game
BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")

# if username not found
if [[ -z $USERNAME_SELECTED ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
else
  echo -e "\nWelcome back, $USERNAME_SELECTED! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

SECRET_NUMBER=$(( 1 + $RANDOM % 1000 ))
NUMBER_OF_GUESSES=1
echo "Guess the secret number between 1 and 1000:"

while read INPUT_NUMBER
do
  if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $INPUT_NUMBER -eq $SECRET_NUMBER ]]
    then
      echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break;
    else
      if [[ $INPUT_NUMBER -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $INPUT_NUMBER -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
done

# insert info game
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses,user_id) VALUES($NUMBER_OF_GUESSES,$USER_ID)")