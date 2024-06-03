include .env

run:
	ruby main.rb

publish:
	ifndef APP_DOMAIN
		$(error APP_DOMAIN is not set)
	endif

	ngrok http --domain=$(APP_DOMAIN) 8080