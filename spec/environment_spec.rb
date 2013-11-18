require 'spec_helper'

describe SeedDump do
  describe 'dump_using_environment' do
    before(:all) do
      create_db
    end

    before(:each) do
      @env = {'FILE' => Dir.pwd + '/spec/db/seeds.rb',
              'VERBOSE' => false,
              'DEBUG' => false}

      ActiveSupport::DescendantsTracker.clear
    end

    it "should use 'create!' as the default create method" do
      load_sample_data

      @env['MODELS'] = 'Sample'

      SeedDump.dump_using_environment(@env).should include("Sample.create!")
    end

    it "should return the correct model data" do
      load_sample_data

      @env['MODELS'] = 'Sample'

      SeedDump.dump_using_environment(@env).should include("[{string: nil, text: nil, integer: nil, float: nil, decimal: nil, datetime: nil, time: nil, date: nil, binary: nil, boolean: nil}]")
    end

    it 'should run ok without ActiveRecord::SchemaMigration being set (needed for Rails Engines)' do
      schema_migration = ActiveRecord::SchemaMigration

      ActiveRecord.send(:remove_const, :SchemaMigration)

      begin

        SeedDump.dump_using_environment(@env)
      ensure
        ActiveRecord.const_set(:SchemaMigration, schema_migration)
      end
    end

    it "should skip any models whose tables don't exist" do
      load_sample_data

      SeedDump.dump_using_environment(@env).should_not include('NoTableModel')
    end

    it "should skip any models that don't have have any rows" do
      load_sample_data

      SeedDump.dump_using_environment(@env).should_not include('EmptyModel')
    end

    it 'should only pull attributes that are returned as strings' do
      load_sample_data

      @env['MODELS'] = 'Sample'
      @env['LIMIT'] = '1'

      original_attributes = Sample.new.attributes
      attributes = original_attributes.merge(['col1', 'col2', 'col3'] => 'ABC')

      Sample.any_instance.stub(:attributes).and_return(attributes)

      SeedDump.dump_using_environment(@env).should eq("Sample.create!([{string: nil, text: nil, integer: nil, float: nil, decimal: nil, datetime: nil, time: nil, date: nil, binary: nil, boolean: nil}])\n")
    end
  end
end
