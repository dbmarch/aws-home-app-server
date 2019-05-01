import * as AWS from 'aws-sdk'
import * as AwsAppSettings from '../aws/config'
import Promise from 'bluebird'

AWS.config.region = AwsAppSettings.AWS_REGION
AWS.config.update({
	region: AwsAppSettings.AWS_REGION
})

const ssm = new AWS.SSM()
const ssmGetParameter = Promise.promisify(ssm.getParameter, { context: ssm })

// ssm.deregisterTargetFromMaintenanceWindow(params, function (err, data) {
//   if (err) console.log(err, err.stack); // an error occurred
//   else console.log(data);           // successful response
// });

const getParameter = async (parameter, encrypted) => {
	console.info('Calling getParameer ', parameter, encrypted)
	const params = {
		Name: parameter /* required */,
		WithDecryption: encrypted
	}
	try {
		return await ssmGetParameter(params)
	} catch (err) {
		console.info('Unable to retrieve Parameter', parameter, err.toString())
	}
}

export default getParameter
