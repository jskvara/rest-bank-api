require 'net/http'
require_relative 'bankapi_error'

class Downloader
	CURRENCY_URL = "http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt"
	CURRENCY_FILE = "temp/currencies"

	def self.download(url)
		uri = URI(url)
		# uri.query = URI.encode_www_form({ :limit => 10, :page => 3 })

		res = Net::HTTP.get_response(uri)
		res.body if res.is_a?(Net::HTTPSuccess)
	end

	def self.get_currencies
		last_modified, currencies = load_currencies
		if currencies != nil and last_modified != nil and last_modified.day == Time.now.day
			return currencies
		end

		currencies_txt = download(CURRENCY_URL)
		currencies = currencies_to_hash(currencies_txt)
		save_currencies(currencies)

		currencies
	end

	protected
	def self.currencies_to_hash(currencies_txt)
		currencies = {}
		currencies_txt.each_line.with_index { |line, lineno|
			next if lineno == 0 or lineno == 1
			line_arr = line.split("|")
			currency = line_arr[3].upcase
			course = line_arr[4].gsub(",", ".").to_f
			course = course / line_arr[2].to_f
			currencies[currency] = course
		}
		currencies
	end

	def self.save_currencies(currencies)
		File.open(CURRENCY_FILE, "wb") {|f|
			Marshal.dump(currencies, f)
		}
	end

	def self.load_currencies
		begin
			currencies = nil
			last_modified = File.mtime(CURRENCY_FILE)
			File.open(CURRENCY_FILE, "rb") {|f| 
				currencies = Marshal.load(f)
			}
		rescue Exception => msg
			$stderr.print msg
		end
		[last_modified, currencies]
	end
end