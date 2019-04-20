module.exports = {
	apps: [
		{
			name: 'aws-home-app-server',
			script: './src/server.js',
			instances: 0,
			exec_mode: 'cluster',
			watch: true,
			env: {
				NODE_ENV: 'production',
				PORT: '3001'
			}
		}
	]
}
