FROM ruby:latest

RUN gem install nokogiri curb csv

ADD task.rb /task.rb

CMD ["ruby", "task.rb"]
