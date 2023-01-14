build:
	RUBYOPT='-W0' bundle exec jekyll build -d docs

serve:
	RUBYOPT='-W0' bundle exec jekyll serve -d _drafts