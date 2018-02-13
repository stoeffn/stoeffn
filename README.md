# Stoeffn
Welcome! This is the source code for my [personal website](https://stoeffn.de), which is a work-in-progress blog and projects hub. Feel free to explore and use parts for your own work :)

## Stack
As personal websites are almost never dynamic in a way that requires server-side code, I've decided to [Go Hugo](https://gohugo.io). Hugo is popular static site generator that strives for simplicity and performance. It offers powerful templating as well as easy content management with a simple format loved by many developers: Markdown.

The generated source code at `public` lives in its own repository and its contents are hosted by [GitHub Pages](https://pages.github.com), making it easy to manage.

As a final layer, I use [Cloudflare](https://www.cloudflare.com) for DNS management, caching, and SSL encryption.

## Getting Started
Want to fiddle around a little bit? Sure! Take a look at the [Hugo Quick Start Guide](https://gohugo.io/getting-started/quick-start/), install it and you are ready to go!

> Type `hugo server` to start a local development server at http://localhost:1313.

## Deployment
In order to automate deployment, I've created a simple shell script `./deploy.sh`. In a matter of seconds, a new version of the website can be deployed by typing one command:

```sh
./deploy <Version> <Description>
```

`Version` is a simple version name (e.g. `v1.0-beta`) and `Description` is an optional changelog or summary.

Here is how it works:

1. Make sure there is a version name argument
2. Check if a version with that name has already been deployed
3. Invoke `hugo` to build the site
4. Commit the generated changes to the `public` submodule and set a tag with the given version name and description
5. Push the public submodule along with new tags
6. Commit the new `public` submodule hash and set a tag with the given version name and description
7. Push along with new tags
