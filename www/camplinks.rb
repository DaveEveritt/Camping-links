require 'camping'
#require 'enumerator' # to use each_slice in Ruby < 1.8.7

Camping.goes :Camplinks

module Camplinks

  module Controllers

    class Index
      def get
        render :index
      end
    end

    class Page < R '/(\w+)'
      def get(page_name)
        render page_name
      end
    end

    class Static < R '/(.+)'
      MIME_TYPES = {
        # '.html' => 'text/html',
        # '.css'  => 'text/css',
        # '.js'   => 'text/javascript',
        # '.png'  => 'image/png',
        # '.jpg'  => 'image/jpeg',
        '.gif'  => 'image/gif' # image loads without this?
      }
      PATH = "http://dave.camping.sh"
      def get(path)
        @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
        unless path.include? ".." # prevent directory traversal attacks
          @headers['X-Sendfile'] = "/#{path}"
        else
          @status = "403"
          "403 - Invalid path"
        end
      end
    end

  end

  module Helpers

      def makelist(links) # throws a hash of links into a ul in no discernable order
        ul.thelinks do
          links.each_pair do |label,link|
            li { a label, :href => link }
          end
        end
      end
      
      def envars(theenv)
        ul do
          if theenv == ENV # fails to print the next line but shows non-Rack vars??
            p "#{theenv} - Environment variables available to Ruby:"
            theenv.each_pair do |name,value|
              li { name + " " + value }
            end
          else
            p "Rack environment variables:"
            theenv.each do |name|
              li { name }
            end
          end
        end
      end
      
  end

  module Views

    # 'layout' method wraps around the HTML in the other methods
    def layout
      # doctype!
      html do
        head do
          title { 'Ruby Camping framework links: ' + @str }
            link :rel => 'stylesheet', :type => 'text/css', 
            :href => '/styles.css', :media => 'screen'
          end
          body { div.container {
              ul :id => 'menu' do
                  ['Camping links', '/', 'JRuby and Camping', '/jruby', 'Sites using Camping', '/sites'].each_slice(2) do |label,link|
                      li { a label, :href => link }
                  end
              end
              self << yield # inserts partials
              
              if @env['QUERY_STRING'] == "vars"
                div.twiddle {
    
                  h2 'A little variable tracking and other twiddles:'
                  
                  p "QUERY_STRING: " + @env['QUERY_STRING']
                  p "SERVER_SOFTWARE: " + @env['SERVER_SOFTWARE'] + ' on SERVER_PORT ' + @env['SERVER_PORT']
                  p "HTTP_ACCEPT_ENCODING: " + @env['HTTP_ACCEPT_ENCODING']
                  p {'Value of <code>@str</code> (for title and heading): ' + @str}
                  @sourcepath = File.expand_path(File.dirname(__FILE__))
                  p { "Path to this file: #{sourcepath}" }
#                   if @env['HTTP_REFERER'] # fix - works intermittently
#                     refer = @env['HTTP_REFERER'].scan(/\w+$/).to_s # just get the last part of the URL
#                     p { a("Page last visited: #{refer}", :href => refer) + ' (from <code>@env[\'HTTP_REFERER\']</code>)' }
#                   end
#                   sourcefile = __FILE__.scan(/\w+\./).to_s + 'txt'
#                   p { a "Click to view Ruby source code: #{sourcefile}", :type => 'text/plain', :href => '/' + sourcefile }
#                   if ENV['SCRIPT_NAME'] # ENV systax works here?
#                     filename = ENV['SCRIPT_NAME'].scan(/\w+\.\w+$/)
#                     p { "Script name: #{filename}" }
#                   end
#                   filename2 = ENV['SCRIPT_NAME'].scan(/\w+\.\w+$/)
#                   p { "Script name: #{filename2}" }
#                   envars(ENV)
#                   envars(@env)
                } # end twiddle div
              end
              
              p.footer { a('Camping', :href => 'https://github.com/camping/camping/') + ' is a small but almost perfect Ruby framework originally created by ' + a('_why', :href => 'http://viewsourcecode.org/why/') + ' and now under active development.<br>This? A single-file database-free Camping app in a few hundred lines including CSS and content. Can be used for quick wireframe mockups. Source code is ' + a ('on GitHub', :href => 'https://github.com/DaveEveritt/Camping-links') }
            }} # end body and container div
          end
      end

      # The 'index' partial view:
      def index
        @str = "home"
        h1 'Camping framework links'
        p {'This plain-styled block-ugly site is ' + a('my own', :href => 'http://daveeveritt.org/bio.html') + ' collection of links collected during previous versions of Camping, presented here for ' + strong('checking and updating') + " and (after that) maintaining. " + strong('Note:') + " code in those marked 'PRE 2' might need updating. Anyway, I'd better get to work and look up all the ones I haven't checked yet..."}

        h2 "'Official' Camping links:"
        links_o = { # should really convert to array to keep in order although Ruby 1.9 is supposed to do this?
          'Magnus Holm (Judofyr) - Camping master' => 'http://github.com/camping/camping/',
          'Main Camping website' => 'http://camping.rubyforge.org/',
          'The Camping mailing list archive' => 'http://www.mail-archive.com/camping-list@rubyforge.org/',
          'Magnus Holm (Judofyr) - Camping source unabridged (for comments and source code)' => 'https://github.com/camping/camping/blob/master/lib/camping-unabridged.rb',
          'Serving static files/pages' => 'https://github.com/judofyr/camping/wiki/Serving-Static-Files',
          '(needs update) Camping blog example' => 'https://github.com/camping/camping/blob/master/examples/blog.rb',
          '_why\'s 1.4.2 release notes' => 'http://rubyforge.org/pipermail/camping-list/2006-May.txt',
          'Magnus Holm (Judofyr) - Six (unimpressive) reasons Camping is better than you would imagine' => 'http://librelist.com/browser//hacketyhack/2010/7/20/on-camping-vs-sinatra/',
        }
        makelist(links_o) # has to go after each list, not at end of index view

        h2 'Other useful Camping links:'
        p {"These need to be sorted (hosting, databases...) and concatenated (love that word) with those at " + a("Camping Wiki", :href => "https://github.com/camping/camping/wiki/Miscellaneous-Camping-links") }
        links_u = {
          'Running Camping apps on Heroku' => 'http://radiant-sunset-95.heroku.com/how-to-run-camping-2-apps-on-heroku',
          'Camping 2.0 on cgi/fcgi' => 'http://pastie.org/237138', #http://osdir.com/ml/lang.ruby.camping.general/2008-07/msg00029.html
          'Blog example on Heroku' => 'http://radiant-sunset-95.heroku.com',
          'Original inspration for this Camping app' => 'http://snippets.dzone.com/posts/show/1781',
          'Markaby docs' => 'http://markaby.rubyforge.org/',
          'Original post re Camping\'s move to Rack' => 'http://www.mail-archive.com/camping-list@rubyforge.org/msg00764.html',
          'Implementing Ruby Camping REST Services With RESTstop (Philippe Monet)' => 'http://blog.monnet-usa.com/?p=298',
          'CouchCamping (gem) CouchDB as the database layer in Camping!' => 'https://www.ruby-toolbox.com/gems/CouchCamping',
          'Set up your Camping app to run on Dreamhost' => 'http://wiki.dreamhost.com/Camping',
          'Camping compared with Sinatra' => 'http://stackoverflow.com/questions/795727/are-there-any-important-differences-between-camping-and-sinatra',
          "(PRE 2) Jeremy McAnally's 'Going Camping' slides from GoRuCo 07" => "http://slideshow.rubyforge.org/camping.html#1",
          '(PRE-2) Wild and Crazy Metaprogramming with Camping' => 'http://www.oreillynet.com/ruby/blog/2006/06/wild_and_crazy_metaprogramming.html',
          '(PRE-2) Camping and mysql (from Snax)' => 'http://blog.evanweaver.com/articles/2006/09/17/make-camping-connect-to-mysql/',
          '(PRE-2) Camping screencasts' => 'http://www.techscreencast.com/web-development/ruby-on-rails/camping-a-microframework-for-ruby/326',
          '(PRE-2) Introduction to Camping (PDF, Brisbane RubyUG 2007, John Jeffery)' => 'http://files.meetup.com/280030/Introduction%20to%20Camping.pdf',
          '(PRE-2) Polzr.goes :Camping (2007)' => 'http://polzr.blogspot.co.uk/',
        }
        makelist(links_u)

        h2 'Testing for Camping:'
        links_t = {
          'Mosquito (GitHub)' => 'https://github.com/topfunky/mosquito/',
          'Mosquito docs (Geoffrey Grosenbach): unit and functional tests on Camping models and controllers' => 'http://mosquito.rubyforge.org/',
          'Magnus Holm (Judofyr) - Camping testing framework' => 'http://github.com/judofyr/camping-test/tree/master',
          '(Abandoned?) Test-unit (Geoffrey Grosenbach): Mosquito-based testing in the style of Test::Unit' => 'http://rubyforge.org/projects/testcamp',
          'A/B Test Your Camping App Using ABingo (Philippe Monnet)' => 'http://blog.monnet-usa.com/?cat=28',
        }
        makelist(links_t)

        h2 'Stuff I haven\'t checked yet:'
        links_l = {
          'Ruby, Ubuntu and Apache etc.' => 'https://help.ubuntu.com/community/RubyOnRails#Apache',
          'Open ID authentication' => 'http://wiki.github.com/why/camping/openid-authentication',
          'Picnic: Linux and gem-friendly Camping' => 'http://code.google.com/p/camping-picnic/wiki/PicnicTutorial',
          'optional multi-pane layout' => 'http://www.mail-archive.com/camping-list@rubyforge.org/msg00676.html',
          'ActiveRecord table definition' => 'http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#M000759'
        }
        makelist(links_l)

      end

      # The 'jruby' partial view:
      def jruby
        @str = "Camping with JRuby"
        h1 'Camping links: ' + @str
        p "this might be too small a category, so these may be moved."
        h2 'Using JRuby and Camping:'
        links_t = {
          'Camping in jRuby' => 'https://github.com/camping/camping/wiki/Camping-in-jRuby',
          '(PRE 2) JRuby Camping blog example' => 'http://docs.codehaus.org/display/JRUBY/The+JRuby+Tutorial+Part+2+-+Going+Camping',
          '(PRE 2) Another JRuby blog, with a Camping fork on Github' => 'http://goeslightly.blogspot.com/2008/04/campdepict-jruby-cdk-and-camping.html',
        }
        makelist(links_t)
      end

      # The 'sites' partial view:
      def sites
        @str = "sites built with Camping"
        h1 'Camping links: ' + @str
        p {"Here are a selecton of sites, services and apps made with Camping. If you want to add one, please send a link to the " + a("Camping mailing list", :href => "http://rubyforge.org/mailman/listinfo/camping-list") + "." }
        h2 'Websites and services:'
        links_l = {
          'Cheat - local/remote command-line cheat sheets (Chris Wanstrath)' => 'http://cheat.errtheblog.com/',
          'More about Cheat (blog post)' => 'http://errtheblog.com/posts/91-the-best-of-cheat',
          'Knockout.js tutorial files and demo (Philippe Monet)' => 'http://savings-goal-simulator.herokuapp.com/',
          'My Skills Map (Philippe Monet)' => 'http://www.myskillsmap.com/',
          'Hurl it - demo and debug APIs (Chris Wanstrath and Leah Culver)' => 'http://hurl.it/',
          '(PRE 2?) tippy tippy tepee: Camping-based sandboxed scriptable wiki' => 'https://github.com/parolkar/why_sandbox/tree/master/examples/tippytippytepee',
          'Rapid Dating Malta (Nokan Emiro)' => 'http://rapiddatingmalta.com/',
        }
        makelist(links_l)
      end

  end

end

__END__
@@/styles.css
* {
  margin:0;
  padding:0;
}

body {
  font:normal 14px "Helvetica Neue", Helvetica, Tahoma, sans-serif;
  line-height:1.5;
  background-color:#696;
  color:#444;
}
.container {
  width:80%;
  margin:1em auto 0px;
  padding:10px;
  border:1px solid #8b8;
  background:#eee url(camping_bg.gif) 99% 44px no-repeat;
  border-radius:10px;
}
#menu {
  list-style-type:none;
  text-align:center;
}
#menu li {
  display:inline-block;
  width:33%;
  text-align:center;
  margin:0 2px;
}
#menu > li {
  margin-left:0;
}
#menu li a {
  display:block;
  color:#fefefe;
  background:#474;
  text-decoration:none;
  padding:0.25em 0;
  letter-spacing:1px;
  border-radius:6px;
}
#menu li a:hover {
  display:block;
  color:#eee;
  background:#696;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.8);
}
h1, h2 {
  color:#363;
  text-shadow: 1px 1px 1px rgba(100, 100, 100, 0.6);
}
h1 {
  margin:0.5em 0 0.25em;
  font-size:2em;
  text-align:center;
}
h2 {
  font-size:1.2em;
  padding:0 0.25em 0.2em 0;
  margin:0.5em 0;
}
h1 + p {
  padding:0 10% 0.5em;
  text-align:center;
}
h2 + p {
  margin-top:-0.5em;
}
p + p,
p + ul {
  margin-top:0.5em;
}
.thelinks {
  margin-left:40px;
}
a:link,
.footer a:link,
.footer a:visited {
  color:#444;
  text-decoration:none;
}
a:visited {
  color:#666;
}
a:hover,
p a:hover {
  text-decoration:underline;
  color:#111;
}
p a:link {
  text-decoration:underline;
}
.twiddle {
  margin-top:1.5em;
  padding:0.5em 1em 1em;
  font-size:80%;
  border:2px solid rgba(80,180,80,0.3);
  background-color:rgba(200,200,200,0.35);
  border-radius:6px;
}
.footer {
  margin-top:1em;
  background-color:#474;
  color:#fff;
  font-size:0.75em;
  padding:0.25em;
  text-align:center;
  border-radius:6px;
}
.footer a:link,
.footer a:visited {
  color:#ada;
}
.footer a:hover {
  color:white;
}