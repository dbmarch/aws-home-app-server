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
echo "ECR REPO:"
echo ${ECR_REPO}
IMAGE=$ECR_REPO:${VERSION}
AWS_REGISTRY=327804519666.dkr.ecr.us-east-2.amazonaws.com

echo "IMAGE "${IMAGE}

repo=`aws ecr describe-repositories --repository-names ${ECR_REPO}`
echo ${repo}

`aws ecr get-login --no-include-email --region us-east-2 --registry-ids 327804519666`
docker build -t $IMAGE . || exit 1
docker tag $IMAGE $AWS_REGISTRY/$IMAGE || exit 1
docker tag $IMAGE $AWS_REGISTRY/$ECR_REPO:latest || exit 1
docker push $AWS_REGISTRY/$IMAGE || exit 1
docker push $AWS_REGISTRY/$ECR_REPO:latest || exit 1

# Update the Cloud formation Template

export STACK_INFO=`aws cloudformation describe-stacks --stack-name $STACK_NAME`
STACK_PARAMETERS=`node -e"console.log(process.env.STACK_INFO)"`
STACK_STATUS=`node -e "console.log(JSON.parse(process.env.STACK_INFO).STacks[0].StackStatus"`

echo ${STACK_INFO}
echo "STACK_PARAM"
echo ${STACK_PARAMETERS}
echo "STACK STATUS"
echo ${STACK_STATUS}

# perform cleanup
#docker rmi -f $IMAGE
#docker rmi -f $AWS_REGISTRY/$IMAGE
