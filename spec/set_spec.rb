# Author: Bruce Tesar
#
# These specs verify that the standard library class Set is hashable in
# the expected manner: two distinct sets with equivalent members should be
# treated as equivalent sets, and should be assigned the same hash value.
# In early implementations of Ruby (including 1.8.6), Set did not meet
# these requirements.
# The class Set contains an instance of class Hash. At the time, Hash itself
# did not implement the methods hash() and eql?(), so they defaulted
# to the versions defined in class Object. As a consequence, two hashes were
# eql only if they were the same object, normally, and the hash() values
# assigned to them were equal only if they were the same object. The class Set
# also did not implement hash() and eql?(), and inherited this odd behavior.
# Later implementations of Ruby fixed this shortcoming, so that instances
# of Set are hashable. These specs verify that Set behaves as expected.

require 'set'

RSpec.shared_examples "equivalent sets" do |set1, set2|
  it "are equivalent" do
    expect(@sh1==@sh2).to be true
  end
  it "are not the same object" do
    expect(@sh1.equal?(@sh2)).not_to be true
  end
  it "are eql" do
    expect(@sh1.eql?(@sh2)).to be true
  end  
  it "have the same hash value" do
    expect(@sh1.hash).to equal(@sh2.hash)
  end  
end # shared_examples "equivalent sets"

RSpec.shared_examples "non-equivalent sets" do |set1, set2|
  it "are not equivalent" do
    expect(@sh1==@sh2).not_to be true
  end
  it "are not the same object" do
    expect(@sh1.equal?(@sh2)).not_to be true
  end
  it "are not eql" do
    expect(@sh1.eql?(@sh2)).not_to be true
  end  
  it "do not have the same hash value" do
    expect(@sh1.hash).not_to equal(@sh2.hash)
  end  
end # shared_examples "non-equivalent sets"

RSpec.describe Set do
  context "distinct sets" do
    before(:each) do
      @sh1 = Set.new
      @sh2 = Set.new
    end
    
    context "each with no members" do
      include_examples "equivalent sets", @sh1, @sh2
    end

    context "each with 'foobar'" do
      before(:each) do
        @sh1.add 'foobar'
        @sh2.add 'foobar'
      end
      include_examples "equivalent sets", @sh1, @sh2
    end

    context "one with 'foo' and one with 'bar'" do
      before(:each) do
        @sh1.add 'foo'
        @sh2.add 'bar'
      end
      include_examples "non-equivalent sets", @sh1, @sh2
    end
  end
end # describe Set
