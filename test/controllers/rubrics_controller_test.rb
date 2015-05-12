require 'test_helper'

class RubricsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super

    @me = FactoryGirl.create(:user, judging_region: 0)
    sign_in @me

    Setting.create!(key:'quarterfinalJudgingOpen', value: '2015-01-01')
    Setting.create!(key:'quarterfinalJudgingClose', value: '2015-01-10')
    Setting.create!(key:'semifinalJudgingOpen', value: '2015-01-13')
    Setting.create!(key:'semifinalJudgingClose', value: '2015-01-18')
    Setting.create!(key:'finalJudgingOpen', value: '2015-01-22')
    Setting.create!(key:'finalJudgingClose', value: '2015-01-24')

    @today = Setting.create!(key:'todaysDateForTesting', value: '2015-01-01')
    @qfs = Event.create!(name: 'Virtual Judging') # quarterfinals
  end

  def create_team(name, options = {})
    has_judged = !!options.delete(:has_judged)
    num_rubrics = options.delete(:num_rubrics).to_i

    if has_judged && num_rubrics == 0
      raise "If the current user has judged this team, there must be at least 1 rubric"
    end

    team = FactoryGirl.create(:team,
      {
        name: name,
        event_id: @qfs.id,
        division: 0,
        region: @me.judging_region
      }.merge(options))
    if has_judged
      FactoryGirl.create(:rubric, team: team, user: @me)
      num_rubrics -= 1
    end
    num_rubrics.times do
      u = FactoryGirl.create(:user, judging_region: 0)
      FactoryGirl.create(:rubric, team: team, user: u)
    end

    team
  end

  test "blank slate" do
    @today.value = '2014-12-31'
    @today.save!

    assert !Setting.anyJudgingRoundActive?

    get :index
    assert_response :success

    assert assigns(:rubrics).empty?

    assert_select "div.loggedin h1", "Judge dashboard"
    assert_select "div.loggedin h3", false, "No judging round active"
    assert_select "div.loggedin h4", /No judging rounds/
    assert_select "div.loggedin a", false
  end

  test "simple quarterfinals case" do
    @power_rangers = create_team("Power Rangers", num_rubrics: 1)
    @avengers = create_team("The Avengers", num_rubrics: 3)
    @golden_oldies = create_team("Golden Oldies", division: 2) # div 'x' = dq'ed

    get :index
    assert_response :success

    assert assigns(:rubrics).empty?
    assert_not_nil assigns(:teams)

    assert_select "div.loggedin h3", /quarterfinals/

    # Should skip Golden Oldies due to invalid division
    # Should skip Avengers because it has more rubrics already
    assert_equal "Power Rangers", assigns(:teams).first.name
  end

  test "should hide teams that i've judged already" do
    @power_rangers = create_team("Power Rangers", num_rubrics: 1, has_judged: true)
    @avengers = create_team("The Avengers", num_rubrics: 3)
    @powerpuff_girls = create_team("PowerPuff Girls", num_rubrics: 2)

    get :index
    assert_response :success

    assert_equal 1, assigns(:rubrics).size
    assert_not_nil assigns(:teams)

    assert_equal "PowerPuff Girls", assigns(:teams).first.name
    assert_equal "Power Rangers", assigns(:rubrics).first.team.name
  end

  test "ensure multiple rubrics are handled correctly" do
    @avengers = create_team("The Avengers", num_rubrics: 3)
    @powerpuff_girls = create_team("PowerPuff Girls", num_rubrics: 2)
    @power_rangers = create_team("Power Rangers", num_rubrics: 1, has_judged: true)

    FactoryGirl.create(:rubric, team: @powerpuff_girls, user: @me)
    FactoryGirl.create(:rubric, team: @avengers, user: @me)

    get :index
    assert_response :success
    assert_nil assigns(:teams)
    rubrics = assigns(:rubrics)
    assert_equal 3, rubrics.size
    assert_equal "Power Rangers", rubrics[2].team.name
    assert_equal "PowerPuff Girls", rubrics[1].team.name
    assert_equal "The Avengers", rubrics[0].team.name
  end

  test "semifinals" do
    @today.value = '2015-01-13'
    @today.save!

    @justice_league = create_team("Justice League", issemifinalist: true, region: 3)
    @watchmen = create_team("Watchmen")
    @avengers = create_team("The Avengers", issemifinalist: true)

    get :index
    assert_response :success

    assert assigns(:rubrics).empty?

    assert_select "div.loggedin h3", /semifinals/

    # Should skip Justice League due to mismatched region
    # Should skip Watchmen because it's not a semifinalist
    assert_equal "The Avengers", assigns(:teams).first.name
  end

  test "inbetween date" do
    # in between semifinal judging close and final judging open
    @today.value = '2015-01-19'
    @today.save!

    create_team("Watchmen")
    create_team("The Pitches")

    assert !Setting.anyJudgingRoundActive?

    get :index
    assert_response :success

    assert_select "div.loggedin h4", /No judging rounds/

    assert assigns(:rubrics).empty?
    assert_nil assigns(:teams)
  end

  test "handle in-person events - something about event_active" do
#event = Event.create(
  #name: 'Bay Area Quarterfinals',
  #location: 'Dropbox',
  #whentooccur: DateTime.new(2015, 07, 11, 20, 10, 0),
  #description: 'Quarterfinals for the Bay Area',
  #organizer: 'Technovation',
#)

  end
end
