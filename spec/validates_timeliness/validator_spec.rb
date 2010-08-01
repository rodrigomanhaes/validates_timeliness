require 'spec_helper'

describe ValidatesTimeliness::Validator do
  include ModelHelpers
  NIL = [nil]

  before do
    Timecop.freeze(Time.local_time(2010, 1, 1, 0, 0, 0))
  end

  it 'should return validator kind as :timeliness' do
    ValidatesTimeliness::Validator.kind.should == :timeliness 
  end

  describe "Model.validates :timeliness option" do
    it 'should use plugin validator class' do
      Person.validates :birth_date, :timeliness => {:is_at => Date.new(2010,1,1), :type => :date}
      Person.validators.should have(1).kind_of(TimelinessValidator)
      valid!(:birth_date, Date.new(2010,1,1))
      invalid!(:birth_date, Date.new(2010,1,2))
    end
  end

  describe ":allow_nil option" do
    it 'should not allow nil by default' do
      Person.validates_datetime :birth_date
      invalid!(:birth_date, NIL)
      valid!(:birth_date, Date.today)
    end

    it 'should allow nil when true' do
      Person.validates_datetime :birth_date, :allow_nil => true
      valid!(:birth_date, NIL)
    end
  end

  describe ":allow_blank option" do
    it 'should not allow blank by default' do
      Person.validates_datetime :birth_date
      invalid!(:birth_date, '')
      valid!(:birth_date, Date.today)
    end

    it 'should allow blank when true' do
      Person.validates_datetime :birth_date, :allow_blank => true
      valid!(:birth_date, '')
    end
  end

  describe ":between option" do
    describe "array value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_time :birth_date, :between => [on_or_after, on_or_before]
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
      end
    end

    describe "range value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_time :birth_date, :between => on_or_after..on_or_before
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
      end
    end
  end
end
