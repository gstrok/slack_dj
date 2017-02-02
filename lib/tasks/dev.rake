
include Amatch

if Rails.env.development? || Rails.env.test? # we may want to seed the test db as well.
  namespace :dev do
    desc "Seed data for development environment"
    task prime: "db:setup" do
      Video.create!(url: "https://www.youtube.com/watch?v=SIQihN--98Y")
      Video.create!(url: "https://www.youtube.com/watch?v=Y1PVmANeyAg")
      Video.create!(url: "https://www.youtube.com/watch?v=Zk0ClOGHoXc")
    end

    desc "Test fetching related video"
    task :test_related => :environment do
      Yt.configure do |config|
        config.api_key = ENV.fetch('YOUTUBE_ACCESS_TOKEN')
        config.log_level = :debug if Rails.env.development?
      end
      recent = Video.recently_played.pluck(:youtube_id) || []
      search = Yt::Collections::Videos.new
      videoId = "iy4mXZN1Zzk"
      videoTitle = "Robbie Williams - Feel"
      related = search.where( relatedToVideoId: videoId, order: "viewCount", max_results: 20 )
      if related.present?
        filtered = related.select do |r|
          recent.exclude? r.id
        end
        m = JaroWinkler.new(videoTitle)
        matches = filtered.map do | video |
          { :video_title => video.title, :video_id => video.id, :score => m.match(video.title) }
        end
        best_fit = matches.min_by{|vid| vid[:score]}
        puts best_fit
      end
    end

  end
end
