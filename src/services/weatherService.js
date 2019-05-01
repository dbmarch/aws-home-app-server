import getParameter from '../aws/getParameter'
import get from 'lodash/get'

const route = async router => {
	console.info('weatherService')

	const darkSkyApiKeyParam = await getParameter('DARK_SKY_API_ID', false)
	const defaultLocation = '42.3601,-71.0589'
	const DARK_SKY_BASE_URL = 'https://api.darksky.net/forecast/'

	const darkSkyApiKey = get(darkSkyApiKeyParam.Parameter, 'Value', null)
	console.info(`Dark Sky API Key is ${darkSkyApiKey ? 'LOADED' : 'NOT_LOADED'}`)

	// the call is
	const API_URL = `${DARK_SKY_BASE_URL}${darkSkyApiKey}/${defaultLocation}`

	router.get('/', (req, res, next) => {
		res.status(200).send({ message: API_URL })
	})
}

module.exports = route
