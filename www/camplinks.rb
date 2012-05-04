require 'camping'
#require 'enumerator' # to use each_slice in Ruby < 1.8.7

Camping.goes :Camplinks

module Camplinks

  module Models
        links_j = {
          'Camping in jRuby' => 'https://github.com/camping/camping/wiki/Camping-in-jRuby',
          '(PRE 2) JRuby Camping blog example' => 'http://docs.codehaus.org/display/JRUBY/The+JRuby+Tutorial+Part+2+-+Going+Camping',
          '(PRE 2) Another JRuby blog, with a Camping fork on Github' => 'http://goeslightly.blogspot.com/2008/04/campdepict-jruby-cdk-and-camping.html',
        }
  end

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
            li { a(:href => link) { label } }
          end
        end
      end
      
      def envars(theenv) # displays environment vars if 'vars' query string added to URL
        ul do
          if theenv == ENV
            li.emph "#{theenv} - non-Rack environment variables available to Ruby:"
            theenv.each_pair do |name,value|
              li { name + " " + value }
            end
          else
            li.emph "@env (or env in Camping) - Rack environment variables:"
#             env.sort_by { |k, v| k.to_s }.each { |key, val|
#               li { key + " " + value }
#             }
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
                  ['Camping misc. links', '/', 'Databases and hosting', '/databases', 'Sites using Camping', '/sites'].each_slice(2) do |label,link|
                      li { a label, :href => link } #, :class => 'here'
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
                  envars(ENV)
                  envars(env)
                } # end twiddle div
              end
              
              p.footer { 
                  a('Camping', :href => 'https://github.com/camping/camping/') + ' is a small but almost perfect Ruby framework originally created by ' + a('_why', :href => 'http://viewsourcecode.org/why/') + ' and now under active development.<br>
                  This? A monofile db-free Camping app (inspired by ' + a('this snippet', :href => 'http://snippets.dzone.com/posts/show/1781') + ' in a few hundred lines including CSS and content. Also good for quick wireframe mockups. ' + a ('Source code on GitHub', :href => 'https://github.com/DaveEveritt/Camping-links')
              }
            }} # end body and container div
          end
      end

      # The 'index' partial view:
      def index
      
        @str = "home"
        h1 'Camping framework links'
        p {'This simple site is ' + a('my own', :href => 'http://daveeveritt.org/bio.html') + ' collection of links collected during previous versions of Camping, presented here for checking, updating and maintaining. ' + strong('Note:') + " code in those marked 'PRE 2' " + em('might') + " still work. Soil background by " + a('Bluebie', :href => 'http://creativepony.com/') + '.'}

        h2 "'Official' Camping links:"
        links_o = { # should really convert to array to keep in order although Ruby 1.9 is supposed to do this?
          'Main Camping website' => 'http://camping.io',
          'Camping website (RubyForge, outdated)' => 'http://camping.rubyforge.org/',
          'Camping master - Magnus Holm (Judofyr)' => 'http://github.com/camping/camping/',
          'Markup as Ruby: mab - with handy reference (Github)' => 'https://github.com/camping/mab',
          'Camping, the Reference' => 'http://camping.rubyforge.org/api.html',
          'The Camping mailing list archive' => 'http://www.mail-archive.com/camping-list@rubyforge.org/',
          'Camping source unabridged (for comments and source code) - Magnus Holm (Judofyr)' => 'https://github.com/camping/camping/blob/master/lib/camping-unabridged.rb',
          'Serving static files/pages' => 'https://github.com/judofyr/camping/wiki/Serving-Static-Files',
          'OpenID Authentication in Camping - Magnus Holm  (Judofyr)' => 'https://github.com/judofyr/camping/wiki/openid-authentication',
          '(needs update) Camping blog example' => 'https://github.com/camping/camping/blob/master/examples/blog.rb',
          '_why\'s 1.4.2 release notes' => 'http://rubyforge.org/pipermail/camping-list/2006-May.txt',
        }
        makelist(links_o) # has to go after each list, not at end of index view

        h2 'Testing for Camping:'
        links_t = {
          '<strong>Mosquito</strong> (GitHub)' => 'https://github.com/topfunky/mosquito/',
          'Mosquito docs (Geoffrey Grosenbach): unit and functional tests on Camping models and controllers' => 'http://mosquito.rubyforge.org/',
          'Camping testing framework - Magnus Holm (Judofyr)' => 'http://github.com/judofyr/camping-test/tree/master',
          '(Abandoned?) <strong>Test-unit</strong> (Geoffrey Grosenbach): Mosquito-based testing in the style of Test::Unit' => 'http://rubyforge.org/projects/testcamp',
        }
        makelist(links_t)

        h2 'Extensions, wrappers, etc. for Camping:'
        links_w = {
          '<strong>Picnic</strong> - install a Camping app as a gem, and run it as a Linux service (almost) right out of the box (Matt Zukowski 2010)' => 'http://code.google.com/p/camping-picnic/',
          '(PRE 2?) <strong>Sleeping Bag</strong>: Rails-style REST resource controllers in your Camping app' => 'http://code.google.com/p/sleepingbag/',
          '(PRE 2) <strong>Parasite</strong>: brings generators, environments, and other Rails-y goodness to the world of Camping app development' => 'http://parasite.rubyforge.org/',
          '(PRE 2?) <strong>TentSteak</strong>: a meaty extension for Camping seasoned with Markaby helper methods, stylesheet management, and bootstrappy goodness.' => 'http://tentsteak.rubyforge.org/',
        }
        makelist(links_w)

        h2 'Using JRuby and Camping:'
        links_j = {
          'Camping in jRuby' => 'https://github.com/camping/camping/wiki/Camping-in-jRuby',
          '(PRE 2) JRuby Camping blog example' => 'http://docs.codehaus.org/display/JRUBY/The+JRuby+Tutorial+Part+2+-+Going+Camping',
          '(PRE 2) Another JRuby blog, with a Camping fork on Github' => 'http://goeslightly.blogspot.com/2008/04/campdepict-jruby-cdk-and-camping.html',
        }
        makelist(links_j)

        h2 'Other useful Camping links:'
        p {"These need to be sorted and concatenated (love that word) with those at " + a("Camping Wiki", :href => "https://github.com/camping/camping/wiki/Miscellaneous-Camping-links") }
        links_u = {
          'Six (unimpressive) reasons Camping is better than you would imagine - Magnus Holm (Judofyr)' => 'http://librelist.com/browser//hacketyhack/2010/7/20/on-camping-vs-sinatra/',
          'Markaby docs' => 'http://markaby.rubyforge.org/',
          'Implementing Ruby Camping REST Services With <strong>RESTstop</strong> (Philippe Monet)' => 'http://blog.monnet-usa.com/?p=298',
          'Camping compared with Sinatra' => 'http://stackoverflow.com/questions/795727/are-there-any-important-differences-between-camping-and-sinatra',
          '<strong>ABingo</strong>: <dfn title="Test two kinds of user interface in one app">A/B Test</dfn> Your Camping App (Philippe Monnet)' => 'http://blog.monnet-usa.com/?cat=28',
          'optional multi-pane layout (snippet, Zimbatm' => 'http://www.mail-archive.com/camping-list@rubyforge.org/msg00676.html',
          '(PRE 2) Going off the Rails with Camping (slides, RailsConf Europe 2006 by Eleanor McHugh + Romek Szczesniak)' => 'http://www.slideshare.net/feyeleanor/camping-going-off-the-rails-with-ruby',
          '(PRE 2) Introductory talk on Camping (slides, Ruby User Group Berlin 2007, Gregor Schmidt)' => 'http://www.slideshare.net/schmidt/camping-126337',
          "(PRE 2) Jeremy McAnally's 'Going Camping' slides from GoRuCo 07" => "http://slideshow.rubyforge.org/camping.html#1",
          '(PRE-2) Wild and Crazy Metaprogramming with Camping' => 'http://www.oreillynet.com/ruby/blog/2006/06/wild_and_crazy_metaprogramming.html',
          '(PRE-2) Camping screencasts' => 'http://www.techscreencast.com/web-development/ruby-on-rails/camping-a-microframework-for-ruby/326',
          '(PRE-2) Introduction to Camping (PDF, Brisbane RubyUG 2007, John Jeffery)' => 'http://files.meetup.com/280030/Introduction%20to%20Camping.pdf',
          '(PRE-2) Polzr.goes :Camping (2007)' => 'http://polzr.blogspot.co.uk/',
        }
        makelist(links_u)

      end

      # The 'databases' partial view:
      def databases
      
        @str = "databases and deployment"
        h1 'Camping: ' + @str

        h2 'Resources for Camping and databases:'
        p { "Lots of choice, SQLite is the default, Active Record the default " + dfn("ORM", :title => "Object-Relational Mapper (SQL-free database interface)") + "." }
        links_d = {
          'CouchCamping (gem) CouchDB as the database layer in Camping!' => 'https://www.ruby-toolbox.com/gems/CouchCamping',
          'chill plugs ruby code in to CouchDB (Bluebie)' => 'https://github.com/Bluebie/chill',
          'Camping with CouchDB (Knut Hellan)' => 'http://knuthellan.com/2009/03/08/camping-with-couchdb/',
          'Going Camping with CouchDB On OS X Tiger (Tim Gittos)' => 'http://www.timgittos.com/archives/going-camping-with-couchdb-on-os-x-tiger/',
          'Camping::Kirbybase a gem for using Kirbybase with Camping (Isak Andersson)' => 'https://github.com/MilkshakePanda/camping-kirbybase',
          '(PRE-2) Camping and mysql (from Snax)' => 'http://blog.evanweaver.com/articles/2006/09/17/make-camping-connect-to-mysql/',
        }
        makelist(links_d)

        h2 'Camping deployment:'
        p { "Servers, hosting" }
        links_d = {
          'Running Camping apps on Heroku' => 'http://radiant-sunset-95.heroku.com/how-to-run-camping-2-apps-on-heroku',
          'Set up your Camping app to run on Dreamhost' => 'http://wiki.dreamhost.com/Camping',
          'Camping 2.0 on cgi/fcgi' => 'http://pastie.org/237138', #http://osdir.com/ml/lang.ruby.camping.general/2008-07/msg00029.html
          'Blog example on Heroku' => 'http://radiant-sunset-95.heroku.com',
          'Original post re Camping\'s move to Rack' => 'http://www.mail-archive.com/camping-list@rubyforge.org/msg00764.html',
          '(PRE 2) Ruby + Thin + Camping: Serving static files with Thin vs. Camping’s work around' => 'http://www.eleven33.com/2009/03/ruby-thin-camping-serving-static-files-with-thin-vs-campings-work-around/',
        }
        makelist(links_d)
        
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
  background:#1d1410 url(soil.gif);
  color:#444;
}
.container {
  width:80%;
  margin:1.24em auto 0px;
  padding:10px;
  border:1px solid #8b8;
  background:rgba(240,240,240,0.8) url(camping_bg.gif) 50% 48px no-repeat;
  border-radius:10px;
}
#menu {
  list-style-type:none;
  text-align:center;
  margin-top:-2em;
}
#menu li {
  display:inline-block;
  width:33%;
  text-align:center;
  margin:0 4px 4px;
}
#menu > li {
  margin-left:0;
}
#menu li a {
  display:block;
  line-height:2em;
  color:#ccc;
  background:rgba(56, 37, 30, 0.90);
/*  background:rgba(68, 119, 68, 0.85);*/
  text-decoration:none;
  padding:0em 2px;
  letter-spacing:1px;
  border-bottom-right-radius: 6px;
  border-bottom-left-radius: 6px;
  -webkit-transition-property:all;
  -moz-transition-property:all;
  -ms-transition-property:all;
  -o-transition-property:all;
  transition-property:all;
  -webkit-transition-duration:1s;
  -moz-transition-duration:1s;
  -ms-transition-duration:1s;
  -o-transition-duration:1s;
  transition-duration:1s;
}
#menu li a:hover {
  background:rgba(68, 119, 68, 1);
  box-shadow: 0px 2px 0px rgba(20, 20, 20, 0.5);
  color:#fefefe;
  text-shadow: 0px 2px 0px rgba(20, 20, 20, 0.5);
}
#menu li a.here {
  
}
h1, h2 {
  color:#363;
  text-shadow: 1px 1px 1px rgba(100, 100, 100, 0.6);
}
h1 {
  margin:0.25em 0 0.25em;
  font-size:2em;
  text-align:center;
}
h2 {
  font-size:1.2em;
  padding:0 0.25em 0.2em 0;
  margin:0.5em 0;
  border-top:2px solid rgba(100, 100, 100, 0.2);
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
.emph {
  font-weight:bold;
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
dfn {
  border-bottom:1px dotted #666;
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
  padding:1em 0.25em;
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