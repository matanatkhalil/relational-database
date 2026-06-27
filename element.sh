#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

INPUT=$1

# If no argument
if [[ -z $INPUT ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Check if input is atomic number
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number=$INPUT"
else
  CONDITION="e.symbol='$INPUT' OR e.name='$INPUT'"
fi

# Query database
RESULT=$($PSQL "
SELECT
  e.atomic_number,
  e.name,
  e.symbol,
  p.atomic_mass,
  p.melting_point_celsius,
  p.boiling_point_celsius,
  t.type
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t USING(type_id)
WHERE $CONDITION
")

# If not found
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit
fi

# Format output
echo "$RESULT" | while IFS="|" read NUM NAME SYMBOL MASS MELT BOIL TYPE
do
  echo "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
done