require 'bcrypt'
require 'net/http'
require 'uri'
require 'rack'

def simulate(path)
  case path.gsub('/unicorn/', '').gsub('/puma/', '').gsub('/puma-sock/', '')
  when 'cpu'
    BCrypt::Password.create("my password #{rand}")
  when 'io'
    uri = URI.parse('http://google.com/')
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    response.body
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

app = Proc.new do |env|
  t1 = Time.now.to_f
  body = simulate(env['REQUEST_PATH'])
  t2 = Time.now.to_f
  body = "#{(t2 - t1).round(3)}; #{body}"
  headers = { 'Content-Type' => 'text/plain', 'Content-Length' => body.length.to_s }
  [200, headers, [body]]
end

run app
