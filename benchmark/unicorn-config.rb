worker_processes 16

working_directory '/vagrant/benchmark'

listen '/tmp/unicorn.sock', backlog: 1024
# listen '127.0.0.1:9292', tcp_nopush: true

timeout 60

logger  Logger.new('/dev/null')

stdout_path '/vagrant/report/time.log'
