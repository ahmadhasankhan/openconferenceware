require 'spec_helper'

describe OpenConferenceWare::Track do
  fixtures :all

  before(:each) do
    @valid_attributes = {
      title: "value for title",
      description: "value for description",
      excerpt: "value for excerpt",
      color: "#00CC00",
      event_id: 1
    }
  end

  it "should build a new instance given valid attributes" do
    build(:track, @valid_attributes).should be_valid
  end

  it "should not be valid without an event" do
    build(:track, event: nil).should_not be_valid
  end

  it "should sort alphabetically by title" do
    tracks = [ build(:track, title: 'Blues'),
               build(:track, title: 'Punk'),
               build(:track, title: 'Folk'),
               nil ]

    sorted_tracks = tracks.sort
    sorted_tracks[0].should be_nil
    sorted_tracks[1].title.should == 'Blues'
    sorted_tracks[2].title.should == 'Folk'
    sorted_tracks[3].title.should == 'Punk'
  end
end
