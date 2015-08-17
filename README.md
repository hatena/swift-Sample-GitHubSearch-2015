# Swift sample app

## GitHub Search iOS app

This sample app uses the [GitHub Search API](https://developer.github.com/v3/search/#search-repositories).

## How to setup

Install Ruby interpreter with [`rbenv`](https://github.com/sstephenson/rbenv):

```shell
$ rbenv install
```
And then use [Bundler](http://bundler.io):

```shell
$ gem install bundler
$ rbenv rehash
$ bundle install
```

Finally, install pods with [CocoaPods](https://cocoapods.org):

```shell
$ bundle exec pod install
```

Now, open the `xcworkspace` in Xcode and **Run**!
