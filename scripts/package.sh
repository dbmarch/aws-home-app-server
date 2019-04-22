VERSION=`node -e "console.log(require('./package.json').version);"`
APP_NAME=`node e "console.log(require('./package.json').name);"`
zip -r ${APP_NAME}-${VERSION}.zip lib node_modules