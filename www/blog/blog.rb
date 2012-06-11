require 'camping'

Camping.goes :Blog

module Blog::Controllers
  class Index < R ''
    def get
      @time = Time.now
      render :sundial
    end
  end
end

module Blog::Views
  def layout
    html do
      head do
        title { "Blog placeholder: Nuts And GORP" }
        link :rel => 'stylesheet', :type => 'text/css', 
        :href => '/styles.css', :media => 'screen'
      end
      body { self << yield }
    end
  end

  def sundial
    h1 "Blog Placeholder"
    p :style => 'color: red' do
      text "The time and date are now: #{@time}"
    end
  end
end
__END__
@@/styles.css
body {font-family: 'Lucida Sans', sans-serif; color: #666;}