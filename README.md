# FFXIV

An unofficial Ruby toolkit for Final Fantasy XIV: A Realm Reborn, featuring Lodestone scraper.

## Installation

```
$ gem install ffxiv
```

## Usage

Currently there are three flavors of Lodestone scrapers - [Character](lib/ffxiv/lodestone/character.rb), [FreeCompany](lib/ffxiv/lodestone/free-company.rb), and [Linkshell](lib/ffxiv/lodestone/linkshell.rb).

Each class is designed to be somewhat similar to ActiveModel in Rails where class methods handle aggregate opeartions such as search, and each instance represents a single model (i.e. character, free company, or linkshell).

### Basics

If you know the ID of the cahracter you want to fetch:

```
ch = FFXIV::Lodestone::Character.find_by_id(id)
```

If you know the name and the server of this character is on:

```
ch = FFXIV::Lodestone::Character.find_by_name(name, server)
# name must be a full name.
```

Either method returns an instance of FFXIV::Lodestone::Character or nil if not found.
Note that searching by ID is always faster than searching by name.

Same is true for FreeCompany and Linkshell:

```
# FreeCompany
fc = FFXIV::Lodestone::FreeCompany.find_by_id(id)
fc = FFXIV::Lodestone::FreeCompany.find_by_name(name, server)

# Linkshell
ls = FFXIV::Lodestone::Linkshell.find_by_id(id)
ls = FFXIV::Lodestone::Linkshell.find_by_name(name, server)
```

### Character

Some interesting methods:
```
ch = FFXIV::Lodestone::Character.find_by_name('Syro Bonkus', 'Chocobo')

# Free Company this character belongs to:
# Note that this FreeCompany instance is populated for only the fields that are shown on the character's page (i.e. name, server)
fc = ch.free_company

# If you want a fully populated FreeCompany instance, pass true as the first arugment:
full_fc = ch.free_company(true)

# Number of blogs to date:
puts ch.num_blogs

# Daily frequency of blogging:
ch.bpd

# Blogs this character has published (only the public posts):
blogs = ch.blogs

# If you want to fetch all of the blog comments, then pass true as the first argument:
blogs_with_comments = ch.blogs(true)

# Note that #blogs() can be very costly, depending on the number of the blogs and blog comments this character has. Use it wisely.


```

## Contributing

This is a one-man project I have started to make my life in Eorzea a little better.
Current focus is on scraping the [Lodestone website](http://na.finalfantasyxiv.com/lodestone/).
Feel free to submit issues, suggestions, and/or pull requests! ;)

## License

Distributed under the [MIT License](LICENSE).

## Credits

FINAL FANTASY XIV is a registered trademark of Square Enix Holdings Co., Ltd. A REALM REBORN is a trademark of Square Enix Co., Ltd.
