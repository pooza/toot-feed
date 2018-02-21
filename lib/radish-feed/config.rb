require 'yaml'
require 'singleton'

module RadishFeed
  class Config < Hash
    include Singleton

    def initialize
      super
      Dir.glob(File.join(ROOT_DIR, 'config', '*.yaml')).each do |f|
        self[File.basename(f, '.yaml')] = YAML.load_file(f)
      end
      self['db'] ||= {
        'host' => 'localhost',
        'user' => 'postgres',
        'password' => '',
        'dbname' =>'mastodon',
        'port' => 5432,
      }
      self['local'] ||= {}
      self['local']['entries'] ||= {'default' => 50, 'max' => 200}
    end
  end
end
