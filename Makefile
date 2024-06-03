include .env

run:
	ruby main.rb

publish:
	ngrok http --domain=$(APP_DOMAIN) 8080