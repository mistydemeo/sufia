require 'spec_helper'

RSpec.describe FileViewStat, :type => :model do
  let (:file_id) {"99"}
  let (:date) {DateTime.new}
  let (:file_stat) {FileViewStat.create(views:"25", date: date, file_id: file_id)}

  it "has attributes" do
    expect(file_stat).to respond_to(:views)
    expect(file_stat).to respond_to(:date)
    expect(file_stat).to respond_to(:file_id)
    expect(file_stat.file_id).to eq("99")
    expect(file_stat.date).to eq(date)
    expect(file_stat.views).to eq(25)
  end

  describe "#get_float_statistics" do

    let(:dates) {
      ldates = []
      4.downto(0) {|idx| ldates << (Date.today-idx.day) }
      ldates
    }
    let(:date_strs) {
      dates.map {|date|  date.strftime("%Y%m%d") }
    }

    let(:view_output) {
      [[statistic_date(dates[0]), 4], [statistic_date(dates[1]), 8], [statistic_date(dates[2]), 6], [statistic_date(dates[3]), 10]]
    }

    # This is what the data looks like that's returned from Google Analytics (GA) via the Legato gem
    # Due to the nature of querying GA, testing this data in an automated fashion is problematc.
    # Sample data structures were created by sending real events to GA from a test instance of
    # Scholarsphere.  The data below are essentially a "cut and paste" from the output of query
    # results from the Legato gem.
    let(:sample_pageview_statistics) {
      [
          OpenStruct.new(date: date_strs[0], pageviews: 4),
          OpenStruct.new(date: date_strs[1], pageviews: 8),
          OpenStruct.new(date: date_strs[2], pageviews: 6),
          OpenStruct.new(date: date_strs[3], pageviews: 10),
          #OpenStruct.new(date: date_strs[4], pageviews: 2)
      ]
    }
    describe "cache empty" do
      let (:stats) {
        expect(FileViewStat).to receive(:ga_statistics).and_return(sample_pageview_statistics)
        FileViewStat.statistics(file_id,Date.today-4.day)
      }

      it "includes cached ga data" do
        expect(FileViewStat.to_flots stats).to include(*view_output)
      end

      it "caches data" do
        expect(FileViewStat.to_flots stats).to include(*view_output)

        # at this point all data should be cached
        allow(FileViewStat).to receive(:ga_statistics).with(Date.today, file_id).and_raise("We should not call Google Analytics All data should be cached!")

        stats2 = FileViewStat.statistics(file_id,Date.today-5.day)
        expect(FileViewStat.to_flots stats2).to include(*view_output)
      end

    end

    describe "cache loaded" do

      let!(:file_view_stat) { FileViewStat.create(date: (Date.today-5.day).to_datetime, file_id: file_id, views:"25")}

      let (:stats) {
        expect(FileViewStat).to receive(:ga_statistics).and_return(sample_pageview_statistics)
        FileViewStat.statistics(file_id,Date.today-5.day)
      }

      it "includes cached data" do
        expect(FileViewStat.to_flots stats).to include([file_view_stat.date.to_i*1000,file_view_stat.views],*view_output)
      end

    end
  end
end

