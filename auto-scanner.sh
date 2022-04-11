#!/bin/bash

while :
do


PROFILE_OPT="--profile appsec-admin"
AWSCLI="aws"
AWS_PARTITION="aws"




notifyme(){
    python3 reporter.py "$ARN" "$OFFENDER" "$ResourceType" "$REGION" "$IpLocation" "$ACCOUNT_NUM" "$SLACKTITLE"
    echo "You have been notified through slack."
}



fetchdata () {
    DATA=$(aws cloudtrail  lookup-events $PROFILE_OPT  --max-items 300\
        --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::S3::Bucket>data.txt)
}


fetchevent () {
    EventId=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['EventId'])" 2> /dev/null)
}


fetchresourcetype () {
    ResourceType=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['Resources'][0]['ResourceType'])" 2> /dev/null)
    hint="AWS"
    if [[ "$ResourceType" =~ "$hint" ]];then
        :;else
        ResourceType="NA"
    fi
}


fetcheventdata () {
    EventData=$(cat data.txt|python3 -c "import sys, json; print(json.load(sys.stdin)['Events'][$i]['CloudTrailEvent'])" 2> /dev/null)
}



fetchlocation () {
    IpAddress=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['sourceIPAddress'])" 2> /dev/null)
    IsIp=$((echo "$IpAddress" | grep -Eq  ^[0-9\.]+$) && echo "true" || echo "false")
    Positive="true"
    if [[ "$IsIp" == "$Positive" ]]; then
        IpLocation_regionName=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['regionName'])")
        IpLocation_city=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['city'])")
        IpLocation_country=$(curl -s http://ip-api.com/json/$IpAddress |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['country'])")
        IpLocation="$IpLocation_regionName, $IpLocation_city, $IpLocation_country"; else
        IpAddress="NA"
        IpLocation="NA"
    fi
}




fetchextra () {
    EventName=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['eventName'])" 2> /dev/null)
    ARN=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['resources'][0]['ARN'])"  2> /dev/null)
    REGION=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['awsRegion'])" 2> /dev/null)
    ACCOUNT_NUM=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['userIdentity']['accountId'])" 2> /dev/null)
    OFFENDER=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['userIdentity']['principalId'])" 2> /dev/null)
}




checks3 () {
    BucketIdentifier="AWS::S3::Bucket"
    if [[ "$ResourceType" == "$BucketIdentifier"  ]];then
        bucket=$(echo $EventData |python3 -c "import sys, json; print(json.loads(sys.stdin.read())['requestParameters']['bucketName'])" 2> /dev/null)
        source checks/s3/check_extra73
        echo  "s3 check done."
        echo $EventId >>events.txt
    fi
}






executechain () { 
    
    fetchevent
    if ! grep -Fxq "$EventId" events.txt;then
        fetchresourcetype
        fetcheventdata
        fetchlocation
        fetchextra
        checks3
    fi
}



fetchdata

i=-1
while (( i < 299 ));do
    ((i++))
    echo "checking $i" && executechain &
done


done
