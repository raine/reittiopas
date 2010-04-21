require 'rubygems'
require 'bundler'
Bundler.setup

require 'hoe'
require 'fileutils'
require './lib/reittiopas'

Hoe.plugin :newgem

$hoe = Hoe.spec 'reittiopas' do
  developer 'Raine Virta', 'raine.virta@gmail.com'
  self.rubyforge_name = self.name

  %w{ addressable nokogiri }.each do |dep|
    self.extra_dev_deps << [dep, '>= 0']
  end

  self.url              = "http://github.com/raneksi/reittiopas"
  self.extra_dev_deps   = [['webmock', ">= 0.9.1"]]
  self.readme_file      = "README.rdoc"
  self.extra_rdoc_files = FileList['*.rdoc']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# For some reason this is required or bundler's gems won't be available
# in specs, TODO until I find some project using bundler + spec that
# does this correctly
ENV["GEM_PATH"] = nil
