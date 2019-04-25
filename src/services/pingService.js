const route = router => {
	console.info('pingService')
	router.get('/', (req, res, next) => {
		res.status(200).send()
	})
}

module.exports = route
