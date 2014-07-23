require 'spec_helper'

describe GenericFileHelper do
  describe "#render_collection_list" do
    context "using a file that is part of a collection" do
      let(:collection) do
        mock_model(Collection, title: "Foo Collection")
      end

      let(:gf) do
        mock_model(GenericFile, { collections: [collection, collection] })
      end

      let(:link) do
        "<a href=\"/collections/#{collection.to_param}\">#{collection.title}</a>"
      end

      it "displays a comma-delimited list of collections" do
        expect(helper.render_collection_list(gf)).to eq("Part of: " + [link, link].join(", "))
      end
    end

    context "using a file that is not part of a collection" do
      let(:gf) do
        mock_model(GenericFile, { collections: [] })
      end

      it "renders nothing" do
        expect(helper.render_collection_list(gf)).to be_nil
      end
    end
  end
end
