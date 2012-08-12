require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem

$hoe = Hoe.spec 'reittiopas' do
  developer 'Raine Virta', 'raine.virta@gmail.com'
  self.rubyforge_name = self.name

  self.extra_deps = [
    [ 'addressable', '= 2.2.8' ],
    [ 'nokogiri', '>= 0']
  ]

  self.urls             = ["http://github.com/raneksi/reittiopas"]
  self.extra_dev_deps   = [
    ['webmock', "= 1.8.8"],
    ['rspec', "= 2.11.0"],
    ['darkfish-rdoc', ">= 0"]
  ]
  self.readme_file      = "README.md"
  self.extra_rdoc_files = FileList['*.rdoc']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
