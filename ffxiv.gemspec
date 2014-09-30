Gem::Specification.new do |s|
  s.name        = "ffxiv"
  s.version     = "0.9.1"
  s.date        = "2014-09-29"
  s.summary     = "An unofficial FFXIV ARR toolkit for Ruby, featuring Lodestone scraper."
  s.description = "An unofficial FFXIV ARR toolkit for Ruby, featuring Lodestone scraper."
  s.authors     = ["Isjaki Kveikur"]
  s.email       = ["isjaki.xiv@gmail.com"]
  s.files       = ["lib/ffxiv.rb",
                   "lib/ffxiv/lodestone.rb",
                   "lib/ffxiv/lodestone/model.rb",
                   "lib/ffxiv/lodestone/character.rb",
                   "lib/ffxiv/lodestone/free-company.rb"]
  s.homepage    = "https://github.com/ffxiv/ffxiv"
  s.license     = "MIT"
end