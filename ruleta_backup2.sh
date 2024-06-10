#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n${redColour}Saliendo...${endColour}"
  tput cnorm;
  exit 1
}

#Ctrl+c
trap ctrl_c INT

function helpPanel(){
  echo -e "\t-m) Dinero con el que se desea jugar"
  echo -e "\t-t) Tecnica a utilizar (martingala/inverseLabrouchere)\n"
  exit 1
}

function martingala(){
 echo -e "\nDinero actual: \$${money}"
 echo -n "Cuanto dinero tienes pensado apostar? -> " && read initial_bet
 echo -n "A que deseas apostar continuamente (par/impar)? -> " && read par_impar 

 echo -e "\nVamos a jugar con una cantidad inicial de \$${initial_bet} a $par_impar"

 backup_bet=$initial_bet
 play_counter=1
 jugadas_malas=""
 max_money=0




 tput civis
 while true; do 
  
  money=$(($money-$initial_bet))
  current_money=$initial_bet

  #echo -e "\nAcabas de apostar \$${initial_bet} y tienes \$${money}"
  random_number="$(($RANDOM % 37))"
  #echo -e "Ha salido el numero $random_number"
  

  if [ ! "$money" -lt 0 ]; then 
     if [ "$par_impar" == "par" ]; then
          #Toda esta definicion es para cuando apostamos por numeros pares
          if [ "$(($random_number % 2))" -eq 0 ]; then
              if [ "$random_number" -eq 0 ]; then
               # echo -e "${redColour}Ha salido el 0, perdimos :(${endColour}"
                initial_bet=$(($initial_bet*2)) #se duplica la apuesta cuando se pierte
                jugadas_malas+="$random_number "
              else
                #Escenario en donde se gana
                #echo -e "${greenColour}El numero que ha salido es par, ganas! :D${endColour}"
                reward=$(($initial_bet*2))
               # echo -e "Ganas un total de \$${reward}"
                money=$(($money+$reward))
                backup_highscore=$money

                #echo -e "Tienes \$${money}"
                initial_bet=$backup_bet #la apuesta se mantiene igual a la entrada inicial
                jugadas_malas="" 

              fi
            
          else
            #echo -e "${redColour}El numero que ha salido es impar, pierdes! :(${endColour}"
            initial_bet=$(($initial_bet*2)) #se duplica la apuesta cuando se pierde
            jugadas_malas+="$random_number "            #echo -e "Ahora mismo te quedas en \$${money}"
            if [ "$money" -gt "$max_money" ]; then
              max_money=$money
            fi
          fi
     else
       #toda esta definicion para cuando apostamos por numeros impares
       if [ "$(($random_number % 2))" -eq 1 ]; then

              #echo -e "${greenColour}El numero que ha salido es impar, ganas! :D${endColour}"
              reward=$(($initial_bet*2))
              # echo -e "Ganas un total de \$${reward}"
              money=$(($money+$reward))
              backup_highscore=$money

              # echo -e "Tienes \$${money}"
              initial_bet=$backup_bet #la apuesta se mantiene igual a la entrada inicial
              jugadas_malas=""      
       else
              initial_bet=$(($initial_bet*2))
              jugadas_malas+="$random_number "
           
       fi
     fi
  else
    #Nos quedamos sin dinero
    echo -e "${redColour}Te has quedado sin dinero capo :(${endColour}\n"
    echo -e "Han habido un total de $((play_counter-1)) jugadas"

    echo -e "A continuacion se van a presentar las malas jugadas consecutivas que han salido:\n"
    echo -e "[ $jugadas_malas ]"
    echo -e "El valor maximo que obtuviste antes de perder fue de $max_money"
    tput cnorm; exit 0
  fi
  let play_counter+=1
 done

 tput cnorm #Recuperamos el cursor
}

function inverseLabrouchere(){
  echo -e "\nDinero actual: \$${money}"
  echo -n "A que deseas apostar continuamente (par/impar)? -> " && read par_impar
 
  declare -a my_sequence=(1 2 3 4)
  echo -e "\nComenzamos con la secuencia [${my_sequence[@]}]"


  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  
  jugadas_totales=0
  bet_to_renew=$(($money+50)) #dinero el cual una vez alcanzado, hara que renovemos nuestra secuencia a (1 2 3 4)
  
  echo -e "El tope a renovar la secuencia està establecido por encima de \$$bet_to_renew"

  #sleep 8
  tput civis
  while true; do
    let jugadas_totales+=1
    random_number=$(($RANDOM % 37))
    money=$(($money - $bet)) 
    if [ ! "$money" -lt 0 ]; then
      echo -e "Invertimos \$${bet}"
      echo -e "Tenemos \$${money}"
      echo -e "\nHa salido el numero ${random_number}"
      
      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
          echo "El numero es par, ganas!"
          reward=$(($bet*2))
          let money+=$reward

          echo -e "Tienes ahora mismo \$${money}"
          if [ $money -gt $bet_to_renew ]; then
            echo -e "Se ha superado el tope establecido de \$${bet_to_renew} para renovar nuestra secuencia"
            bet_to_renew=$(($bet_to_renew + 50))
            echo -e "El tope se ha establecido en \$${bet_to_renew}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "La secuencia ha sido restablecida a [${my_sequence[@]}] :D "
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})
            echo -e "Nuestra nueva secuencia es (control) [${my_sequence[@]}]"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo "Hemos perdido nuestra secuencia :("
              my_sequence=(1 2 3 4)
              echo -e "Reestablecemos la secuencia a [${my_sequence[@]}]"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        elif [ "$((random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
          if [ "$((random_number % 2))" -eq 1 ]; then
            echo -e "El numero es impar, pierdes :("
          else
            echo -e "\nHa salido el  numero 0, pierdes :("
          fi

          if [ $money -lt $(($bet_to_renew-100)) ]; then
            echo -e "Hemos llegado a un minimo crìtico, se procede a reajustar el tope"
            bet_to_renew=$(($bet_to_renew - 50))
            echo -e "El tope ha sido renovado a: \$${bet_to_renew}" 
         
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            echo -e "Nuestra nueva secuencia es [${my_sequence[@]}]"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo "Hemos perdido nuestra secuencia :("
              my_sequence=(1 2 3 4)
              echo -e "Reestablecemos la secuencia a [${my_sequence[@]}]"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            
            my_sequence=(${my_sequence[@]}) #acà hay que volverlo a declarar ya que si no, entra en conflicto

            echo -e "La secuencia va a quedar de la siguiente forma: [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo "Hemos perdido nuestra secuencia :("
              my_sequence=(1 2 3 4)
              echo -e "Reestablecemos la secuencia a [${my_sequence[@]}]" 
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        fi
      fi
    else
      echo -e "\n${redColour}Te has quedado sin dinero capo :(${endColour}\n"
      echo -e "En total han habido ${jugadas_totales} jugadas totales!\n"
      tput cnorm; exit 1
    fi

    #sleep 1
  done
  tput cnorm

}


while getopts "m:t:h" arg; do
  case $arg in 
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ $money ] && [ $technique ]; then
  
  if [ "$technique" == "martingala" ]; then
    martingala #asi se llaman las funciones sin tener en cuenta el "()"
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere

  else
  
    echo -e "\n La tecnica introducida no existe!"
    helpPanel
  fi
else
  helpPanel
fi



