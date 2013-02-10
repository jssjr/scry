namespace :scry do
  task :view do
    Scry.init
    Scry::Printer.print
  end
end

desc "Scry the available configuration sources and view thew results"
task :scry => ['scry:view']
