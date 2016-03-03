test:
	bundle exec rspec -r spec_helper.rb spec

lint:
	bundle exec rubocop
