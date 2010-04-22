require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'

Hoe.plugin :newgem

$hoe = Hoe.spec 'reittiopas' do
  developer 'Raine Virta', 'raine.virta@gmail.com'
  self.rubyforge_name = self.name

  %w{ addressable nokogiri }.each do |dep|
    self.extra_deps << [dep, '>= 0']
  end

  self.url              = "http://github.com/raneksi/reittiopas"
  self.extra_dev_deps   = [
    ['webmock', ">= 0.9.1"],
    ['rspec', ">= 0"]
  ]
  self.readme_file      = "README.rdoc"
  self.extra_rdoc_files = FileList['*.rdoc']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
