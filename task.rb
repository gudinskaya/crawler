require 'nokogiri'
require 'open-uri'
require 'curb'
require 'csv'
puts "Enter the url of category"
url = gets
puts "Enter the file name"
file = gets
# file = "/data/out.csv"
# 'https://www.petsonic.com/pienso-para-perros/'
# url.to_s
# https://www.petsonic.com/snacks-huesos-para-perros/?categorias=huesos-para-perro
flag = true
incr = 1
# url = 'https://www.petsonic.com/snacks-huesos-para-perros/'
symbol = '?p='
      # 'test.csv'
  CSV.open(file.strip,'w', :write_headers=> true, :headers => ["Name", "Price", "Image"]) do|csv|
        while(flag)
          # unless incr < 2 
          #   page = symbol.concat(incr.to_s)
          #   c = Curl::Easy.new(url.strip.concat(page))
          #   c.follow_location = false
          #   c.on_redirect do |easy, code|
          #     flag = false
          #   end
          #   c.perform
          #   if !flag
          #     break
          #   end
          #   document = Nokogiri::HTML(c.body_str)
          # else
          #   document = Nokogiri::HTML(Curl.get(url.strip).body_str)
          # end
          pageURL = url.strip
          page = ""
          if incr > 1
            page = symbol.concat(incr.to_s)
            pageURL += page
          end
          c = Curl::Easy.new(url.strip.concat(page))
          c.follow_location = false
          c.on_redirect do |easy, code|
            flag = false
          end
          c.perform
          if !flag
            break
          end
          document = Nokogiri::HTML(c.body_str)
          puts "\n///////////Next page //////////\n"
          puts(incr)
            
          tags = document.xpath('//a[contains(@class, "name")]')
          tags.each do |tag|
            document1 = Nokogiri::HTML(Curl.get("#{tag[:href]}").body_str)
            image = document1.xpath('//img[contains(@id, "bigpic")]/@src')
            name = document1.xpath('//h1[contains(@class, "name")]/text()')
            prices = document1.xpath('//span[@class = "price_comb"]/text()')
            puts "Parsing product page..."
            unless prices.length < 2
              tagWeight = document1.xpath('//span[@class = "radio_label"]/text()') 
              arrWeight = Array.new
              arrPrice = Array.new
              tagWeight.each do |weight|
                arrWeight.push(weight)
              end
              prices.each do |price|
                arrPrice.push(price)
              end
              for i in 0..prices.length-1
                csv << ["#{name}#{arrWeight.at(i)}".strip, "#{arrPrice.at(i)}", "#{image}" ]
                csv.fsync()
              end
            else
              if "#{name}".strip.length != 0
                csv << ["#{name}".strip, "#{prices}", "#{image}"]
                csv.fsync()
              end
            end
            puts "Writing info about product to file...\n\n"
          end
          incr = incr+1
        end
        puts "DONE"
  end

