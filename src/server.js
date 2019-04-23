const express = require('express')
var bodyParser = require('body-parser')
const path = require('path')
const app = express()
var cors = require('cors')

const port = process.env.PORT || 3001

app.use(cors())
app.use(express.static(path.join(__dirname, 'build')))
app.use(bodyParser.json())

app.get('/healthcheck', (req, res) => {
	res.send({ message: 'health check' })
})
app.get('/ping', (req, res) => {
	res.send({ message: 'health check' })
})

app.get('/api/hello', (req, res) => {
	res.send({ message: 'Hello From Express' })
})

app.get('/', function(req, res) {
	res.send('Hello from React Server')
})

if (process.env.NODE_ENV === 'production') {
	// Serve any static files
	app.use(express.static(path.join(__dirname, 'client/build')))
	// Handle React routing, return all requests to React app
	app.get('*', function(req, res) {
		res.sendFile(path.join(__dirname, 'client/build', 'index.html'))
	})
}

// app.listen(port, () => console.log(`Listening on port ${port}`));
app.listen(port, () => {
	console.log(`Resource Server Ready on port ${port}`)
})
module.exports = { app }
