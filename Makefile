
install:
	bundle install

build: install
	RUBYOPT='-W0' bundle exec jekyll build -d docs

serve: install
	RUBYOPT='-W0' bundle exec jekyll serve -d _drafts