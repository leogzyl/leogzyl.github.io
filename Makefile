

build:
	JEKYLL_ENV=production bundle exec jekyll build -d docs

serve:
	JEKYLL_ENV=dev bundle exec jekyll serve --host 0.0.0.0