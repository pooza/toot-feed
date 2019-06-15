module RadishFeed
  class Server < Ginseng::Web::Sinatra
    include Package

    get '/feed/v1.1/account/:account' do
      if registered?(params[:account])
        @renderer = ATOMRenderer.new
        @renderer.tweetable = true
        @renderer.tweetable = params[:tweetable]
        @renderer.title_length = params[:length]
        @renderer.actor_type = params[:actor_type]
        @renderer.hashtag = params[:hashtag]
        @renderer.ignore_cw = params[:ignore_cw]
        @renderer.attachments = params[:attachments]
        @renderer.visibility = params[:visibility]
        @renderer.query = 'account_timeline'
        @renderer.params = {account: params[:account], entries: params[:entries]}
      else
        @renderer.status = 404
        @renderer.message = "Resource #{request.path} not found."
      end
      return @renderer.to_s
    end

    get '/feed/v1.1/local' do
      @renderer = ATOMRenderer.new
      @renderer.tweetable = params[:tweetable]
      @renderer.title_length = params[:length]
      @renderer.actor_type = params[:actor_type]
      @renderer.hashtag = params[:hashtag]
      @renderer.ignore_cw = params[:ignore_cw]
      @renderer.attachments = params[:attachments]
      @renderer.visibility = params[:visibility]
      @renderer.query = 'local_timeline'
      @renderer.params = {entries: params[:entries]}
      return @renderer.to_s
    end

    def self.site
      return Postgres.instance.execute('site').map do |row|
        [row['var'], YAML.safe_load(row['value'])]
      end.to_h
    end

    private

    def default_renderer_class
      return 'Ginseng::Web::XMLRenderer'.constantize
    end

    def registered?(account)
      return !Postgres.instance.execute('registered', {account: account}).empty?
    end
  end
end
