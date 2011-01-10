# -*- encoding: utf-8 -*-

include_files = ["README", "MIT-LICENSE", "Rakefile", "init.rb", "{lib,tasks,spec,features,rails}/**/*"].map do |glob|
  Dir[glob]
end.flatten

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'copycopter_client/version'

Gem::Specification.new do |s|
  s.name = "copycopter_client"
  s.version = CopycopterClient::VERSION
  s.authors = ["thoughtbot"]
  s.date = "2010-06-04"
  s.email = "support@thoughtbot.com"
  s.extra_rdoc_files = ["README.textile"]
  s.files = include_files
  s.homepage = "http://github.com/thoughtbot/copycopter_client"
  s.rdoc_options = ["--line-numbers", "--main"]
  s.require_path = "lib"
  s.rubyforge_project = "copycopter_client"
  s.rubygems_version = "1.3.5"
  s.summary = "Client for the Copycopter content management service"

  s.add_dependency 'i18n', '~> 0.5.0'
  s.add_dependency 'json'
end
