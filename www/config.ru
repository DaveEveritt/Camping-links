$LOAD_PATH << File.dirname(Pathname.new(File.expand_path(__FILE__)).realpath.to_s).to_s
require 'camplinks.rb'
run Camplinks