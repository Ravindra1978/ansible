
DOMAIN_NAME=ravidevops.cloud
SECURITY_GROUP_ID=sg-02aff670556d3d4d0
IMAGE_ID=ami-03265a0778a880afb
INSTANCE_TYPE=""

for i in $@
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then 
        INSTANCE_TYPE="t3.medium"
    else
         INSTANCE_TYPE="t2.micro"
    fi
echo "Creating $i instance:"
IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID)
echo "Created $i instance: $IP_ADDRESS" 

# aws ec2 associate-iam-instance-profile \
#     --instance-id i-05e76525c51127172 \
#     --iam-instance-profile Name=ec2-admin-role


aws route53 change-resource-record-sets \
    --hosted-zone-id Z01163212KDRMFKEXYVZE \
    --change-batch '{
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "'$i.$DOMAIN_NAME'",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP_ADDRESS'"
                        }
                    ]
                }
            }
        ]
    }'
done