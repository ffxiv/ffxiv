Gem::Specification.new do |s|
  s.name        = "ffxiv"
  s.version     = "0.9.14"
  s.date        = "2015-06-10"
  s.summary     = "An unofficial FFXIV ARR toolkit for Ruby, featuring Lodestone scraper."
  s.description = "An unofficial Final Fantasy XIV / A Realm Reborn toolkit for Ruby, featuring Lodestone scraper."
  s.authors     = ["Syro Bonkus"]
  s.email       = ["sb.ffxiv@gmail.com"]
  s.files       = ["lib/ffxiv.rb",
                   "lib/ffxiv/utils.rb",
                   "lib/ffxiv/lodestone.rb",
                   "lib/ffxiv/lodestone/model.rb",
                   "lib/ffxiv/lodestone/character.rb",
                   "lib/ffxiv/lodestone/free-company.rb",
                   "lib/ffxiv/lodestone/linkshell.rb"]
  s.homepage    = "https://github.com/ffxiv/ffxiv"
  s.license     = "MIT"
  s.add_runtime_dependency "nokogiri", ">=1.5.0", "<1.7.0"
end
