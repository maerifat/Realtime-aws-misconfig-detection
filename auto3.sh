#/bin/bash

while : 
do
rm data.txt

PROFILE_OPT="--profile maerifat"
AWSCLI="aws"


i=0
fetchdata () {
DATA=$(aws cloudtrail  lookup-events $PROFILE_OPT  --max-items 3\
 --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::S3::Bucket>data.txt)
}

fetchdata

fetchevent () {


#About the Resource
ResourceType=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['Resources'][0]['ResourceType'])" 2> /dev/null)
hint="AWS"
if [[ "$ResourceType" =~ "$hint" ]];then
:
else
ResourceType="NA"
fi










#--------------------------------


EventId=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['EventId'])" 2> /dev/null)






if ! grep -Fxq "$EventId" events.txt
then

EventData=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['CloudTrailEvent'])" 2> /dev/null)




# About the Ip Address and then location
IpAddress=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['sourceIPAddress'])" 2> /dev/null)
IpLocation_regionName=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['regionName'])")
IpLocation_city=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['city'])")
IpLocation_country=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['country'])")

IpLocations="$IpLocation_regionName, $IpLocation_city, $IpLocation_country"
IpLocation=$(echo $IpLocations)

IsIp=$((echo "$IpAddress" | grep -Eq  ^[0-9\.]+$) && echo "true" || echo "false")





Positive="true"



if [[ "$IsIp" == "$Positive" ]]
then
:
else
IpAddress="NA"
fi






#About the Event Name
EventName=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['eventName'])" 2> /dev/null)
ARN=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['resources'][0]['ARN'])"  2> /dev/null)
REGION=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['awsRegion'])" 2> /dev/null)
ACCOUNT_NUM=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['userIdentity']['accountId'])" 2> /dev/null)
AWS_PARTITION="aws"
OFFENDER=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['userIdentity']['principalId'])" 2> /dev/null)

fi









BucketIdentifier="AWS::S3::Bucket"

if [[ "$ResourceType" == "$BucketIdentifier"  ]]
then
if ! grep -Fxq "$EventId" events.txt
then
bucket=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['requestParameters']['bucketName'])" 2> /dev/null)

source check_extra73
echo "I'm checked"
echo "Bucket is $bucket"
echo $EventId >>events.txt
else
echo "$EventId already there"
fi
fi





#Printing Center
echo "Ip address is $IpAddress"
echo "ARN is $ARN"
echo "Region is $REGION"
echo "Resource type is $ResourceType"
echo "Event id is $EventId"
#echo $EventData| jq
echo "Event name is $EventName"
echo "Offender is $OFFENDER"
echo "$AWS_PARTITION is partition name"
echo "Location is: $IpLocation "
echo " "
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo " " 
echo " "
}


i=0
while (( i < 3  ))
do
fetchevent 
((i++))
sleep 5
done



rm data.txt

done
