VERSION = 9

Weya = require '../lib//weya/weya'

UI_JS = [
 'static'
 'parser'
 'reader'
 'nodes'
]

template = ->
 title = @$.options.options.title
 @html ->
  @head ->
   @meta charset: "utf-8"
   if title?
    @title title
   else
    @title "Made with Wallapatta"
   @meta name: "viewport", content: "width=device-width, initial-scale=1.0"
   @meta name: "apple-mobile-web-app-capable", content:"yes"
   @link
    href: 'http://fonts.googleapis.com/css?family=Lato:100,300,400,700'
    rel: 'stylesheet'
    type: 'text/css'
   @link href: "lib/bootstrap/css/bootstrap.min.css", rel: "stylesheet"
   @link href: "lib/fontawesome/css/font-awesome.min.css", rel: "stylesheet"
   @link href: "css/style.css", rel: "stylesheet"
   @link rel: "shortcut icon", href: "img/favicon.ico", type: "image/x-icon"
   @script '''
     (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
     (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
     m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
     })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

     ga('create', 'UA-37809145-1', 'auto');
     ga('send', 'pageview');
   '''

  @body ->
   @div ".container.wallapatta-container", ->
    @div ".row.wallapatta", ->
     if title?
      @div ".col-xs-12", ->
       @h1 ".title", title
     @div ".wallapatta-main.col-xs-9", "###MAIN###"
     @div ".wallapatta-sidebar.col-xs-3", "###SIDEBAR###"
     @div style: {display: 'none'}, "###CODE###"

   @script src:"lib/weya/weya.js"
   @script src:"lib/weya/base.js"
   @script src:"lib/mod/mod.js"

   for file in @$.scripts
    @script src: "js/#{file}.js?v=#{VERSION}"

exports.html = (options) ->
 options ?= {}
 options.scripts ?= UI_JS

 html = Weya.markup context: options, template

 html = html.replace '###MAIN###', options.main
 html = html.replace '###SIDEBAR###', options.sidebar
 html = html.replace '###CODE###',
  "<div class='wallapatta-code'>#{options.code}</div>"

 html = "<!DOCTYPE html>#{html}"

 return html


