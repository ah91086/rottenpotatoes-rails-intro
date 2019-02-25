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
    @all_ratings = Movie.get_ratings
    shouldInclude = []
    retrievedHash = params["ratings"]
    if retrievedHash != nil
      for rating in @all_ratings do 
        if retrievedHash.key?(rating)
          shouldInclude.push(rating)
        end
      end
    end

    @movie_title_yellow = false
    @release_date_yellow = false

    if params[:orderByHeader]
      # @movies = Movie.order(:title)
      @movies = Movie.with_ratings(shouldInclude, :title)
      @movie_title_yellow = true
    elsif params[:orderByDate] 
      # @movies = Movie.order(:release_date)
      @movies = Movie.with_ratings(shouldInclude, :release_date)
      @release_date_yellow = true
    else
      @movies = Movie.with_ratings(shouldInclude, nil)
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
