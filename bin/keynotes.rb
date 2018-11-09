require 'net/http'
require 'json'
require 'date'

def slug(string)
  string.downcase.gsub!(/[ äöüß]/) do |match|
    case match
    when 'ä' then 'ae'
    when 'ö' then 'oe'
    when 'ü' then 'ue'
    when 'ß' then 'ss'
    when ' ' then '_'
    end
  end
end

uri = URI('https://orga.hrx.events/en/thinkabout2019/public/events.json')
response = Net::HTTP.get(uri)
schedule = JSON.parse(response, symbolize_names: true)

talks = schedule[:conference_events][:events].select do |talk|
  talk[:type] == 'lecture'
end

talks.select { |t| t[:track].casecmp('keynote').zero? }.sort_by { |t| Date.parse(t[:start_time]) }.reverse.each do |talk|
  speaker = talk[:speakers][0]
  person = speaker[:full_public_name]
  person_slug = slug(person)
  link = speaker[:links].first
  url = link ? link[:url] : '#'
  company = link ? link[:title] : 'TODO'
  html = <<-HTML
          <section topic="#{talk[:track].downcase}">
            <h4>Keynote</h4>
            <article>
              <p>"#{talk[:title]}"</p>
              <hr/>
              <header>
                <div>
                  <h1>#{person}</h1>
                  <p><a href="#{url}">#{company}</a></p>
                </div><figure>
                  <img src="/assets/images/speaker/#{person_slug}.png" />
                </figure></header>
              </article>
          </section>
  HTML
  indentation = html.lines.first[/^ */].size
  puts html.lines.map { |l| l.gsub(/^ {#{indentation}}/, '') }.join
end
