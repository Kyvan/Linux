#!/bin/bash

# Making Maze for Assignment03 - 16S
# May 26th, 2016

# Might be used in the future
# shuf4="$(shuf -i 1-4 -n 1)"

# Making some variables
shuf="$(shuf -i 0-9 -n 1)"
rand=$(rand -N "$(shuf -i 0-5 -n 1)") 
ranDot=$(rand -d . -N "$(shuf -i 0-5 -n 1)")

# Making an array to make 10 Directories
dir='{0,1,2,3,4,5,6,7,8,9}'

# Making the Directory structure
eval mkdir -p "${HOME}/mazetest/Maze/.$dir/.$dir/.$dir/.$dir"

# A while loop to create folders/files for each user
while read -r line ; do
	echo "$line" > Maze/."$shuf"/."$shuf"/."$shuf"/."$line".unk
	echo "This is not the file, pay closer attention to the INSTRUCTIONS." > Maze/."$shuf"/."$shuf"/.."$line".unk
	echo -e "Congrats on finding the correct file.\nWrite a command to find all the files that contain your username."
	echo -e "Write a Command that finds only files with your username in them where the name begins with a space.\nWrite a Command that finds only hidden files with your username in them.\nWrite a Command that finds only your username in a hidden file that ends with and unknown three character file extension.\nWrite the commands you used to find the files above in a file named A4-7.txt" > "Maze/.$shuf/.$shuf/.$shuf/.$shuf/$line*txt"

	# A for loop to make the maze
	for (( counter = 1 ; counter <= 200 ; counter++ )) ; do
		if (( "$counter" % 5 == 0 )) ; then
			touch Maze/."$shuf/.$shuf/.$shuf/.$shuf/$rand $line $rand"
		elif (( "$counter" % 3 == 0 )) ; then
			touch Maze/."$shuf/.$shuf/.$shuf/ $rand $line $rand"
		elif (( "$counter" % 2 == 0 )) ; then
			touch Maze/."$shuf/.$shuf/.$ranDot.$line.$ranDot.NO"
			touch Maze/."$shuf/.$shuf/.$ranDot.$line.$ranDot.RTFM"
		else
			touch Maze/"$rand $rand"
			touch Maze/."$shuf/$rand $rand"
		fi
	done
done < userList.txt
