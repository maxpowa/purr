# purr

In case you like the pomf-standard api enough to require its existence.

## Installation

`~/.bin/` should be replaced with an appropriate directory on your path.

```
$ crystal build src/cli.cr -o purr
$ mv purr ~/.bin/
```

## Usage

```
Usage: purr [arguments]
    -p, --port=PORT                  Specifies port to run server on
    -i, --client-id=ID               Specifies client id to use with Imgur
    -h, --help                       Show this help
```

## Contributing

1. Fork it ( https://github.com/maxpowa/purr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maxpowa](https://github.com/maxpowa) Max Gurela - creator, maintainer
