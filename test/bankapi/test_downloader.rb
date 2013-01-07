require 'test/unit'
require_relative '../../lib/bankapi/downloader'
  
class TestDownloader < Test::Unit::TestCase
	CURRENCY_URL = "http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt"

	def test_download
		currencies_txt = Downloader.download(CURRENCY_URL)
		assert_equal(36, currencies_txt.lines.count)
	end

	def test_get_currencies
		currencies = Downloader.get_currencies
		assert_equal(34, currencies.size)
	end
end