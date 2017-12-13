require 'pg'
require 'radish-feed/config'

module RadishFeed
  class Postgres
    def initialize
      @config = Config.new
      @db = PG::connect({
        host: @config['db']['host'],
        user: @config['db']['user'],
        password: @config['db']['password'],
        dbname: @config['db']['dbname'],
        port: @config['db']['port'],
      })
    end

    def execute (name, values = [])
      return @db.exec(@config['query'][name], values).to_a
    end
  end
end