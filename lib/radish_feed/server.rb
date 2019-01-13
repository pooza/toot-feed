module RadishFeed
  class Server < Ginseng::Sinatra
    include Package

    get '/feed/v1.1/account/:account' do
      unless registered?(params[:account])
        raise Ginseng::NotFoundError, "Account #{params[:account]} not found."
      end
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
      site = {}
      Postgres.instance.execute('site').each do |row|
        site[row['var']] = YAML.safe_load(row['value'])
      end
      return site
    end

    def default_renderer_class
      return 'Ginseng::XMLRenderer'
    end

    not_found do
      @renderer = Ginseng::XMLRenderer.new
      @renderer.status = 404
      @renderer.message = "Resource #{request.path} not found."
      return @renderer.to_s
    end

    error do |e|
      e = Ginseng::Error.create(e)
      @renderer = Ginseng::XMLRenderer.new
      @renderer.status = e.status
      @renderer.message = "#{e.class}: #{e.message}"
      Slack.broadcast(e.to_h)
      @logger.error(e.to_h)
      return @renderer.to_s
    end

    private

    def registered?(account)
      return !Postgres.instance.execute('registered', {account: account}).empty?
    end
  end
end
