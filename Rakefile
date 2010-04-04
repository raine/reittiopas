require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/reittiopas'

Hoe.plugin :newgem

$hoe = Hoe.spec 'reittiopas' do
  developer 'Raine Virta', 'raine.virta@gmail.com'
  self.rubyforge_name   = self.name

  %w{ addressable nokogiri }.each do |dep|
    self.extra_dev_deps << [dep, '>= 0']
  end

  self.url              = "http://github.com/raneksi/reittiopas"
  self.extra_dev_deps   = [['webmock', ">= 0"]]
  self.readme_file      = "README.rdoc"
  self.extra_rdoc_files = FileList['*.rdoc']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# remove_task :default
# task :default => [:spec, :features]

require 'gokdok'
Gokdok::Dokker.new do |gd|
  gd.repo_url  = "git@github.com:raneksi/reittiopas.git"
  gd.rdoc_task = :docs
  gd.doc_home  = 'doc'
end
