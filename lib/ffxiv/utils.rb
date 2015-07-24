$:.unshift File.dirname(__FILE__)

module FFXIV
  module Utils

    @@eorzean_months = {
      "1st Astral Moon" => 1,
      "1st Umbral Moon" => 2,
      "2nd Astral Moon" => 3,
      "2nd Umbral Moon" => 4,
      "3rd Astral Moon" => 5,
      "3rd Umbral Moon" => 6,
      "4th Astral Moon" => 7,
      "4th Umbral Moon" => 8,
      "5th Astral Moon" => 9,
      "5th Umbral Moon" => 10,
      "6th Astral Moon" => 11,
      "6th Umbral Moon" => 12
    }

    @@eorzean_days = {
      "1st Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31},
      "1st Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 7, 9 => 8, 10 => 9, 11 => 10, 12 => 11, 13 => 12, 14 => 13, 15 => 14, 16 => 14, 17 => 15, 18 => 16, 19 => 17, 20 => 18, 21 => 19, 22 => 20, 23 => 21, 24 => 21, 25 => 22, 26 => 23, 27 => 24, 28 => 25, 29 => 26, 30 => 27, 31 => 28, 32 => 29},
      "2nd Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31},
      "2nd Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 7, 9 => 8, 10 => 9, 11 => 10, 12 => 11, 13 => 12, 14 => 13, 15 => 14, 16 => 15, 17 => 16, 18 => 17, 19 => 18, 20 => 19, 21 => 20, 22 => 21, 23 => 22, 24 => 23, 25 => 24, 26 => 25, 27 => 26, 28 => 27, 29 => 28, 30 => 28, 31 => 29, 32 => 30},
      "3rd Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 29, 30 => 29, 31 => 30, 32 => 31},
      "3rd Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 7, 9 => 8, 10 => 9, 11 => 10, 12 => 11, 13 => 12, 14 => 13, 15 => 14, 16 => 15, 17 => 16, 18 => 17, 19 => 18, 20 => 19, 21 => 20, 22 => 21, 23 => 22, 24 => 23, 25 => 24, 26 => 25, 27 => 26, 28 => 27, 29 => 28, 30 => 28, 31 => 29, 32 => 30},
      "4th Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31},
      "4th Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31},
      "5th Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 7, 9 => 8, 10 => 9, 11 => 10, 12 => 11, 13 => 12, 14 => 13, 15 => 14, 16 => 15, 17 => 16, 18 => 17, 19 => 18, 20 => 19, 21 => 20, 22 => 21, 23 => 22, 24 => 23, 25 => 24, 26 => 25, 27 => 26, 28 => 27, 29 => 28, 30 => 28, 31 => 29, 32 => 30},
      "5th Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31},
      "6th Astral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 7, 9 => 8, 10 => 9, 11 => 10, 12 => 11, 13 => 12, 14 => 13, 15 => 14, 16 => 15, 17 => 16, 18 => 17, 19 => 18, 20 => 19, 21 => 20, 22 => 21, 23 => 22, 24 => 23, 25 => 24, 26 => 25, 27 => 26, 28 => 27, 29 => 28, 30 => 28, 31 => 29, 32 => 30},
      "6th Umbral Moon" => {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10, 11 => 11, 12 => 12, 13 => 13, 14 => 14, 15 => 15, 16 => 16, 17 => 17, 18 => 18, 19 => 19, 20 => 20, 21 => 21, 22 => 22, 23 => 23, 24 => 24, 25 => 25, 26 => 26, 27 => 27, 28 => 28, 29 => 28, 30 => 29, 31 => 30, 32 => 31}
    }

    @@servers = {
      "Elemental" => %w{Aegis Atomos Carbuncle Garuda Gungnir Kujata Ramuh Tonberry Typhon Unicorn},
      "Gaia" => %w{Alexander Bahamut Durandal Fenrir Ifrit Ridill Tiamat Ultima Valefor Yojimbo Zeromus},
      "Mana" => %w{Anima Asura Belias Chocobo Hades Ixion Mandragora Masamune Pandaemonium Shinryu Titan},
      "Aether" => %w{Adamantoise Balmung Cactuar Coeurl Faerie Gilgamesh Goblin Jenova Mateus Midgardsormr Sargatanas Siren Zalera},
      "Primal" => %w{Behemoth Brynhildr Diabolos Excalibur Exodus Famfrit Hyperion Lamia Leviathan Malboro Ultros},
      "Chaos" => %w{Cerberus Lich Moogle Odin Phoenix Ragnarok Shiva Zodiark}
    }

    class << self

      def ed2gd(ed)
        partials = ed.match(/^(\d+).+([1-6].*)$/)
        # Wanted to use 2013 as year, but 2013 is not a leap year, resulting in invalid format error on deriving a birthday if nameday is "32st Sun of the 1st Umbral Moon".
        # Use the closest year here since year value is not relevant anyways.
        Date.new(2012, @@eorzean_months[partials[2]], @@eorzean_days[partials[2]][partials[1].to_i])
      end

      def servers
        @@servers
      end

      def data_center(server)
        self.servers.each do |dc, srvs|
          return dc if srvs.include? server
        end
      end

    end
  end
end