# OBSOLETE – have to fix, do manually until that
# namespace :docs do
#   desc "Publish rdoc to Github pages"
#   task :publish => "docs" do
#     sh 'cp doc/README_rdoc.html doc/index.html'
#     sh 'cp -R doc/* .gh_pages/'
#     sh 'cd .gh_pages; git add .; git commit -m "Update docs"; git push origin gh-pages'
#   end
# end
