require 'rails_helper'

RSpec.describe Api::TasksController, :type => :controller do

  context "for a new logged-in user with two tasks" do
    let(:task_list) { create(:task_list, :with_tasks) }
    let(:task1)     { task_list.tasks[0] }
    let(:task2)     { task_list.tasks[1] }
    let(:user)      { create(:user) }

    before          { sign_in(user) }

    describe "#index" do
      it "is expected to return json of array of those tasks" do
        get :index, task_list_id: task_list.id
        tasks = JSON.parse(response.body)

        expect(tasks).to eq [
          { 'id' => task1.id, 'description' => task1.description,
            'priority' => nil, 'due_date' => nil, 'completed' => false },
          { 'id' => task2.id, 'description' => task2.description,
            'priority' => nil, 'due_date' => nil, 'completed' => false }
        ]
      end
    end

    describe "#create" do
      let(:post_create) do
        post :create, task_list_id: task_list.id, description: "New Task"
      end

      it "is expected to add the record to the database" do
        expect {
          post_create
        }.to change(Task, :count).by(3) #TODO is correct?
      end

      it "is expected to return 200 OK" do
        post_create
        expect(response).to be_success
      end

      it "is expected to preserve passed parameters" do
        post_create
        expect(Task.order(:id).last.description).to eq "New Task"
      end
    end

    describe "#update" do
      let(:patch_update) do
        patch :update, task_list_id: task_list.id, id: task1.id,
          description: "New description", priority: 1, completed: true
      end

      it "is expected to update passed parameters of the given task" do
        patch_update

        expect(task1.reload.description).to eq "New description"
        expect(task1.priority).to           eq 1
        expect(task1.completed).to          eq true
      end

      it "is expected to return 200 OK" do
        patch_update
        expect(response).to be_success
      end
    end

    describe "#destroy" do
      let(:delete_destroy) do
        delete :destroy, task_list_id: task_list.id, id: task1.id
      end

      it "is expected to remove the task from database" do
        delete_destroy
        expect {
          task1.reload
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "is expected to return 200 OK" do
        delete_destroy
        expect(response).to be_success
      end
    end

  end
end
