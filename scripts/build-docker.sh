echo "Running Build-docker.sh"
export APP_NAME=`node -e "console.log(require('./package.json').name);"`
export AWS_REGION="us-east-2"
export ECR_REPO="home-app-server"
export VERSION=`node -e "console.log(require('./package.json').version);"`
export STACK_NAME="home-app-server"
echo "Version "${VERSION}
echo "App name: "${APP_NAME}

if [ -f packaget-lock.json ]; then
  echo "Using locked versions"
  npm ci || exit 1
else
  echo "Using package.json"
  npm i || exit 1
fi

echo "Code is built"

npm run package || exit 1
npm prune --production || exit 1

echo "ECR_REPO: "${ECR_REPO}
IMAGE=$ECR_REPO:${VERSION}
AWS_REGISTRY=327804519666.dkr.ecr.us-east-2.amazonaws.com

echo "IMAGE "$IMAGE

repo=`aws ecr describe-repositories --repository-names ${ECR_REPO}`
echo "ECR REPOSITORIES: "$repo

`aws ecr get-login --no-include-email --region us-east-2 --registry-ids 327804519666`
docker build -t $IMAGE . || exit 1
docker tag $IMAGE $AWS_REGISTRY/$IMAGE || exit 1
docker tag $IMAGE $AWS_REGISTRY/$ECR_REPO:latest || exit 1
docker push $AWS_REGISTRY/$IMAGE || exit 1
docker push $AWS_REGISTRY/$ECR_REPO:latest || exit 1

# Update the Cloud formation Template
echo "STACK NAME: "$STACK_NAME

STACK_INFO=`aws cloudformation describe-stacks --stack-name $STACK_NAME`
echo $STACK_INFO
export STACK_INFO
#BUILD_STAMP="$(date +"%T")"
BUILD_STAMP=`date "+%Y%m%d-%H%M"`
STACK_VERSION_PARAMETER="ApplicationVersion"
export STACK_VERSION_PARAMETER
echo "BUILD_STAMP "$BUILD_STAMP
#export STACK_INFO=`aws cloudformation describe-stacks --stack-name $STACK_NAME`
#STACK_PARAMETERS=`node -e "console.log(JSON.stringify(JSON.parse(process.env.STACK_INFO).Stacks[0].Parameters))"`
STACK_PARAMETERS=`node -e "console.log(JSON.stringify(JSON.parse(process.env.STACK_INFO).Stacks[0].Parameters.map(param=>(param.ParameterKey===process.env.STACK_VERSION_PARAMETER) ? {ParameterKey : param.ParameterKey, ParameterValue: process.env.VERSION} : {ParameterKey : param.ParameterKey, UsePreviousValue:true})))"`
STACK_STATUS=`node -e "console.log(JSON.parse(process.env.STACK_INFO).Stacks[0].StackStatus)"`

echo "STACK_PARAM "${STACK_PARAMETERS}
echo "STACK STATUS "${STACK_STATUS}

if [ "$STACK_STATUS" = "CREATE_COMPLETE" ] || [ "$STACK_STATUS" = "UPDATE_COMPLETE" ] || [ "$STACK_STATUS" = "UPDATE_ROLLBACK_COMPLETE" ]
then
   echo "Updating the stack "$STACK_NAME
   echo "STACK parameters: "$STACK_PARAMETERS
   aws cloudformation update-stack --stack-name $STACK_NAME --use-previous-template --parameters "$STACK_PARAMETERS" --capabilities CAPABILITY_NAMED_IAM
else
  echo "UNABLE TO UPDATE STACK "$STACK_STATUS
fi

# perform cleanup
#docker rmi -f $IMAGE
#docker rmi -f $AWS_REGISTRY/$IMAGE

if docker images -f "dangling=true" | grep ago --quiet; then
     docker rmi -f $(docker images -f "dangling=true" -q)
fi