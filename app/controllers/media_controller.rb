class MediaController < ApplicationController
  before_filter :load_collection

  def index
    @media = Media.all - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == Media.uncategorized
        @fandom_listing[medium] = medium.fandoms.find(:all, :order => 'created_at DESC', :limit => 5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ? medium.fandoms.unhidden_top(5).find(:all, :conditions => {:canonical => true}) : medium.fandoms.public_top(5).find(:all, :conditions => {:canonical => true})
      end
    end
  end

  def show
    medium = Media.find_by_name(params[:id])
    @medium_name = medium.name
    
    if medium == Media.uncategorized
      @media_alphabet = medium.fandoms.collect {|fandom| fandom.name[0,1].upcase}.uniq.sort
    else
      @media_alphabet = medium.fandoms.canonical.select{|f| f.visible_synonyms_works_count > 0}.collect {|fandom| fandom.name[0,1].upcase}.uniq.sort
    end

    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = @media_alphabet[0]
    end
    
    if medium == Media.uncategorized
      @fandoms = medium.fandoms.starting_with(letter)  # add .select{|f| f.visible_synonyms_works_count > 0} if you want to hide fandoms that won't show any works to current visitor/user
    else
      @fandoms = medium.fandoms.canonical.starting_with(letter).select{|f| f.visible_synonyms_works_count > 0} #.paginate(:page => params[:page])
    end
  end
end
