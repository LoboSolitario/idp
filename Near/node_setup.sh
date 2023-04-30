#!/bin/bash

# !!!!!!!!!!!!!
#   PLEASE ENSURE YOU HAVE BOOKED A SLOT ON CALENDAR FOR THE NODES IN THE PARAMTERS BEFORE EXECUTING THIS SCRIPT.
#   YOU CAN VERIFY THIS USING COMMAND - `pos calendar list` and check if there is entry for the nodes against your username.
#
#   Script Usage : ./nodes_setup "node1" "node2" ...
# !!!!!!!!!!!!!

# check if at least one parameter was provided
if [ $# -eq 0 ]; then
    echo "Error: no parameters provided. Please provide at least one parameter to run the script on."
    exit 1
fi

# loop through all provided parameters
for param in $@; do
    # Free the nodes if it is allocated to some other user.
    # Nodes need to be manually freed after the slot expiration
    echo "Freeing up node $param."
    pos allocations free $param

    # check if the first command ran successfully
    if [ $? -eq 0 ]; then
        # Allocate the nodes mentionedin the paramters
        echo "Allocating node $param."
        pos allocations allocate $param

        # check if the second command ran successfully
        if [ $? -eq 0 ]; then
            # Assign the image to the node
            echo "Setting image for node $param."
            pos nodes image $param debian-bullseye

            # check if the third command ran successfully
            if [ $? -eq 0 ]; then
                # Reset the node
                pos nodes reset $param &
                echo "Reset command for $param running in background with pid $! ."
            else
                # the third command failed
                echo "Error: setting image for $param failed. Exiting script."
                pos nodes image $param debian-bullseye 2>&1
                exit 1
            fi
        else
            # the second command failed
            echo "Error: allocating node $param failed. Exiting script."
            pos allocations allocate $param 2>&1
            exit 1
        fi
    else
        # the first command failed
        echo "Error: freeing up node for $param failed. Exiting script."
        pos allocations free $param 2>&1
        exit 1
    fi
done

wait

if [ $? -eq 0 ]; then
  echo "Reset of all nodes completed successfully"
else
  echo "Reset of one or more nodes failed"
  exit 1
fi

# loop through all provided parameters
for param in $@; do
    echo "Installing sudo to node $param."
    pos commands launch $param -- apt install -y sudo

    # check if the  sudo install command ran successfully
    if [ $? -ne 0 ]; then
        echo "Error: installing sudo for $param failed. Exiting script."
        pos commands launch $param -- apt install -y sudo 2>&1
        exit 1
    else
        # update packages.
        echo "Updating packages for node $param."
        pos commands launch $param -- sudo apt-get update --fix-missing &
    fi
done

wait

if [ $? -eq 0 ]; then
  echo "Setup for all nodes is completed successfully. Ready to start the experiment."
else
  echo "One or more commands failed to install updates on the nodes."
  exit 1
fi
