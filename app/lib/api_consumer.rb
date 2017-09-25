# encoding: utf-8

class ApiConsumer
  require 'net/http'
  require 'json'

  def initialize
  end

  def mampf(ids)
    res = {}
    base_url = "https://mampf-dev.mathi.uni-heidelberg.de/api/v1/keks_questions/%s?width=640"
    ids.each do |id|
      url = base_url % [id]
      uri = URI(url)
      response = Net::HTTP.get(uri)
      j = JSON.parse(response)
      t = {}
      t['video_file_link'] = j["medium"]["video_file_link"]
      t['width'] = j["medium"]["width"]
      t['height'] = j["medium"]["height"]
      t['embedded_video'] = j['embedded_video'].empty? ? nil : j['embedded_video']
      res[id] = t
    end

    res
  end
end
