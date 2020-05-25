# Author: Bruce Tesar

require 'lexicon_image'

RSpec.describe LexiconImage do
  let(:lexicon){instance_double("Lexicon")}
  let(:pref1){instance_double("Lexical_Entry", :label => "p1", :uf => "a")}
  let(:root1){instance_double("Lexical_Entry", :label => "r1", :uf => "x")}
  let(:root2){instance_double("Lexical_Entry", :label => "r2", :uf => "y")}
  let(:suff1){instance_double("Lexical_Entry", :label => "s1", :uf => "y")}
  context "An empty lexicon should produce an image" do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = LexiconImage.new(lexicon)
    end
    it "with one row" do
      expect(@lexicon_image.row_count).to eq(1)
    end
    it "with one column" do
      expect(@lexicon_image.col_count).to eq(1)
    end
    it "with nil in [1,1]" do
      expect(@lexicon_image[1,1]).to be nil
    end
  end
  
  context "A lexicon with root r1 /x/" do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = LexiconImage.new(lexicon)
    end    
    it "should produce an image with one row" do
      expect(@lexicon_image.row_count).to eq(1)
    end
    it "should produce an image with two columns" do
      expect(@lexicon_image.col_count).to eq(2)
    end
    it "should produce an image with with 'r1' in [1,1]" do
      expect(@lexicon_image[1,1]).to eq('r1')
    end
    it "should produce an image with with 'x' in [1,2]" do
      expect(@lexicon_image[1,2]).to eq('x')
    end    
  end

  context "A lexicon with root 1 r1 /x/ and root r2 /y/" do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1, root2])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = LexiconImage.new(lexicon)
    end    
    it "should produce an image with one row" do
      expect(@lexicon_image.row_count).to eq(1)
    end
    it "should produce an image with five columns" do
      expect(@lexicon_image.col_count).to eq(5)
    end
    it "should produce an image with with 'r1' in [1,1]" do
      expect(@lexicon_image[1,1]).to eq('r1')
    end
    it "should produce an image with with 'x' in [1,2]" do
      expect(@lexicon_image[1,2]).to eq('x')
    end
    it "should produce an image with with nil in [1,3]" do
      expect(@lexicon_image[1,3]).to be nil
    end
    it "should produce an image with with 'r2' in [1,4]" do
      expect(@lexicon_image[1,4]).to eq('r2')
    end
    it "should produce an image with with 'y' in [1,5]" do
      expect(@lexicon_image[1,5]).to eq('y')
    end
  end

  context "A lexicon with root 1 r1 /x/ and suffix s1 /y/" do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([suff1])
      @lexicon_image = LexiconImage.new(lexicon)
    end    
    it "should produce an image with two rows" do
      expect(@lexicon_image.row_count).to eq(2)
    end
    it "should produce an image with two columns" do
      expect(@lexicon_image.col_count).to eq(2)
    end
    it "should produce an image with with 'r1' in [1,1]" do
      expect(@lexicon_image[1,1]).to eq('r1')
    end
    it "should produce an image with with 'x' in [1,2]" do
      expect(@lexicon_image[1,2]).to eq('x')
    end
    it "should produce an image with with 's1' in [2,1]" do
      expect(@lexicon_image[2,1]).to eq('s1')
    end
    it "should produce an image with with 'y' in [2,2]" do
      expect(@lexicon_image[2,2]).to eq('y')
    end
  end

  context "A lexicon with prefix p1 /a/, root r1 /x/ and suffix s1 /y/" do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([pref1])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([suff1])
      @lexicon_image = LexiconImage.new(lexicon)
    end    
    it "should produce an image with three rows" do
      expect(@lexicon_image.row_count).to eq(3)
    end
    it "should produce an image with two columns" do
      expect(@lexicon_image.col_count).to eq(2)
    end
    it "should produce an image with with 's1' in [1,1]" do
      expect(@lexicon_image[1,1]).to eq('p1')
    end
    it "should produce an image with with 'y' in [1,2]" do
      expect(@lexicon_image[1,2]).to eq('a')
    end
    it "should produce an image with with 'r1' in [2,1]" do
      expect(@lexicon_image[2,1]).to eq('r1')
    end
    it "should produce an image with with 'x' in [2,2]" do
      expect(@lexicon_image[2,2]).to eq('x')
    end
    it "should produce an image with with 's1' in [3,1]" do
      expect(@lexicon_image[3,1]).to eq('s1')
    end
    it "should produce an image with with 'y' in [3,2]" do
      expect(@lexicon_image[3,2]).to eq('y')
    end
  end

end # RSpec.describe LexiconImage
