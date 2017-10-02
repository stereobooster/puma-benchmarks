require 'bcrypt'
require 'net/http'
require 'uri'
require 'rack'
require 'logger'

def simulate(path)
  case path.gsub('/unicorn/', '').gsub('/puma/', '').gsub('/puma-sock/', '')
  when 'cpu'
    BCrypt::Password.create("my password #{rand}")
  when 'io'
    begin
      uri = URI.parse('http://exmaple.com/')
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      response.body
    rescue
      'Timeout'
    end
  when 'gc'
    x = rand(20_000)
    (0..20_000).map(&:to_s).reduce(:+)[x, x + 10]
  when 'sleep'
    sleep(0.5)
  when 'random'
    simulate(%w(cpu io gc sleep).sample)
  else
    ''
  end
end

logger = Logger.new($stdout)
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.to_f.round(3)},#{msg}\n"
end

app = Proc.new do |env|
  began_at = Time.now.to_f
  body = simulate(env['REQUEST_PATH'])
  end_at = Time.now.to_f
  request_latency = ((began_at - env['HTTP_X_REQUEST_START'].to_f) * 1000).round(3)
  request_duration = (end_at - began_at).round(3)
  logger.info("#{request_duration},#{request_latency}")
  body = "#{request_duration}; #{body}"
  headers = { 'Content-Type' => 'text/plain', 'Content-Length' => body.length.to_s }
  [200, headers, [body]]
end

run app
