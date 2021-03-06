require 'spec_helper'

describe "open_conference_ware/proposals/show.html.erb" do
  before :each do
    stub_settings_accessors_on(view)

    @user = build :user
    @event = create :populated_event, proposal_status_published: false
    @proposal = proposal_for_event(@event, users: [@user])

    view.stub(:schedule_visible? => true)
  end

  %w[accepted confirmed waitlisted rejected junk].each do |status|
    it "should not show the status for #{status} proposals if statuses are not published" do
      @event.proposal_status_published = false
      @proposal.status = status

      assign(:event, @event)
      assign(:proposal, @proposal)
      assign(:kind, :proposal)

      render
      rendered.should_not have_selector(".#{status}")
    end
  end

  it "should show the proposal status for a confirmed proposal if statuses are published" do
    @event.proposal_status_published = true
    @proposal.status = 'confirmed'

    assign(:event, @event)
    assign(:proposal, @proposal)
    assign(:kind, :proposal)

    render
    rendered.should have_selector("div.proposal-status")
  end

  %w[accepted waitlisted rejected junk].each do |status|
    it "should should not show the status for #{status} proposals even if statuses are published" do
      @event.proposal_status_published = true
      @proposal.status = status

      assign(:event, @event)
      assign(:proposal, @proposal)
      assign(:kind, :proposal)

      render
      rendered.should_not have_selector(".#{status}")
    end
  end

  %w[confirmed].each do |status|
    it "should show the status for #{status} proposals if statuses are published" do
      @event.proposal_status_published = true
      @proposal.status = status

      assign(:event, @event)
      assign(:proposal, @proposal)
      assign(:kind, :proposal)

      render
      rendered.should have_selector(".#{status}")
    end
  end

  describe "with confirmed proposal for event that publishes status" do
    before :each do
      @event.proposal_status_published = true
      @proposal.status = 'confirmed'
      @proposal.start_time = nil
      @proposal.room = nil

      assign(:event, @event)
      assign(:proposal, @proposal)
      assign(:kind, :proposal)
    end

    it "should show the proposal status for a confirmed proposal" do
      render
      rendered.should have_selector(".proposal-status")
      rendered.should_not have_selector(".proposal-scheduling")
      rendered.should_not have_selector(".proposal-room")
    end

    it "should show session time if set" do
      @proposal.start_time = Time.now

      render
      rendered.should have_selector(".proposal-scheduling")
      rendered.should_not have_selector(".proposal-room")
    end

    it "should show session time and location if both set" do
      @proposal.start_time = Time.now
      @proposal.room = @event.rooms.first

      render
      rendered.should have_selector(".proposal-scheduling")
      rendered.should have_selector(".proposal-room")
    end
  end

  it "should only show proposals in the speaker's bio that are for this event and its family" do
    user = build :user
    parent = create :populated_event, proposal_status_published: true
    event  = create :populated_event, proposal_status_published: true, parent: parent
    child  = create :populated_event, proposal_status_published: true, parent: event
    other  = create :populated_event, proposal_status_published: true
    event_proposal  = session_for_event event,  users: [user]
    child_proposal  = session_for_event child,  users: [user]
    other_proposal  = session_for_event other,  users: [user]
    parent_proposal = session_for_event parent, users: [user]
    event.reload

    assign(:event, event)
    assign(:proposal, event_proposal)
    assign(:kind, :proposal)
    render

    rendered.should have_selector(".session_info     a[href='#{session_path(event_proposal )}']")
    rendered.should have_selector(".session_info     a[href='#{session_path(child_proposal )}']")
    rendered.should have_selector(".session_info     a[href='#{session_path(parent_proposal)}']")
    rendered.should_not have_selector(".session_info a[href='#{session_path(other_proposal )}']")
  end
end
