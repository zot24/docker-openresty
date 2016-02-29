# OpenResty Docker image

This is an OpenResty docker base image based on the [ficusio/openresty](https://github.com/ficusio/openresty) docker image with just few modifications to make it even more basic, actually it won't be useful unless you set it as a base image and extend it using the `FROM` instruction.

## Getting Started

This container have been build for being used as a base image and extend it, so you'll need to first `EXPOSE 8080` or the port you specify on your `nginx.conf`, file that you'll need as well as to `COPY/ADD` when extending the base image, like: for example:

```
FROM zot24/openresty

RUN rm -rf conf/* html/*
COPY nginx $NGINX_PREFIX/

EXPOSE 8080
```

## Resources

Some util resources about docker + images + alpine + being smart :)

* [Tips & Tricks with Alpine + Docker](http://blog.zot24.com/tips-tricks-with-alpine-docker/)
* [Tips & Tricks with Docker & Docker compose](http://blog.zot24.com/tips-tricks-docker/)

## Authors

* **Israel Sotomayor** - *Initial work* - [zot24](https://github.com/zot24)

See also the list of [contributors](https://github.com/zot24/openresty/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
