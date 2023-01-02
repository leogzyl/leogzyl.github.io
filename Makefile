
install:
	bundle install

build: install
	bundle exec jekyll build -d docs

serve: install
	bundle exec jekyll serve -d docs