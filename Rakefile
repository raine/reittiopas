require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem
Hoe.plugin :yard

$hoe = Hoe.spec 'reittiopas' do
  developer 'Raine Virta', 'raine.virta@gmail.com'
  self.rubyforge_name = self.name

  self.extra_deps = [
    [ 'addressable', '= 2.2.8' ],
    [ 'nokogiri', '>= 0']
  ]

  self.readme_file      = "README.md"
  self.urls             = ["http://github.com/raneksi/reittiopas"]
  self.extra_dev_deps   = [
    ['webmock', "= 1.8.8"],
    ['rspec', "= 2.11.0"],
    ['yard', ">= 0.8.2.1"],
    ['hoe-yard', ">= 0"]
  ]

  self.yard_title = 'Reittiopas (0.1.0)'
  self.yard_markup = "markdown"
  self.yard_opts = ['--protected']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
