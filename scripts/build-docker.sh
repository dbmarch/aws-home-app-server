ls
pwd

EXPORT ECR_REPO=327804519666.dkr.ecr.us-east-2.amazonaws.com/home-app-server

EXPORT VERSION=`node -e "console.log(require(./package.json').version);"`

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
echo $ECR_REPO $VERSION
IMAGE = $ECR_REPO:${VERSION}
AWS_REGISTRY=327804519666.dkr.ecr.us-east-2.amazonaws.com

repo = `aws ecr describe-repositories --repository-names ${ECR_REPO}`

echo ${repo}

aws ecr get-login --no-include-email --region us-east-2 --registry-ids 327804519666
docker build -t $IMAGE . || exit 1

