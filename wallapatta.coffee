require './lib/mod/mod'

Mod.set 'fs', require 'fs'
Mod.set 'jsdom', require 'jsdom'
Mod.set 'Weya', require './lib/weya/weya'
Mod.set 'Weya.Base', require './lib/weya/base'
Mod.set 'yamljs', require 'yamljs'
Mod.set 'path', require 'path'
Mod.set 'HLJS', require 'highlight.js'
{exec} = require 'child_process'

require './file'
require './paginate'

require './js/parser'
require './js/nodes'
require './js/reader'
require './js/render'

Mod.require 'jsdom',
 'fs'
 'yamljs'
 'path'
 'Wallapatta.File'
 'Wallapatta.Paginate'
 'Weya'
 (jsdom, fs, YAML, path, FileRender, Paginate, Weya) ->

  exports.copyStatic = copyStatic = (options, callback) ->
   if not options.static?
    callback()
    return

   commands = []
   js = path.resolve options.output, 'js'
   css = path.resolve options.output, 'css'
   lib  = path.resolve options.output, 'lib'
   if fs.existsSync js
    commands.push "rm -r #{js}"
   if fs.existsSync css
    commands.push "rm -r #{css}"
   if fs.existsSync lib
    commands.push "rm -r #{lib}"

   commands = commands.concat [
    "mkdir #{js}"
    "mkdir #{css}"
    "mkdir #{lib}"
    "cp -r #{path.resolve __dirname, 'build/js/*'} #{js}"
    "cp -r #{path.resolve __dirname, 'build/css/*'} #{css}"
    "cp -r #{path.resolve __dirname, 'build/lib/*'} #{lib}"
   ]

   exec commands.join('&&'), (e, stderr, stdout) ->
    console.error stderr.trim()
    console.log stdout.trim()
    e = (if e? then 1 else 0)
    callback e


  renderPost = (options, opt) ->
   FileRender
    file: opt.file
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "#{opt.id}.html"
    options: opt

   if opt.content?
    for i in opt.content
     renderPost options, i


  exports.file = (options, callback) ->
   FileRender
    file: options.file
    template: path.resolve __dirname, options.template
    output: path.resolve options.output, "index.html"
    options:
     title: options.title

   copyStatic options, callback

  exports.book = (options, callback) ->
   data = YAML.parse "#{fs.readFileSync options.book}"
   toc = require path.resolve __dirname, options.toc

   jsdom.env '<div id="toc"></div>', (err, window) ->
    Weya.setApi document: window.document
    tocElem = window.document.getElementById 'toc'
    toc.render data, tocElem
    output = toc.html
     title: data.title
     toc: tocElem.innerHTML

    fs.writeFileSync (path.resolve options.output, "toc.html"), output

    for i in data
     renderPost options, i

   copyStatic options, callback


  exports.blog = (options, callback) ->
   blog = YAML.parse "#{fs.readFileSync options.blog}"
   inputs = []
   pages = 0
   N = Math.ceil blog.posts.length / blog.postsPerPage
   cwd = path.dirname options.blog
   paginateTemplate =
    path.resolve __dirname,
                 path.resolve cwd, blog.paginateTemplate
   postTemplate =
    path.resolve __dirname,
                 path.resolve cwd, blog.postTemplate

   paginate = ->
    Paginate
     input: inputs
     page: pages
     template: paginateTemplate
     output: options.output
     pages: N
    pages++
    inputs = []

   for post in blog.posts
    FileRender
     file: path.resolve cwd, post.file
     template: postTemplate
     output: path.resolve options.output, "#{post.id}.html"
     title: post.title
    inputs.push
     file: path.resolve cwd, post.file
     id: post.id
     title: post.title
    if inputs.length is blog.postsPerPage
     paginate()

   if inputs.length > 0
    paginate()

   copyStatic options, callback

Mod.initialize()
