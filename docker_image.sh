# What does this script?
# Take input from user about image base, open port, software needed, source and destination for the file; Then save it into variables
# Create Dockerfile
# Build the image
# check if image created


#!/bin/bash

#Base image ( centos , ubuntu, debian, python, alpine )
echo " what base image do you want to use choose one
1-Centos
2-Ubuntu
3-Debian
4-Python
5-Alpine
6-Jenkins
"
read ANSWER

echo "what tag are you using”
read TAG

echo "what port do you want to exposed? List them separate by space"
read PORT
echo "list all softwares that need to be installed separate them with a space"
read SOF
echo "what is your username?"
read NAME
echo "what command should be run in the container"
read COM 
echo "what is the path to the file that needs to be copied in the container?"
read FILE 
echo "what is the path where to copy the file?"
read P 

if [ $ANSWER -eq 1 ]

then 
OS=centos
elif [ $ANSWER -eq 2 ]
then
OS=ubuntu
elif [ $ANSWER -eq 3 ]
then
OS=debian 
elif [ $ANSWER -eq 4 ]
then
OS=python 
elif [ $ANSWER -eq 5 ]
then
OS=jenkins 
else 
echo "please make a choice between 1,2,3,4,5,6"
exit 1
fi 
## Dockerfile creation

>Dockerfile

if [ -z ${TAG} ]
then
echo "FROM ${OS}" >> Dockerfile
else 
echo "FROM ${OS}:${TAG}" >> Dockerfile 
fi

echo "MAINTAINER $NAME" >> Dockerfile 

case $OS in 
centos) echo -e "RUN yum install ${SOF} -y" >>  Dockerfile
;;
ubuntu|debian|python|jenkins) echo -e "RUN apt install ${SOF} -y" >> Dockerfile 
;;
alpine) echo -e "RUN apk install ${SOF} -y" >> Dockerfile 
;;
*) echo ""
;;
esac

[ -f ${file} ] && echo "COPY ${FILE} S{P} " >> Dockerfile
# echo "COPY ${FILE} ${P} " >> Dockerfile
echo "EXPOSE ${PORT}" >> Dockerfile
echo "CMD ${COM} " >> Dockerfile
echo -e "\n\n"
echo "***************************************"
cat Dockerfile 
echo "*****************************************"
echo -e "\n\n"

echo "the dockerfile is ready please enter your image name: "
read IM 
echo "Now building your image please wait as this can take couple minutes"

docker rmi $(docker images | grep ${IM}:${NAME} | awk '{print$3}') -f 
docker build -t ${IM}:${NAME} . 

docker images | grep ${IM}:${NAME}
if [ $? -eq 0 ]
then
echo "your image was successfully created please run the command docker images to verify "
>Dockerfile
else 
echo " sorry something went wrong please try again ..."
exit 2 
fi
