class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :search]

  def home
  end

  def dashboard
    @company = current_user.company
    @jobs = Job.where(company: @company)
    @jobs = @jobs.sort_by { |job| job.created_at }.reverse
    @applications = Application.where(developer: current_user.developer)
    @applications = @applications.sort_by { |application| application.created_at }.reverse
    @developer = current_user.developer
    @developer_jobs = []
    Application.where(status:'accepted', developer: @developer).each do |application|
      @developer_jobs << application.job
    end
    @developer_jobs = @developer_jobs.sort_by { |job| job.created_at }.reverse
    @developers = []
    Application.where(status:'accepted', job: @jobs).each do |application|
      @developers << application.developer
      @developers.flatten
    end
    @developers = @developers.sort_by { |developer| developer.created_at }.reverse
    @received_applications = []
    @jobs.each do |job|
      job.applications.each do |application|
        @received_applications << application if application.status == 'pending'
      end
    end
    @received_applications = @received_applications.sort_by { |application| application.created_at }.reverse
  end

  def search
    if params[:search_type] == 'dev_location'
      if params[:query].blank?
        @results = Developer.all
      else
        @results = Developer.search_dev_by_location(params[:query])
      end
    elsif params[:search_type] == 'company_location'
      if params[:query].blank?
        @results = Company.all
      else
        @results = Company.search_companies_by_location(params[:query])
      end
    elsif params[:search_type] == 'Developers'
      if params[:query].blank?
        @results = Developer.all
      else
        @results = Developer.search_all_developers(params[:query])
      end
    elsif params[:search_type] == 'Companies'
      if params[:query].blank?
        @results = Company.all
      else
        @results = Company.search_all_companies(params[:query])
      end
    elsif params[:search_type] == 'dev_interests'
      if params[:query].blank?
        @results = Developer.all
      else
        @results = Developer.search_dev_by_interests(params[:query])
      end
    elsif params[:search_type] == 'company_mission'
      if params[:query].blank?
        @results = Company.all
      else
        @results = Company.search_companies_by_mission(params[:query])
      end
    elsif params[:search_type] == 'Jobs'
      if params[:query].blank?
        @results = filter_active_jobs(Job.all)
      else
        @results = filter_active_jobs(Job.search_all_jobs(params[:query]))
      end

    else
      @results = Developer.all
    end
    serp_headline
  end

  def serp_headline
    if params[:search_type] == 'Companies'
      @serp_headline = serp_headline_helper('company')
    elsif params[:search_type] == 'Jobs'
      @serp_headline = serp_headline_helper('jobs')
    elsif params[:search_type] == 'company_location'
      @serp_headline = serp_headline_helper('company')
    elsif params[:search_type] == 'company_mission'
      @serp_headline = serp_headline_helper('company')
    else
      @serp_headline = serp_headline_helper('developer')
    end
  end

  def filter_active_jobs(results)
    results.select { |result| result.active}
  end

  private

  def serp_headline_helper(term)
    term = ActionController::Base.helpers.pluralize(@results.size, term)
    if params[:query] == ""
      return "All #{term}"
    else
      return "#{term} matching '#{params[:query]}'"
    end
  end
end
