require 'spec_helper'

module Cellect
  describe GroupedProject do
    PROJECT_TYPES.each do |project_type|
      context project_type do
        it_behaves_like 'stateful', :project
        it_behaves_like 'project', :project
        let(:project){ GroupedProject[project_type] }
        let(:user){ project.user 123 }
        let(:set_klass){ project.prioritized? ? DiffSet::PrioritySet : DiffSet::RandomSet }
        
        it 'should provide unseen from a random group for users' do
          project.groups[1] = set_klass.new
          project.groups[1].should_receive(:subtract).with user.seen, 3
          project.unseen_for 123, limit: 3
        end
        
        it 'should provide unseen from a specific group for users' do
          3.times{ |i| project.groups[i] = DiffSet::RandomSet.new }
          project.group(1).should_receive(:subtract).with user.seen, 3
          project.unseen_for 123, group_id: 1, limit: 3
        end
        
        it 'should sample subjects from a random group without a user' do
          project.groups[1] = set_klass.new
          project.group(1).should_receive(:sample).with 3
          project.sample limit: 3
        end
        
        it 'should sample subjects from a specific group without a user' do
          3.times{ |i| project.groups[i] = DiffSet::RandomSet.new }
          project.group(1).should_receive(:sample).with 3
          project.sample group_id: 1, limit: 3
        end
        
        it 'should sample subjects from a random group for a user' do
          project.groups[1] = set_klass.new
          project.groups[1].should_receive(:subtract).with user.seen, 3
          project.sample user_id: 123, limit: 3
        end
        
        it 'should sample subjects from a specific group for a user' do
          3.times{ |i| project.groups[i] = DiffSet::RandomSet.new }
          project.group(1).should_receive(:subtract).with user.seen, 3
          project.sample user_id: 123, group_id: 1, limit: 3
        end
        
        it 'should be grouped' do
          project.should be_grouped
        end
      end
    end
  end
end
