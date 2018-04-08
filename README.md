# Wildcat

*This is a work in progress. Not even nearly 1.0.*

Wildcat is a content management and blogging system written in Ruby that generates static pages.

It is designed to be run locally or on a server. It is designed to be fast.

It can generate websites that *don’t* have a blog — for instance, you could use it to generate the help files for a Mac or iOS app. But its main use is for sites with a blog.

It generates JSON Feed and RSS feeds as well as HTML pages. It supports the MetaWeblog API. It supports title-less blog posts, too, so you can use this is a microblogging system, if you want. Or as a hybrid — you can mix posts-with-titles and posts-without-titles.

I’m not looking for pull requests yet. Some time in the future, possibly, although forking just may be the better way to go.

Note: if the Ruby seems weird anywhere, please let me know. I’m a Swift and Objective-C developer trying to get good at Ruby, but realizing I have a long way to go. :)

This code is licensed via The Unlicense. If you fork it, all I ask is that you choose a name other than Wildcat, so there’s no confusion.

## The gist

Blog posts and pages are stored as files on disk. No databases.

At the top of each file is some attributes — lines that start with a `@` sign. Below that is either HTML or Markdown.

Files are treated according to their suffixes: `.html` means not to process the text; `.markdown` means to use the Markdown renderer.

(Wildcat requires the RDiscount gem for Markdown rendering.)

## Macros

### No macros (or scripts) in pages and posts

Pages and posts don’t get any kind of macros.

I’ve been writing blogging systems since the ’90s, and I’ve found that while it may be relatively easy to migrate from one system to another, the thing that doesn’t get migrated is any special trickery inside pages and posts.

With that in mind, the only processing that gets done is Markdown rendering.

### Templates

Templates, on other hand, may include other files and may contain substitutions. While you can’t place scripts inside templates, you can place text that gets substituted at build time.

The idea is that there are very few templates compared to the number of pages and posts, and so migration of templates isn’t that big of a job, so it’s worth supporting these features for templates.

## Performance

It rebuilds the entire site on any change. It’s not fancy.

But a rebuild for my [19-year-old blog](http://inessential.com/) takes about three seconds. It’s fast.

## How to run on a server

TBD

## How to run locally

TBD
