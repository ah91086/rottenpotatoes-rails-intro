class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # session.clear

    @test  = true
    @all_ratings = Movie.get_ratings
    shouldInclude = []
    retrievedHash = params["ratings"]

    if !session.key?(:first_iteration_passed)
      session[:first_iteration_passed] = true
      session[:filterSettings] =  @all_ratings
      session[:orderByHeader] = false
      session[:orderByDate] = false
    end

    
    shouldInclude = []
    retrievedHash = params["ratings"]


    retrievedHash = params["ratings"]
    if retrievedHash == nil ||  retrievedHash.length == 0
      shouldInclude = session[:filterSettings]
    else

      for rating in @all_ratings do 
        if retrievedHash.key?(rating)
          shouldInclude.push(rating)
        end
      end

      session[:filterSettings] = shouldInclude

    end


    @movie_title_yellow = false
    @release_date_yellow = false


    if params.length == 0
      redirect_to "ratings"=>shouldInclude
    elsif params[:orderByHeader] and params["ratings"]
      @movie_title_yellow = true
      @movies = Movie.with_ratings(params["ratings"].keys, :title)
    elsif params[:orderByDate] and params["ratings"]
      @release_date_yellow = true
      @movies = Movie.with_ratings(params["ratings"].keys, :release_date)
    else
      if params[:orderByHeader]

        session[:orderByHeader] = true
        session[:orderByDate] = false


        if shouldInclude.length != @all_ratings.length

          ratingsHash = Hash.new
          for r in shouldInclude do
            ratingsHash[r] = "true"
          end

          redirect_to "ratings"=>ratingsHash,  "orderByHeader"=>"true"
        else

          @movies = Movie.order(:title)
          @movie_title_yellow = true
        end 

      elsif params[:orderByDate] 

        session[:orderByDate] = true
        session[:orderByHeader] = false

        if shouldInclude.length != @all_ratings.length

          ratingsHash = Hash.new
          for r in shouldInclude do
            ratingsHash[r] = "true"
          end

          redirect_to "ratings"=>ratingsHash, "orderByDate"=>"true"

        else

          @movies = Movie.order(:release_date)
          @release_date_yellow = true
        end

      else
        
        if session[:orderByDate] || session[:orderByHeader]
          if shouldInclude.length != @all_ratings.length

            ratingsHash = Hash.new
            for r in shouldInclude do
              ratingsHash[r] = "true"
            end

            if session[:orderByDate]
              redirect_to "ratings"=>ratingsHash, "orderByDate"=>"true"
            else
              redirect_to "ratings"=>ratingsHash, "orderByHeader"=>"true"
            end

          else
            if session[:orderByDate]
              @movies = Movie.order(:release_date)
            else
              @movies = Movie.order(:title)
            end
          end
        else
          @movies = Movie.with_ratings(shouldInclude, nil)
        end
      end
    end
  end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
