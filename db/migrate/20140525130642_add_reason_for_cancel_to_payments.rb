class AddReasonForCancelToPayments < ActiveRecord::Migration
  def up
		add_column(:payments, :reason_for_cancellation, :string)	unless column_exists?(:payments, :reason_for_cancellation)
    end

    def down    	
    	remove_column(:payments, :reason_for_cancellation)	if column_exists?(:payments, :reason_for_cancellation)    	
    end
end
