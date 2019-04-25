const route = router => {
	console.info('imageService')
	router.get('/', (req, res, next) => {
		console.info('GET /images')
		res.send('GET /image')
	})
}

module.exports = route
