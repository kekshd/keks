# encoding: utf-8

require 'spec_helper'

describe Perf do
  let(:perf) { FactoryGirl.build(:perf) }

  it "doesn’t include http:// in its URL" do
    perf.save
    perf.reload
    expect(perf.url).not_to include("http://", "https://")
  end
end
