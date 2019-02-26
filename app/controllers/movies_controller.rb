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


    # if @first_iteration
    #   @first_iteration = false
    #   session[:filterSettings] = 

    # session[:filterSettings]







    #we set the default value of check boxes to checked but idk if thats reflected in the retrievedHash

    retrievedHash = params["ratings"]
    if retrievedHash == nil ||  retrievedHash.length == 0
      shouldInclude = session[:filterSettings]
    else
      # if retrievedHash != nil

      for rating in @all_ratings do 
        if retrievedHash.key?(rating)
          shouldInclude.push(rating)
        end
      end


      # end

      session[:filterSettings] = shouldInclude

    end










    @movie_title_yellow = false
    @release_date_yellow = false

    # if @first_iteration
    #   @first_iteration = false
    #   shouldInclude = Movie.get_ratings

    #   @movie_title_yellow = true
    #   @release_date_yellow = true
    # end

    # @movie_title_yellow = true
    # @release_date_yellow = true



    if params[:orderByHeader]
      session[:orderByHeader] = true
      session[:orderByDate] = false

      # @movies = Movie.order(:title)
      @movies = Movie.with_ratings(shouldInclude, :title)
      @movie_title_yellow = true
    elsif params[:orderByDate] 
      # @movies = Movie.order(:release_date)
      session[:orderByDate] = true
      session[:orderByHeader] = false

      @movies = Movie.with_ratings(shouldInclude, :release_date)
      @release_date_yellow = true
    else
      @movies = Movie.with_ratings(shouldInclude, nil)
    end


    if session[:orderByHeader] 
      @movie_title_yellow = true
      @movies = Movie.with_ratings(shouldInclude, :title)
    end

    if session[:orderByDate]
      @release_date_yellow = true
      @movies = Movie.with_ratings(shouldInclude, :release_date)
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
