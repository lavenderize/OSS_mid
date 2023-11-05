#!/bin/bash

user_name="kimseeun"
student_number="12213543"

while true; do
    clear
    echo "--------------------------"
    echo "User Name: $user_name"
    echo "Student Number: $student_number"
    echo "[ MENU ]"
    echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
    echo "2. Get the data of 'action' genre movies from 'u.item'"
    echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
    echo "4. Delete the 'IMDb URL' from 'u.item'"
    echo "5. Get the data about users from 'u.user'"
    echo "6. Modify the format of 'release date' in 'u.item'"
    echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
    echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
    echo "9. Exit"
    echo "--------------------------"
    echo "Enter your choice [1-9]"

    read option

    case $option in
        1)
            echo "Please enter the 'movie id’ (1~1682):"
            read movie_id
            if [[ $movie_id =~ ^[0-9]+$ && $movie_id -ge 1 && $movie_id -le 1682 ]]; then
                grep "^$movie_id|" u.item
            else
                echo "Invalid input. Please enter a valid 'movie id’ within the range of 1 to 1682."
            fi
            ;;
        2)
            	echo "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n)"
		read choice
		if [ "$choice" == "y" ]; then
   			 awk -F "|" '$7 == 1 {print $1, $2}' u.item | head -n 10
		else
   			 echo "Action genre movies not selected."
		fi
		;;

        3)
            echo "Please enter the 'movie id’ (1~1682):"
            read movie_id
            if [[ $movie_id =~ ^[0-9]+$ && $movie_id -ge 1 && $movie_id -le 1682 ]]; then
                grep -w "$movie_id" u.data | awk '{sum += $3; count++} END {if (count > 0) printf "%.5f\n", sum / count; else print "N/A"}'
            else
                echo "Invalid input. Please enter a valid 'movie id’ within the range of 1 to 1682."
            fi
            ;;
        4)
            echo "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n)"
            read choice
            if [ "$choice" == "y" ]; then
                sed 's/|//5' u.item | head -n 10
                echo "IMDb URLs deleted from 'u.item'."
            else
                echo "IMDb URL not deleted from 'u.item'."
            fi
            ;;
        5)
		echo "Do you want to get the data about users from 'u.user'? (y/n)"
		read choice
	if [ "$choice" == "y" ]; then
    		head -n 10 u.user | awk -F '|' '{print "user", $1, "is", $2, "years old", $3, $4}'
	else
   		 echo "User data not selected."
	fi
        ;;
        6)
		echo "Do you want to modify the format of 'video release date' in 'u.item' to YYYYMMDD format? (y/n)"
		read choice
		
		if [ "$choice" == "y" ]; then
		    awk -F "|" '{
        		if ($4 != "") {
            			split($4, date, "-");
            			months = ("JanFebMarAprMayJunJulAugSepOctNovDec");
			        new_date = sprintf("%s%02d%02d", date[3], (index(months, date[2]) + 1) / 3, date[1]);
           			$4 = new_date;
       			 }
        		 print;
			}' u.item > u.item.tmp

			 mv u.item.tmp u.item

			 echo "Format of 'video release date' modified in 'u.item'."
		else
   			 echo "Format of 'video release date' not modified in 'u.item'."
		fi
		;;

        7)
            echo "Please enter the 'user id’ (1~943):"
            read user_id
            
            if [[ $user_id =~ ^[0-9]+$ && $user_id -ge 1 && $user_id -le 943 ]]; then
    		rated_movie_ids=$(awk -F "|" -v user_id="$user_id" '$1 == user_id {print $2}' u.data | sort -n)

    		echo "$rated_movie_ids" | tr '\n' '|' | sed 's/|$//'
   		echo

		head -n 10 u.item | awk -F "|" -v rated_movie_ids="$rated_movie_ids" '$1 in rated_movie_ids {print $1"|"$2}'
	   else
   		echo "Invalid input. Please enter a valid 'user id' within the range of 1 to 943."
	   fi
	   ;;

        8)
            echo "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n)"
            read choice

	    if [ "$choice" == "y" ]; then
    		user_ids=$(awk -F "|" '$3 >= 20 && $3 <= 29 && $4 == "programmer" {print $1}' u.user)

		    if [ -z "$user_ids" ]; then
        	        echo "No ratings found for programmers in their 20s."

	    	else
			ratings=$(awk -F "	" -v users="$user_ids" 'BEGIN {split(users, user_array, " ");} $1 in user_array {print $3}' u.data)
			total = 0
			count = 0
			for rating in $ratings; do
				total=$(bc <<< "$total + $rating")
				((count++))
			done

			if [ $count -eq 0 ]; then
				echo "No ratings found for programmers in their 20s."
			else
				average=$(bc -l <<< "scale=6; $total / $count")
				echo "Average rating of movies rated by programmers in their 20s: $average"
			fi
		fi
	else
		echo "No ratings found."
	fi
	;;


        9)
            echo "Bye"
            exit 0
            ;;
        *)
            echo "Invalid option. Please enter a number between 1 and 9."
            ;;
    esac

    echo "--------------------------"
    echo "Press Enter to continue..."
    read
done

