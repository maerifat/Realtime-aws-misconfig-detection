import json
import sys
import random
import requests
if __name__ == '__main__':
    url = "https://hooks.slack.com/services/T02JLFT344U/B02K807C8SU/F8V9FQMXBl8E7RlxXXXXXXXXXX"
    ARN = sys.argv[1]
    OFFENDER =sys.argv[2]
    RESOURCETYPE= sys.argv[3]
    REGION= sys.argv[4]
    IPLOCATION= sys.argv[5]
    ACCOUNTID= sys.argv[6]
    SLACKTITLE= sys.argv[7]

    message = (f"*AccountId:* {ACCOUNTID} \n *Resource Type:* {RESOURCETYPE}\n *Region:* {REGION} \n *Offender:* {OFFENDER} \n *ARN:* {ARN} \n *Location:* {IPLOCATION} ")
    title = (SLACKTITLE)
  
    slack_data = {


	"blocks": [
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": title
				
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": message
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "The issue has been stored for further analysis."
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": "View Issue Details"
					
				},
				"value": "click_me_123",
				"url": "https://example.com",
				"action_id": "button-action"
			}
		},
		{
			"type": "divider"
		}
	]
}
    byte_length = str(sys.getsizeof(slack_data))
    headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
    response = requests.post(url, data=json.dumps(slack_data), headers=headers)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
